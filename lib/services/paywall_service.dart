import '../contracts/commerce_contracts.dart';

class PaywallService implements PaywallContract {
  const PaywallService({
    required PremiumAccessContract premiumAccessContract,
  }) : _premiumAccessContract = premiumAccessContract;

  final PremiumAccessContract _premiumAccessContract;

  @override
  Future<PaywallDecision> evaluate({required PaywallSurface surface}) async {
    final accessState = await _premiumAccessContract.getAccessState();
    if (accessState == PremiumAccessState.active) {
      return PaywallDecision.hidden;
    }

    return switch (surface) {
      PaywallSurface.sceneSelection => PaywallDecision.showFeatureGate,
      PaywallSurface.widgetSetup => PaywallDecision.showFeatureGate,
      PaywallSurface.settings => PaywallDecision.showSoftPrompt,
      PaywallSurface.postQuickExit => PaywallDecision.showSoftPrompt,
    };
  }

  @override
  Future<void> recordDismissed({required PaywallSurface surface}) async {}
}
