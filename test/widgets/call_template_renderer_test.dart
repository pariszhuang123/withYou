import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/services/call_template_service.dart';
import 'package:with_you/theme/app_theme.dart';
import 'package:with_you/widgets/call_templates/call_template_renderer.dart';
import 'package:with_you/widgets/call_templates/call_template_widget.dart';

void main() {
  group('CallTemplateRenderer', () {
    const service = CallTemplateService();

    testWidgets('renders ringing actions with required semantics and sizing', (
      tester,
    ) async {
      final spec = service.resolve(
        const Locale('zh', 'CN'),
        TargetPlatform.android,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: CallTemplateRenderer(
              spec: spec,
              visualState: CallScreenVisualState.ringing,
              callerName: 'Xiao Chen',
              callDuration: Duration.zero,
              onAccept: () {},
              onDecline: () {},
              onEnd: () {},
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Accept support call'), findsOneWidget);
      expect(find.bySemanticsLabel('Decline support call'), findsOneWidget);
      expect(find.bySemanticsLabel('End support call'), findsNothing);

      final buttons = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      for (final button in buttons) {
        expect(button.style?.minimumSize?.resolve({}), const Size.square(72));
      }
    });

    testWidgets('renders in-call end action only', (tester) async {
      final spec = service.resolve(const Locale('en'), TargetPlatform.iOS);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: CallTemplateRenderer(
              spec: spec,
              visualState: CallScreenVisualState.inCall,
              callerName: 'Xiao Chen',
              callDuration: const Duration(minutes: 2, seconds: 34),
              onAccept: () {},
              onDecline: () {},
              onEnd: () {},
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Accept support call'), findsNothing);
      expect(find.bySemanticsLabel('Decline support call'), findsNothing);
      expect(find.bySemanticsLabel('End support call'), findsOneWidget);
      expect(find.text('02:34'), findsOneWidget);
    });

    testWidgets('android in-call layout top-aligns caller identity', (
      tester,
    ) async {
      final spec = service.resolve(const Locale('ko'), TargetPlatform.android);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: CallTemplateRenderer(
              spec: spec,
              visualState: CallScreenVisualState.inCall,
              callerName: 'Xiao Chen',
              callDuration: const Duration(seconds: 45),
              onAccept: () {},
              onDecline: () {},
              onEnd: () {},
            ),
          ),
        ),
      );

      final nameTopLeft = tester.getTopLeft(find.text('Xiao Chen'));
      final endButtonTopLeft = tester.getTopLeft(
        find.bySemanticsLabel('End support call'),
      );

      expect(nameTopLeft.dy, lessThan(endButtonTopLeft.dy));
    });

    testWidgets('display-only controls stay out of semantics', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      try {
        const spec = CallTemplateSpec(
          template: CallTemplate.iosNative,
          layout: CallTemplateLayout.iosIncoming,
          palette: CallTemplatePalette(
            ringingBackground: Color(0xFF101417),
            inCallBackground: Color(0xFF101417),
            acceptAction: Color(0xFF34C759),
            declineAction: Color(0xFFFF3B30),
            textPrimary: Color(0xFFF1F4F6),
            textSecondary: Color(0xFFC5CCD2),
          ),
          ringingScreenIsDark: true,
          inCallScreenIsDark: true,
          supportsAvatarPulse: true,
          localizedVoiceCallLabel: 'Mobile',
          displayOnlyControls: <String>['Remind Me', 'Message'],
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark(),
            home: Scaffold(
              body: CallTemplateRenderer(
                spec: spec,
                visualState: CallScreenVisualState.ringing,
                callerName: 'Xiao Chen',
                callDuration: Duration.zero,
                onAccept: () {},
                onDecline: () {},
                onEnd: () {},
              ),
            ),
          ),
        );

        expect(find.text('Remind Me'), findsOneWidget);
        expect(find.text('Message'), findsOneWidget);
        expect(find.bySemanticsLabel('Remind Me'), findsNothing);
        expect(find.bySemanticsLabel('Message'), findsNothing);
      } finally {
        semanticsHandle.dispose();
      }
    });

    testWidgets('supports large text scale without overflow', (tester) async {
      final spec = service.resolve(
        const Locale('zh', 'TW'),
        TargetPlatform.android,
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: CallTemplateRenderer(
                spec: spec,
                visualState: CallScreenVisualState.ringing,
                callerName: 'Xiao Chen',
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
    });
  });
}
