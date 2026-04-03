import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/app_contracts.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';

void main() {
  test('app launch intents capture external route inputs', () {
    const intent = AppLaunchIntent(
      source: AppLaunchSource.homeScreenWidget,
      destination: AppRouteDestination.paywall,
      scenario: Scenario.socialPull,
      stage: 2,
      sessionId: 'session-42',
    );

    expect(intent.source, AppLaunchSource.homeScreenWidget);
    expect(intent.destination, AppRouteDestination.paywall);
    expect(intent.scenario, Scenario.socialPull);
    expect(intent.stage, 2);
    expect(intent.sessionId, 'session-42');
  });

  test('home route state has no external payload by default', () {
    const route = AppRouteState.home();

    expect(route.destination, AppRouteDestination.home);
    expect(route.scenario, isNull);
    expect(route.stage, isNull);
    expect(route.sessionId, isNull);
  });
}
