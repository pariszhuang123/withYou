import '../call_flow/fake_call_timing_contract.dart';

enum WidgetAvailabilityState { available, requiresPremium, unavailable }

class WidgetAvailability {
  const WidgetAvailability({
    required this.state,
    this.supportsDirectPickerLaunch = false,
  });

  final WidgetAvailabilityState state;
  final bool supportsDirectPickerLaunch;
}

enum LaunchSurface { appButton, homeScreenWidget }

enum WidgetLaunchOutcome {
  launchSelectedScene,
  fallbackToPresence,
  openPremiumScreen,
}

class WidgetLaunchPlan {
  const WidgetLaunchPlan({
    required this.outcome,
    required this.requestedScenario,
    required this.resolvedScenario,
    this.showFallbackMessage = false,
  });

  final WidgetLaunchOutcome outcome;
  final Scenario requestedScenario;
  final Scenario resolvedScenario;
  final bool showFallbackMessage;
}

abstract class WidgetAvailabilityContract {
  Future<WidgetAvailability> getAvailability();
}

abstract class WidgetLaunchContract {
  Future<WidgetLaunchPlan> planLaunch({
    required LaunchSurface surface,
    required Scenario selectedScenario,
  });
}
