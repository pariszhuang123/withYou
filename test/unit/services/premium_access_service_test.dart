import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/app_contracts.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/contracts/commerce_contracts.dart';
import 'package:with_you/services/premium_access_service.dart';

class _TestAppStateContract implements AppStateContract {
  bool premiumAccess = false;

  @override
  Future<String?> getSelectedAudioLocaleTag() async => null;

  @override
  Future<Scenario?> getSelectedScenario() async => null;

  @override
  Future<bool> hasPremiumAccess() async => premiumAccess;

  @override
  Future<void> setPremiumAccess(bool hasPremiumAccess) async {
    premiumAccess = hasPremiumAccess;
  }

  @override
  Future<void> setSelectedAudioLocaleTag(String localeTag) async {}

  @override
  Future<void> setSelectedScenario(Scenario scenario) async {}
}

void main() {
  test('recordPurchase persists active premium state', () async {
    final appState = _TestAppStateContract();
    final service = PremiumAccessService(appStateContract: appState);

    expect(await service.getAccessState(), PremiumAccessState.inactive);

    await service.recordPurchase();

    expect(await service.getAccessState(), PremiumAccessState.active);
  });
}
