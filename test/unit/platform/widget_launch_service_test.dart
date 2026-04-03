import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/contracts/platform_contracts.dart';
import 'package:with_you/platform/widget_launch_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const eventChannel = EventChannel('test/widget_launch/events');

  test('eventStream maps widget payloads into launch events', () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const codec = StandardMethodCodec();

    messenger.setMockMessageHandler(eventChannel.name, (message) async {
      final call = codec.decodeMethodCall(message);
      if (call.method == 'listen') {
        return codec.encodeSuccessEnvelope(null);
      }
      return null;
    });

    final service = WidgetLaunchPlatformService(eventChannel: eventChannel);
    final events = <WidgetLaunchEvent>[];
    final subscription = service.eventStream.listen(events.add);

    await messenger.handlePlatformMessage(
      eventChannel.name,
      const StandardMethodCodec().encodeSuccessEnvelope({
        'scenario': 'socialPull',
      }),
      (_) {},
    );
    await Future<void>.delayed(Duration.zero);

    expect(events.single.scenario, Scenario.socialPull);

    await subscription.cancel();
    messenger.setMockMessageHandler(eventChannel.name, null);
  });

  test('eventStream treats unknown scenario payloads as null', () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const codec = StandardMethodCodec();

    messenger.setMockMessageHandler(eventChannel.name, (message) async {
      final call = codec.decodeMethodCall(message);
      if (call.method == 'listen') {
        return codec.encodeSuccessEnvelope(null);
      }
      return null;
    });

    final service = WidgetLaunchPlatformService(eventChannel: eventChannel);
    final events = <WidgetLaunchEvent>[];
    final subscription = service.eventStream.listen(events.add);

    await messenger.handlePlatformMessage(
      eventChannel.name,
      const StandardMethodCodec().encodeSuccessEnvelope({
        'scenario': 'not_a_real_scenario',
      }),
      (_) {},
    );
    await Future<void>.delayed(Duration.zero);

    expect(events.single.scenario, isNull);

    await subscription.cancel();
    messenger.setMockMessageHandler(eventChannel.name, null);
  });
}
