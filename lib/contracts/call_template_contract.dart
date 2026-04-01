import 'package:flutter/material.dart';

enum CallTemplate {
  wechatStyle,
  lineStyle,
  whatsappStyle,
  iosNative,
  androidNative,
}

enum CallTemplateLayout {
  centeredIncoming,
  iosIncoming,
  androidInCallTopAligned,
}

@immutable
class CallTemplatePalette {
  const CallTemplatePalette({
    required this.ringingBackground,
    required this.inCallBackground,
    required this.acceptAction,
    required this.declineAction,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color ringingBackground;
  final Color inCallBackground;
  final Color acceptAction;
  final Color declineAction;
  final Color textPrimary;
  final Color textSecondary;
}

@immutable
class CallTemplateSpec {
  const CallTemplateSpec({
    required this.template,
    required this.layout,
    required this.palette,
    required this.ringingScreenIsDark,
    required this.inCallScreenIsDark,
    required this.supportsAvatarPulse,
    required this.localizedVoiceCallLabel,
    required this.displayOnlyControls,
  });

  final CallTemplate template;
  final CallTemplateLayout layout;
  final CallTemplatePalette palette;
  final bool ringingScreenIsDark;
  final bool inCallScreenIsDark;
  final bool supportsAvatarPulse;
  final String localizedVoiceCallLabel;
  final List<String> displayOnlyControls;
}

abstract class CallTemplateContract {
  CallTemplateSpec resolve(Locale locale, TargetPlatform platform);
}
