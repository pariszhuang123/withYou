import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/commerce_contracts.dart';

void main() {
  test('paywall surfaces remain setup-oriented', () {
    expect(PaywallSurface.values, hasLength(4));
    expect(PaywallSurface.values, contains(PaywallSurface.sceneSelection));
    expect(PaywallSurface.values, contains(PaywallSurface.widgetSetup));
    expect(PaywallSurface.values, contains(PaywallSurface.postQuickExit));
  });

  test('paywall decisions model hidden, gate, and soft prompt states', () {
    expect(PaywallDecision.values, <PaywallDecision>[
      PaywallDecision.hidden,
      PaywallDecision.showFeatureGate,
      PaywallDecision.showSoftPrompt,
    ]);
  });
}
