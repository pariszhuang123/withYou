import 'package:flutter/material.dart';

import '../contracts/call_flow_contracts.dart';

class CallTemplateService implements CallTemplateContract {
  const CallTemplateService();

  static const CallTemplatePalette _wechatPalette = CallTemplatePalette(
    ringingBackground: Color(0xFF101417),
    inCallBackground: Color(0xFF101417),
    acceptAction: Color(0xFF07C160),
    declineAction: Color(0xFFF44336),
    textPrimary: Color(0xFFF1F4F6),
    textSecondary: Color(0xFFC5CCD2),
  );

  static const CallTemplatePalette _linePalette = CallTemplatePalette(
    ringingBackground: Color(0xFFF7FAF7),
    inCallBackground: Color(0xFF101417),
    acceptAction: Color(0xFF06C755),
    declineAction: Color(0xFFB3261E),
    textPrimary: Color(0xFFF1F4F6),
    textSecondary: Color(0xFFC5CCD2),
  );

  static const CallTemplatePalette _whatsappPalette = CallTemplatePalette(
    ringingBackground: Color(0xFF13252C),
    inCallBackground: Color(0xFF13252C),
    acceptAction: Color(0xFF25D366),
    declineAction: Color(0xFFF44336),
    textPrimary: Color(0xFFF1F4F6),
    textSecondary: Color(0xFFC5CCD2),
  );

  static const CallTemplatePalette _iosPalette = CallTemplatePalette(
    ringingBackground: Color(0xFF1D2328),
    inCallBackground: Color(0xFF101417),
    acceptAction: Color(0xFF34C759),
    declineAction: Color(0xFFFF3B30),
    textPrimary: Color(0xFFF1F4F6),
    textSecondary: Color(0xFFC5CCD2),
  );

  static const CallTemplatePalette _androidPalette = CallTemplatePalette(
    ringingBackground: Color(0xFF101417),
    inCallBackground: Color(0xFF101417),
    acceptAction: Color(0xFF4CAF50),
    declineAction: Color(0xFFF44336),
    textPrimary: Color(0xFFF1F4F6),
    textSecondary: Color(0xFFC5CCD2),
  );

  @override
  CallTemplateSpec resolve(Locale locale, TargetPlatform platform) {
    final countryCode = locale.countryCode?.toUpperCase();
    final languageCode = locale.languageCode.toLowerCase();

    if (countryCode == 'CN' || (countryCode == null && languageCode == 'zh')) {
      return const CallTemplateSpec(
        template: CallTemplate.wechatStyle,
        layout: CallTemplateLayout.centeredIncoming,
        palette: _wechatPalette,
        ringingScreenIsDark: true,
        inCallScreenIsDark: true,
        supportsAvatarPulse: true,
        localizedVoiceCallLabel: 'Voice call',
        displayOnlyControls: <String>[],
      );
    }

    if (countryCode == 'TW' || languageCode == 'ja') {
      return const CallTemplateSpec(
        template: CallTemplate.lineStyle,
        layout: CallTemplateLayout.centeredIncoming,
        palette: _linePalette,
        ringingScreenIsDark: false,
        inCallScreenIsDark: true,
        supportsAvatarPulse: true,
        localizedVoiceCallLabel: 'Voice call',
        displayOnlyControls: <String>[],
      );
    }

    if (countryCode == 'HK') {
      return const CallTemplateSpec(
        template: CallTemplate.whatsappStyle,
        layout: CallTemplateLayout.centeredIncoming,
        palette: _whatsappPalette,
        ringingScreenIsDark: true,
        inCallScreenIsDark: true,
        supportsAvatarPulse: true,
        localizedVoiceCallLabel: 'Voice call',
        displayOnlyControls: <String>[],
      );
    }

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return const CallTemplateSpec(
        template: CallTemplate.iosNative,
        layout: CallTemplateLayout.iosIncoming,
        palette: _iosPalette,
        ringingScreenIsDark: true,
        inCallScreenIsDark: true,
        supportsAvatarPulse: true,
        localizedVoiceCallLabel: 'Mobile',
        displayOnlyControls: <String>[],
      );
    }

    return const CallTemplateSpec(
      template: CallTemplate.androidNative,
      layout: CallTemplateLayout.androidInCallTopAligned,
      palette: _androidPalette,
      ringingScreenIsDark: true,
      inCallScreenIsDark: true,
      supportsAvatarPulse: true,
      localizedVoiceCallLabel: 'Incoming call',
      displayOnlyControls: <String>[],
    );
  }
}
