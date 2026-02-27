// ══════════════════════════════════════════════════════════════
// SYNAP — PremiumBloc
// Full Google Play Billing via in_app_purchase
// Handles: Student + Professional tiers, restore, errors
// ══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'premium_event.dart';
import 'premium_state.dart';
import 'premium_plans.dart';

export 'premium_state.dart';
export 'premium_event.dart';
export 'premium_plans.dart';

// SharedPreferences keys
const _kIsPremium      = 'synap_is_premium';
const _kActivePlan     = 'synap_active_plan';
const _kActiveTier     = 'synap_active_tier';
const _kPurchaseToken  = 'synap_purchase_token';

class PremiumBloc extends Bloc<PremiumEvent, PremiumState> {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  PremiumBloc() : super(PremiumState.initial()) {
    on<PremiumInitialized>(_onInit);
    on<PremiumPurchaseStarted>(_onPurchaseStarted);
    on<PremiumPurchaseUpdated>(_onPurchaseUpdated);
    on<PremiumPurchaseRestored>(_onRestore);
    on<PremiumPurchaseError>(_onError);
    on<PremiumUnlocked>(_onUnlocked);

    add(PremiumInitialized());
  }

  // ══════════════════════════════════════════════════════════
  // 1. INITIALIZE
  // ══════════════════════════════════════════════════════════
  Future<void> _onInit(
    PremiumInitialized event,
    Emitter<PremiumState> emit,
  ) async {
    emit(state.copyWith(status: PremiumStatus.loading));

    // ── Step 1: Check cached premium (instant UI, no wait) ──
    final prefs = await SharedPreferences.getInstance();
    final cachedPremium = prefs.getBool(_kIsPremium) ?? false;
    final cachedPlan    = prefs.getString(_kActivePlan);
    final cachedTierStr = prefs.getString(_kActiveTier);
    final cachedTier    = cachedTierStr == 'professional'
        ? PlanTier.professional
        : cachedTierStr == 'student'
            ? PlanTier.student
            : null;

    if (cachedPremium) {
      emit(state.copyWith(
        isPremium: true,
        activeProductId: cachedPlan,
        activeTier: cachedTier,
        status: PremiumStatus.idle,
      ));
    }

    // ── Step 2: Check billing availability ──────────────────
    final available = await _iap.isAvailable();
    if (!available) {
      emit(state.copyWith(
        status: PremiumStatus.error,
        errorMessage: 'Google Play Billing not available.',
        billingAvailable: false,
      ));
      return;
    }

    emit(state.copyWith(billingAvailable: true));

    // ── Step 3: Subscribe to purchase stream ────────────────
    _purchaseSub?.cancel();
    _purchaseSub = _iap.purchaseStream.listen(
      (list) => add(PremiumPurchaseUpdated(list)),
      onError: (e) => add(PremiumPurchaseError(e.toString())),
    );

    // ── Step 4: Load products from Play Store ───────────────
    await _loadProducts(emit);
  }

  Future<void> _loadProducts(Emitter<PremiumState> emit) async {
    try {
      final response = await _iap.queryProductDetails(SynapPlans.allIds);

      if (response.error != null) {
        // Non-fatal — UI still works with static prices
        emit(state.copyWith(
          status: PremiumStatus.idle,
          errorMessage: null, // don't show to user
        ));
        return;
      }

      emit(state.copyWith(
        status: PremiumStatus.idle,
        products: response.productDetails,
        clearError: true,
      ));
    } catch (e) {
      // Non-fatal — static prices will be used
      emit(state.copyWith(status: PremiumStatus.idle));
    }
  }

