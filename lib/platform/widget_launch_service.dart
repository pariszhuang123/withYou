import 'dart:async';

import 'package:flutter/services.dart';

import '../contracts/call_flow_contracts.dart';
import '../contracts/platform_contracts.dart';

class WidgetLaunchPlatformService implements WidgetLaunchEventContract {
  WidgetLaunchPlatformService({EventChannel? eventChannel})
    : _eventChannel =
          eventChannel ?? const EventChannel('with_you/widget_launch/events') {
    _eventStream = _eventChannel
        .receiveBroadcastStream()
        .map(_mapEvent)
        .asBroadcastStream();
  }

  final EventChannel _eventChannel;
  late final Stream<WidgetLaunchEvent> _eventStream;

  @override
  Stream<WidgetLaunchEvent> get eventStream => _eventStream;

  static WidgetLaunchEvent _mapEvent(dynamic rawEvent) {
    final payload = (rawEvent as Map<dynamic, dynamic>).cast<String, dynamic>();
    final scenarioName = payload['scenario'] as String?;

    return WidgetLaunchEvent(scenario: _scenarioFromName(scenarioName));
  }

  static Scenario? _scenarioFromName(String? rawScenario) {
    if (rawScenario == null || rawScenario.isEmpty) {
      return null;
    }

    for (final scenario in Scenario.values) {
      if (scenario.name == rawScenario) {
        return scenario;
      }
    }

    return null;
  }
}
