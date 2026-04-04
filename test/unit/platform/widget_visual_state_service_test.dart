import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/platform/widget_visual_state_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('test/widget_visual_state/methods');
  final methodCalls = <MethodCall>[];

  setUp(() {
    methodCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (call) async {
          methodCalls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  test(
    'syncPremiumAccess forwards premium state to the native bridge',
    () async {
      final service = WidgetVisualStateService(methodChannel: methodChannel);

      await service.syncPremiumAccess(isActive: true);

      expect(methodCalls.single.method, 'syncPremiumAccess');
      expect(methodCalls.single.arguments, <String, bool>{'isActive': true});
    },
  );
}
