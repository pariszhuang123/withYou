import '../contracts/app_contracts.dart';
import '../contracts/commerce_contracts.dart';
import '../contracts/platform_contracts.dart';

class PremiumAccessService implements PremiumAccessContract {
  const PremiumAccessService({
    required AppStateContract appStateContract,
    required WidgetVisualStateContract widgetVisualStateContract,
  }) : _appStateContract = appStateContract,
       _widgetVisualStateContract = widgetVisualStateContract;

  final AppStateContract _appStateContract;
  final WidgetVisualStateContract _widgetVisualStateContract;

  @override
  Future<PremiumAccessState> getAccessState() async {
    final hasPremiumAccess = await _appStateContract.hasPremiumAccess();
    return hasPremiumAccess
        ? PremiumAccessState.active
        : PremiumAccessState.inactive;
  }

  @override
  Future<void> recordPurchase() async {
    await _appStateContract.setPremiumAccess(true);
    await _widgetVisualStateContract.syncPremiumAccess(isActive: true);
  }

  @override
  Future<void> refresh() async {
    final hasPremiumAccess = await _appStateContract.hasPremiumAccess();
    await _widgetVisualStateContract.syncPremiumAccess(
      isActive: hasPremiumAccess,
    );
  }

  @override
  Future<void> restorePurchases() => refresh();
}
