enum PaywallSurface { sceneSelection, settings, widgetSetup, postQuickExit }

enum PaywallDecision { hidden, showFeatureGate, showSoftPrompt }

abstract class PaywallContract {
  Future<PaywallDecision> evaluate({required PaywallSurface surface});

  Future<void> recordDismissed({required PaywallSurface surface});
}
