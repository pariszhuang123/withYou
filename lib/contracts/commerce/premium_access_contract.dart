enum PremiumAccessState { inactive, active }

abstract class PremiumAccessContract {
  Future<PremiumAccessState> getAccessState();

  Future<void> refresh();

  Future<void> recordPurchase();

  Future<void> restorePurchases();
}
