import '../call_flow/fake_call_timing_contract.dart';

class WidgetLaunchEvent {
  const WidgetLaunchEvent({required this.scenario});

  final Scenario? scenario;
}

abstract class WidgetLaunchEventContract {
  Stream<WidgetLaunchEvent> get eventStream;
}
