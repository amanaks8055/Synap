// lib/blocs/premium/premium_event.dart
import 'package:in_app_purchase/in_app_purchase.dart';

abstract class PremiumEvent { const PremiumEvent(); }

/// Called once on app start — init billing + check cached status
class PremiumInitialized extends PremiumEvent {}

/// User tapped a plan card's buy button
class PremiumPurchaseStarted extends PremiumEvent {
  final String productId;
  const PremiumPurchaseStarted(this.productId);
}

/// Play Billing stream emitted updates
class PremiumPurchaseUpdated extends PremiumEvent {
  final List<PurchaseDetails> purchases;
  const PremiumPurchaseUpdated(this.purchases);
}

/// User tapped "Restore Purchase"
class PremiumPurchaseRestored extends PremiumEvent {}

/// Billing stream error
class PremiumPurchaseError extends PremiumEvent {
  final String message;
  const PremiumPurchaseError(this.message);
}

/// Force-unlock after server validation (advanced flow)
class PremiumUnlocked extends PremiumEvent {
  final String productId;
  const PremiumUnlocked(this.productId);
}
