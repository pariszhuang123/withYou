import 'package:flutter/material.dart';

import '../../contracts/call_flow_contracts.dart';
import 'android_native_call_template.dart';
import 'call_template_widget.dart';
import 'ios_native_call_template.dart';
import 'line_call_template.dart';
import 'wechat_call_template.dart';
import 'whatsapp_call_template.dart';

class CallTemplateRenderer extends StatelessWidget {
  const CallTemplateRenderer({
    required this.spec,
    required this.visualState,
    required this.callerName,
    required this.callDuration,
    required this.onAccept,
    required this.onDecline,
    required this.onEnd,
    super.key,
  });

  final CallTemplateSpec spec;
  final CallScreenVisualState visualState;
  final String callerName;
  final Duration callDuration;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return switch (spec.template) {
      CallTemplate.wechatStyle => WechatCallTemplate(
        spec: spec,
        visualState: visualState,
        callerName: callerName,
        callDuration: callDuration,
        onAccept: onAccept,
        onDecline: onDecline,
        onEnd: onEnd,
      ),
      CallTemplate.lineStyle => LineCallTemplate(
        spec: spec,
        visualState: visualState,
        callerName: callerName,
        callDuration: callDuration,
        onAccept: onAccept,
        onDecline: onDecline,
        onEnd: onEnd,
      ),
      CallTemplate.whatsappStyle => WhatsappCallTemplate(
        spec: spec,
        visualState: visualState,
        callerName: callerName,
        callDuration: callDuration,
        onAccept: onAccept,
        onDecline: onDecline,
        onEnd: onEnd,
      ),
      CallTemplate.iosNative => IosNativeCallTemplate(
        spec: spec,
        visualState: visualState,
        callerName: callerName,
        callDuration: callDuration,
        onAccept: onAccept,
        onDecline: onDecline,
        onEnd: onEnd,
      ),
      CallTemplate.androidNative => AndroidNativeCallTemplate(
        spec: spec,
        visualState: visualState,
        callerName: callerName,
        callDuration: callDuration,
        onAccept: onAccept,
        onDecline: onDecline,
        onEnd: onEnd,
      ),
    };
  }
}
