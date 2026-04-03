import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/commerce_contracts.dart';
import 'package:with_you/services/paywall_service.dart';

class _TestPremiumAccessContract implements PremiumAccessContract {
  _TestPremiumAccessContract(this.state);

  PremiumAccessState state;

  @override
  Future<PremiumAccessState> getAccessState() async => state;

  @override
  Future<void> recordPurchase() async {
    state = PremiumAccessState.active;
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<void> restorePurchases() async {}
}

void main() {
  test('active premium hides the paywall', () async {
    final service = PaywallService(
      premiumAccessContract: _TestPremiumAccessContract(
        PremiumAccessState.active,
      ),
    );

    final decision = await service.evaluate(
      surface: PaywallSurface.sceneSelection,
    );

    expect(decision, PaywallDecision.hidden);
  });

  test('scene selection uses a feature gate when premium is inactive', () async {
    final service = PaywallService(
      premiumAccessContract: _TestPremiumAccessContract(
        PremiumAccessState.inactive,
      ),
    );

    final decision = await service.evaluate(
      surface: PaywallSurface.sceneSelection,
    );

    expect(decision, PaywallDecision.showFeatureGate);
  });

  test('settings uses a soft prompt when premium is inactive', () async {
    final service = PaywallService(
      premiumAccessContract: _TestPremiumAccessContract(
        PremiumAccessState.inactive,
      ),
    );

    final decision = await service.evaluate(surface: PaywallSurface.settings);

    expect(decision, PaywallDecision.showSoftPrompt);
  });
}
