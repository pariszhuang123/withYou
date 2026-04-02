import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/platform/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('test/notifications/methods');
  const eventChannel = EventChannel('test/notifications/events');

  final methodCalls = <MethodCall>[];
  setUp(() {
    methodCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (call) async {
          methodCalls.add(call);
          if (call.method == 'initialize') {
            return true;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(eventChannel, null);
  });

  test('initialize binds the native bridge and reports enabled state', () async {
    final service = NotificationService(
      methodChannel: methodChannel,
      eventChannel: eventChannel,
    );

    final initialized = await service.initialize();

    expect(initialized, isTrue);
    expect(methodCalls.single.method, 'initialize');
  });

  test('scheduleFollowUp forwards payload to the native bridge', () async {
    final service = NotificationService(
      methodChannel: methodChannel,
      eventChannel: eventChannel,
    );

    await service.scheduleFollowUp(
      sessionId: 'session-a',
      scenario: Scenario.socialPull,
      stage: 2,
      delay: const Duration(minutes: 2),
      callerName: 'Xiao Li',
    );

    expect(methodCalls.single.method, 'scheduleFollowUp');
    expect(methodCalls.single.arguments, <String, Object?>{
      'sessionId': 'session-a',
      'scenario': 'socialPull',
      'stage': 2,
      'delaySeconds': 120,
      'callerName': 'Xiao Li',
    });
  });

  test('eventStream emits notification events from the native event channel', () async {
    final service = NotificationService(
      methodChannel: methodChannel,
      eventChannel: eventChannel,
    );

    final events = <NotificationEvent>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(eventChannel, MockStreamHandler.inline(
      onListen: (Object? arguments, MockStreamHandlerEventSink eventsSink) {
        eventsSink.success(<String, Object?>{
          'sessionId': 'session-b',
          'scenario': 'exitPressure',
          'stage': 3,
          'action': 'missed',
        });
      },
      onCancel: (Object? arguments) {},
    ));

    await service.initialize();
    final subscription = service.eventStream.listen(events.add);
    await Future<void>.delayed(Duration.zero);

    expect(events.single.sessionId, 'session-b');
    expect(events.single.scenario, Scenario.exitPressure);
    expect(events.single.stage, 3);
    expect(events.single.action, NotificationAction.missed);

    await subscription.cancel();
  });
}
