import '../contracts/app_contracts.dart';
import '../contracts/commerce_contracts.dart';

class PremiumAccessService implements PremiumAccessContract {
  const PremiumAccessService({required AppStateContract appStateContract})
    : _appStateContract = appStateContract;

  final AppStateContract _appStateContract;

  @override
  Future<PremiumAccessState> getAccessState() async {
    final hasPremiumAccess = await _appStateContract.hasPremiumAccess();
    return hasPremiumAccess
        ? PremiumAccessState.active
        : PremiumAccessState.inactive;
  }

  @override
  Future<void> recordPurchase() {
    return _appStateContract.setPremiumAccess(true);
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<void> restorePurchases() async {}
}
