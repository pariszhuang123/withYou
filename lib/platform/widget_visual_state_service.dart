import 'package:flutter/services.dart';

import '../contracts/platform_contracts.dart';

class WidgetVisualStateService implements WidgetVisualStateContract {
  WidgetVisualStateService({MethodChannel? methodChannel})
    : _methodChannel =
          methodChannel ??
          const MethodChannel('with_you/widget_visual_state/methods');

  final MethodChannel _methodChannel;

  @override
  Future<void> syncPremiumAccess({required bool isActive}) async {
    await _methodChannel.invokeMethod<void>('syncPremiumAccess', <String, bool>{
      'isActive': isActive,
    });
  }
}