  // ══════════════════════════════════════════════════════════
  // 2. PURCHASE STARTED
  // ══════════════════════════════════════════════════════════
  Future<void> _onPurchaseStarted(
    PremiumPurchaseStarted event,
    Emitter<PremiumState> emit,
  ) async {
    emit(state.copyWith(
      status: PremiumStatus.purchasing,
      clearError: true,
    ));

    try {
      // Find product details
      ProductDetails? product;
      try {
        product = state.products.firstWhere((p) => p.id == event.productId);
      } catch (_) {
        // Product not loaded from Play Store
        emit(state.copyWith(
          status: PremiumStatus.error,
          errorMessage: 'Product not found. Ensure ID is correct in Play Console.',
        ));
        return;
      }

      final param = PurchaseParam(productDetails: product);

      // Buy consumable/non-consumable based on logic
      final success = await _iap.buyNonConsumable(purchaseParam: param);

      if (!success) {
        emit(state.copyWith(
          status: PremiumStatus.error,
          errorMessage: 'Failed to initiate purchase. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PremiumStatus.error,
        errorMessage: _friendlyError(e.toString()),
      ));
    }
  }

  // ══════════════════════════════════════════════════════════
  // 3. PURCHASE STREAM UPDATES
  // ══════════════════════════════════════════════════════════
  Future<void> _onPurchaseUpdated(
    PremiumPurchaseUpdated event,
    Emitter<PremiumState> emit,
  ) async {
    for (final purchase in event.purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          emit(state.copyWith(status: PremiumStatus.purchasing));
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _deliver(purchase, emit);
          break;

        case PurchaseStatus.error:
          final code = purchase.error?.code ?? '';
          if (code == 'BillingResponse.userCanceled' || code == '1') {
            emit(state.copyWith(status: PremiumStatus.idle));
          } else {
            emit(state.copyWith(
              status: PremiumStatus.error,
              errorMessage: _friendlyError(purchase.error?.message ?? 'Purchase failed'),
            ));
          }
          break;

        case PurchaseStatus.canceled:
          emit(state.copyWith(status: PremiumStatus.idle, clearError: true));
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  // ══════════════════════════════════════════════════════════
  // 4. DELIVER PURCHASE (unlock premium)
  // ══════════════════════════════════════════════════════════
  Future<void> _deliver(
    PurchaseDetails purchase,
    Emitter<PremiumState> emit,
  ) async {
    final productId = purchase.productID;
    final tier = SynapPlans.isPro(productId) ? PlanTier.professional : PlanTier.student;

    // ─── TODO: Server-side verification (CRITICAL for production) ───
    // Replace this section with an API call to YOUR backend:
    //
    // final response = await http.post(
    //   Uri.parse('https://your-api.com/verify-purchase'),
    //   body: {
    //     'purchaseToken': purchase.verificationData.serverVerificationData,
    //     'productId': purchase.productID,
    //     'packageName': 'com.synap.synap',
    //   },
    // );
    // if (response.statusCode != 200) {
    //   emit(state.copyWith(status: PremiumStatus.error,
    //     errorMessage: 'Verification failed. Contact support.'));
    //   return;
    // }
    //
    // Your backend calls Google Play Developer API to verify:
    // https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptions/get
    // ────────────────────────────────────────────────────────────────

    // Persist locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPremium, true);
    await prefs.setString(_kActivePlan, productId);
    await prefs.setString(_kActiveTier, tier == PlanTier.professional ? 'professional' : 'student');
    await prefs.setString(_kPurchaseToken, purchase.purchaseID ?? '');

    emit(state.copyWith(
      isPremium: true,
      status: PremiumStatus.success,
      activeProductId: productId,
      activeTier: tier,
      clearError: true,
    ));
  }

  // ══════════════════════════════════════════════════════════
  // 5. RESTORE PURCHASES
  // ══════════════════════════════════════════════════════════
  Future<void> _onRestore(
    PremiumPurchaseRestored event,
    Emitter<PremiumState> emit,
  ) async {
    emit(state.copyWith(status: PremiumStatus.restoring, clearError: true));

    try {
      await _iap.restorePurchases();
      // Results come via purchaseStream with status=restored
      await Future.delayed(const Duration(seconds: 3));
      if (!state.isPremium) {
        emit(state.copyWith(
          status: PremiumStatus.error,
          errorMessage: 'No previous purchase found for this account.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PremiumStatus.error,
        errorMessage: 'Restore failed: ${_friendlyError(e.toString())}',
      ));
    }
  }

  // ══════════════════════════════════════════════════════════
  // 6. FORCE UNLOCK (after server validation if needed)
  // ══════════════════════════════════════════════════════════
  Future<void> _onUnlocked(
    PremiumUnlocked event,
    Emitter<PremiumState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final tier  = SynapPlans.isPro(event.productId) ? PlanTier.professional : PlanTier.student;
    await prefs.setBool(_kIsPremium, true);
    await prefs.setString(_kActivePlan, event.productId);
    await prefs.setString(_kActiveTier, tier == PlanTier.professional ? 'professional' : 'student');

    emit(state.copyWith(
      isPremium: true,
      status: PremiumStatus.success,
      activeProductId: event.productId,
      activeTier: tier,
    ));
  }

  // ══════════════════════════════════════════════════════════
  // 7. ERROR
  // ══════════════════════════════════════════════════════════
  void _onError(PremiumPurchaseError event, Emitter<PremiumState> emit) {
    emit(state.copyWith(
      status: PremiumStatus.error,
      errorMessage: _friendlyError(event.message),
    ));
  }

  String _friendlyError(String raw) {
    final r = raw.toLowerCase();
    if (r.contains('cancel'))           return 'Purchase was cancelled.';
    if (r.contains('network'))          return 'No internet connection.';
    if (r.contains('item_unavailable')) return 'This plan is not available right now.';
    if (r.contains('already_owned'))    return 'You already own this plan. Try "Restore Purchase".';
    return raw.length > 80 ? '${raw.substring(0, 80)}...' : raw;
  }

  @override
  Future<void> close() {
    _purchaseSub?.cancel();
    return super.close();
  }
}
