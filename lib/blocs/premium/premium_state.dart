// lib/blocs/premium/premium_state.dart
import 'package:in_app_purchase/in_app_purchase.dart';
import 'premium_plans.dart';

enum PremiumStatus {
  initial,
  loading,
  idle,
  purchasing,
  restoring,
  success,
  error,
}

class PremiumState {
  final PremiumStatus status;
  final bool isPremium;
  final PlanTier? activeTier;           // student or professional
  final String? activeProductId;
  final List<ProductDetails> products;  // from Play Store
  final String? errorMessage;
  final bool billingAvailable;

  const PremiumState({
    required this.status,
    required this.isPremium,
    required this.products,
    required this.billingAvailable,
    this.activeTier,
    this.activeProductId,
    this.errorMessage,
  });

  factory PremiumState.initial() => const PremiumState(
    status: PremiumStatus.initial,
    isPremium: false,
    products: [],
    billingAvailable: false,
  );

  // Convenience
  bool get isLoading     => status == PremiumStatus.loading;
  bool get isPurchasing  => status == PremiumStatus.purchasing;
  bool get isRestoring   => status == PremiumStatus.restoring;
  bool get isSuccess     => status == PremiumStatus.success;
  bool get hasError      => status == PremiumStatus.error;

  bool get isStudent      => activeTier == PlanTier.student;
  bool get isProfessional => activeTier == PlanTier.professional;

  // Get live price from Play Store (fallback to static)
  String livePrice(String productId, String fallback) {
    try {
      return products.firstWhere((p) => p.id == productId).price;
    } catch (_) {
      return fallback;
    }
  }

  PremiumState copyWith({
    PremiumStatus? status,
    bool? isPremium,
    PlanTier? activeTier,
    String? activeProductId,
    List<ProductDetails>? products,
    String? errorMessage,
    bool? billingAvailable,
    bool clearError = false,
  }) {
    return PremiumState(
      status: status ?? this.status,
      isPremium: isPremium ?? this.isPremium,
      activeTier: activeTier ?? this.activeTier,
      activeProductId: activeProductId ?? this.activeProductId,
      products: products ?? this.products,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      billingAvailable: billingAvailable ?? this.billingAvailable,
    );
  }
}
