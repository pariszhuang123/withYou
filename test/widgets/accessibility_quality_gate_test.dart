import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/services/call_template_service.dart';
import 'package:with_you/theme/app_theme.dart';
import 'package:with_you/widgets/call_templates/call_template_renderer.dart';
import 'package:with_you/widgets/call_templates/call_template_widget.dart';
import 'package:with_you/widgets/themed_components.dart';

void main() {
  group('Accessibility quality gate', () {
    const service = CallTemplateService();

    Future<void> prepareViewport(WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 932);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
    }

    testWidgets('ringing actions declare deterministic focus order', (
      tester,
    ) async {
      await prepareViewport(tester);
      final spec = service.resolve(const Locale('en'), TargetPlatform.android);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: CallTemplateRenderer(
                spec: spec,
                visualState: CallScreenVisualState.ringing,
                callerName: 'Jordan',
                callDuration: Duration.zero,
                onAccept: () {},
                onDecline: () {},
                onEnd: () {},
              ),
            ),
          ),
        ),
      );

      final orders = tester.widgetList<FocusTraversalOrder>(
        find.byType(FocusTraversalOrder),
      );

      expect(orders, hasLength(2));

      final declineOrder = orders.first.order as NumericFocusOrder;
      final acceptOrder = orders.last.order as NumericFocusOrder;

      expect(declineOrder.order, 1);
      expect(acceptOrder.order, 2);
      expect(find.bySemanticsLabel('Decline support call'), findsOneWidget);
      expect(find.bySemanticsLabel('Accept support call'), findsOneWidget);
    });

    testWidgets('reduced motion collapses avatar animation duration to zero', (
      tester,
    ) async {
      await prepareViewport(tester);
      final spec = service.resolve(
        const Locale('zh', 'CN'),
        TargetPlatform.android,
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: Scaffold(
              body: CallTemplateRenderer(
                spec: spec,
                visualState: CallScreenVisualState.ringing,
                callerName: 'Jordan',
                callDuration: Duration.zero,
                onAccept: () {},
                onDecline: () {},
                onEnd: () {},
              ),
            ),
          ),
        ),
      );

      final animatedScale = tester.widget<AnimatedScale>(
        find.byType(AnimatedScale),
      );

      expect(animatedScale.duration, Duration.zero);
    });

    testWidgets('interactive design-system components expose semantics', (
      tester,
    ) async {
      await prepareViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Column(
              children: [
                ThemedButton(
                  onPressed: () {},
                  semanticLabel: 'Start support call',
                  child: const Text('Start'),
                ),
                ThemedIconButton(
                  icon: Icons.download_outlined,
                  semanticLabel: 'Download language pack',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Start support call'), findsOneWidget);
      expect(find.bySemanticsLabel('Download language pack'), findsOneWidget);
    });

    testWidgets('rtl layout preserves critical actions and alignment', (
      tester,
    ) async {
      await prepareViewport(tester);
      final spec = service.resolve(const Locale('ar'), TargetPlatform.android);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: CallTemplateRenderer(
                spec: spec,
                visualState: CallScreenVisualState.inCall,
                callerName: 'خدمة الدعم الآمنة',
                callDuration: const Duration(minutes: 1, seconds: 12),
                onAccept: () {},
                onDecline: () {},
                onEnd: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('End support call'), findsOneWidget);

      final callerPosition = tester.getTopRight(find.text('خدمة الدعم الآمنة'));
      expect(callerPosition.dx, greaterThan(215));
    });

    testWidgets('expanded localized strings stay readable without overflow', (
      tester,
    ) async {
      await prepareViewport(tester);
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
        localizedVoiceCallLabel:
            'Incoming safety support call with extended localized status copy',
        displayOnlyControls: <String>[
          'Optional display-only chrome label that is intentionally long',
        ],
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: CallTemplateRenderer(
                spec: spec,
                visualState: CallScreenVisualState.ringing,
                callerName: 'Alexandria Support Coordination',
                callDuration: Duration.zero,
                onAccept: () {},
                onDecline: () {},
                onEnd: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Accept support call'), findsOneWidget);
      expect(find.bySemanticsLabel('Decline support call'), findsOneWidget);
    });
  });
}
