import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_template_contract.dart';
import 'package:with_you/services/call_template_service.dart';

void main() {
  group('CallTemplateService', () {
    const service = CallTemplateService();

    test('resolves mainland Chinese locales to WeChat-style', () {
      final spec = service.resolve(
        const Locale('zh', 'CN'),
        TargetPlatform.android,
      );

      expect(spec.template, CallTemplate.wechatStyle);
      expect(spec.ringingScreenIsDark, isTrue);
      expect(spec.displayOnlyControls, isEmpty);
    });

    test('resolves Taiwan and Japanese locales to LINE-style', () {
      final taiwanSpec = service.resolve(
        const Locale('zh', 'TW'),
        TargetPlatform.android,
      );
      final japanSpec = service.resolve(const Locale('ja'), TargetPlatform.iOS);

      expect(taiwanSpec.template, CallTemplate.lineStyle);
      expect(taiwanSpec.ringingScreenIsDark, isFalse);
      expect(japanSpec.template, CallTemplate.lineStyle);
    });

    test('resolves Hong Kong locales to WhatsApp-style', () {
      final spec = service.resolve(
        const Locale('zh', 'HK'),
        TargetPlatform.android,
      );

      expect(spec.template, CallTemplate.whatsappStyle);
      expect(spec.palette.acceptAction, const Color(0xFF25D366));
    });

    test('falls back to iOS native for iOS and macOS', () {
      final iosSpec = service.resolve(const Locale('en'), TargetPlatform.iOS);
      final macSpec = service.resolve(const Locale('en'), TargetPlatform.macOS);

      expect(iosSpec.template, CallTemplate.iosNative);
      expect(macSpec.template, CallTemplate.iosNative);
      expect(iosSpec.layout, CallTemplateLayout.iosIncoming);
    });

    test('falls back to Android native for other locales on Android', () {
      final spec = service.resolve(const Locale('ko'), TargetPlatform.android);

      expect(spec.template, CallTemplate.androidNative);
      expect(spec.layout, CallTemplateLayout.androidInCallTopAligned);
      expect(spec.localizedVoiceCallLabel, 'Incoming call');
    });
  });
}
