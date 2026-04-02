import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/services/call_template_service.dart';
import 'package:with_you/theme/app_theme.dart';
import 'package:with_you/widgets/call_templates/call_template_renderer.dart';
import 'package:with_you/widgets/call_templates/call_template_widget.dart';

void main() {
  group('Call template goldens', () {
    const service = CallTemplateService();
    const boundaryKey = Key('call-template-golden-boundary');

    Future<void> pumpGolden(
      WidgetTester tester, {
      required ThemeData theme,
      required CallTemplateSpec spec,
      required CallScreenVisualState visualState,
      required String callerName,
      required Duration callDuration,
      required double textScale,
      TextDirection textDirection = TextDirection.ltr,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 932);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: const Size(430, 932),
            devicePixelRatio: 1,
            textScaler: TextScaler.linear(textScale),
            disableAnimations: true,
          ),
          child: MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Directionality(
                textDirection: textDirection,
                child: Center(
                  child: RepaintBoundary(
                    key: boundaryKey,
                    child: SizedBox(
                      width: 430,
                      height: 932,
                      child: CallTemplateRenderer(
                        spec: spec,
                        visualState: visualState,
                        callerName: callerName,
                        callDuration: callDuration,
                        onAccept: () {},
                        onDecline: () {},
                        onEnd: () {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
    }

    testWidgets('android ringing dark matches golden', (tester) async {
      await pumpGolden(
        tester,
        theme: AppTheme.dark(),
        spec: service.resolve(const Locale('en'), TargetPlatform.android),
        visualState: CallScreenVisualState.ringing,
        callerName: 'Jordan',
        callDuration: Duration.zero,
        textScale: 1,
      );

      await expectLater(
        find.byKey(boundaryKey),
        matchesGoldenFile('goldens/call_template_android_ringing_dark.png'),
      );
    });

    testWidgets('ios in-call dark matches golden', (tester) async {
      await pumpGolden(
        tester,
        theme: AppTheme.dark(),
        spec: service.resolve(const Locale('en'), TargetPlatform.iOS),
        visualState: CallScreenVisualState.inCall,
        callerName: 'Jordan',
        callDuration: const Duration(minutes: 2, seconds: 34),
        textScale: 1,
      );

      await expectLater(
        find.byKey(boundaryKey),
        matchesGoldenFile('goldens/call_template_ios_in_call_dark.png'),
      );
    });

    testWidgets('android ringing light large text matches golden', (
      tester,
    ) async {
      await pumpGolden(
        tester,
        theme: AppTheme.light(),
        spec: service.resolve(const Locale('zh', 'TW'), TargetPlatform.android),
        visualState: CallScreenVisualState.ringing,
        callerName: 'Jordan',
        callDuration: Duration.zero,
        textScale: 2,
      );

      await expectLater(
        find.byKey(boundaryKey),
        matchesGoldenFile(
          'goldens/call_template_android_ringing_light_large_text.png',
        ),
      );
    });

    testWidgets('ios in-call light large text matches golden', (tester) async {
      await pumpGolden(
        tester,
        theme: AppTheme.light(),
        spec: service.resolve(const Locale('en'), TargetPlatform.iOS),
        visualState: CallScreenVisualState.inCall,
        callerName: 'Jordan',
        callDuration: const Duration(minutes: 2, seconds: 34),
        textScale: 2,
      );

      await expectLater(
        find.byKey(boundaryKey),
        matchesGoldenFile(
          'goldens/call_template_ios_in_call_light_large_text.png',
        ),
      );
    });

    testWidgets('android in-call rtl locale expansion matches golden', (
      tester,
    ) async {
      const spec = CallTemplateSpec(
        template: CallTemplate.androidNative,
        layout: CallTemplateLayout.androidInCallTopAligned,
        palette: CallTemplatePalette(
          ringingBackground: Color(0xFF101417),
          inCallBackground: Color(0xFF101417),
          acceptAction: Color(0xFF4CAF50),
          declineAction: Color(0xFFF44336),
          textPrimary: Color(0xFFF1F4F6),
          textSecondary: Color(0xFFC5CCD2),
        ),
        ringingScreenIsDark: true,
        inCallScreenIsDark: true,
        supportsAvatarPulse: true,
        localizedVoiceCallLabel: 'مكالمة دعم السلامة الواردة',
        displayOnlyControls: <String>[
          'عنصر واجهة عرض فقط',
          'معلومات موسعة للحالة',
        ],
      );

      await pumpGolden(
        tester,
        theme: AppTheme.dark(),
        spec: spec,
        visualState: CallScreenVisualState.inCall,
        callerName: 'خدمة الدعم الآمنة الممتدة',
        callDuration: const Duration(minutes: 8, seconds: 9),
        textScale: 1.3,
        textDirection: TextDirection.rtl,
      );

      await expectLater(
        find.byKey(boundaryKey),
        matchesGoldenFile(
          'goldens/call_template_android_in_call_rtl_expanded.png',
        ),
      );
    });
  });
}
