import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/theme/app_theme.dart';
import 'package:with_you/theme/design_tokens.dart';
import 'package:with_you/widgets/themed_components.dart';

void main() {
  group('ThemedButton', () {
    testWidgets('uses explicit home trigger size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: ThemedButton(
              onPressed: () {},
              semanticLabel: 'Start support call',
              size: ThemedButtonSize.homeTrigger,
              child: const Text('Start'),
            ),
          ),
        ),
      );

      final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
      expect(
        button.style?.minimumSize?.resolve({}),
        Size.square(AppComponentSizeTokens.base.homeTriggerSize),
      );
    });

    testWidgets('uses larger call action size for stressful interactions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: ThemedButton(
              onPressed: () {},
              semanticLabel: 'Accept call',
              size: ThemedButtonSize.callAction,
              child: const Icon(Icons.call),
            ),
          ),
        ),
      );

      final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
      expect(
        button.style?.minimumSize?.resolve({}),
        Size.square(AppComponentSizeTokens.base.callActionSize),
      );
    });

    testWidgets('exposes semantics for actionable controls', (tester) async {
      final semantics = tester.ensureSemantics();

      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: ThemedButton(
                onPressed: () {},
                semanticLabel: 'Start support call',
                child: const Text('Start'),
              ),
            ),
          ),
        );

        expect(find.bySemanticsLabel('Start support call'), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('respects large text scales without overflow', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: Center(
                child: ThemedButton(
                  onPressed: () {},
                  semanticLabel: 'Start support call',
                  child: const Text('Start support call'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Start support call'), findsOneWidget);
    });
  });

  group('ThemedHeroActionButton', () {
    testWidgets('expands to a larger hero-sized primary action', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: ThemedHeroActionButton(
              onPressed: () {},
              semanticLabel: 'Start selected support call',
              icon: Icons.call,
              title: 'Start support call',
              subtitle: 'Start the gentle one-call support flow.',
            ),
          ),
        ),
      );

      final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
      expect(
        button.style?.minimumSize?.resolve({}),
        Size(
          double.infinity,
          AppComponentSizeTokens.base.homeTriggerSize * 2.4,
        ),
      );
      expect(
        find.bySemanticsLabel('Start selected support call'),
        findsOneWidget,
      );
    });
  });

  group('ThemedCard', () {
    testWidgets('uses tokenized surface and spacing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: ThemedCard(
              child: Builder(
                builder: (context) =>
                    Text(Theme.of(context).appColors.textPrimary.toString()),
              ),
            ),
          ),
        ),
      );

      final Card card = tester.widget(find.byType(Card));
      expect(card.color, AppColorTokens.light.surfaceSecondary);
      final RoundedRectangleBorder shape =
          card.shape! as RoundedRectangleBorder;
      expect(
        shape.borderRadius,
        BorderRadius.circular(AppComponentSizeTokens.base.cardRadius),
      );

      final Padding padding = tester.widget(
        find.descendant(
          of: find.byType(ThemedCard),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Padding &&
                widget.padding == EdgeInsets.all(AppSpacingTokens.base.medium),
          ),
        ),
      );
      expect(padding.padding, EdgeInsets.all(AppSpacingTokens.base.medium));
    });
  });

  group('ThemedSurfacePanel', () {
    testWidgets('uses tokenized border and radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: ThemedSurfacePanel(child: Text('Panel'))),
        ),
      );

      final DecoratedBox decoratedBox = tester.widget(
        find.byType(DecoratedBox),
      );
      final BoxDecoration decoration = decoratedBox.decoration as BoxDecoration;

      expect(decoration.color, AppColorTokens.light.surfaceCritical);
      expect(
        decoration.borderRadius,
        BorderRadius.circular(AppComponentSizeTokens.base.cornerRadius),
      );
      expect(decoration.border?.top.color, AppColorTokens.light.borderSubtle);
    });
  });

  group('AppLogo', () {
    testWidgets('renders with default size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: AppLogo(size: 64)),
        ),
      );

      final SizedBox sizedBox = tester.widget(
        find.descendant(
          of: find.byType(AppLogo),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SizedBox && widget.width == 64 && widget.height == 64,
          ),
        ),
      );
      expect(sizedBox.width, 64);
      expect(sizedBox.height, 64);
    });

    testWidgets('renders without animation by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: AppLogo(size: 64)),
        ),
      );

      expect(find.byType(AnimatedScale), findsNothing);
      expect(find.bySemanticsLabel('withYou app logo'), findsOneWidget);
    });

    testWidgets('renders with pulsing animation when animated=true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: AppLogo(size: 64, animated: true)),
        ),
      );

      expect(find.byType(AnimatedScale), findsOneWidget);
      final AnimatedScale animatedScale = tester.widget(
        find.byType(AnimatedScale),
      );
      expect(animatedScale.scale, 1.03);
      expect(animatedScale.duration, AppMotionTokens.base.avatarPulse);
    });

    testWidgets('supports large text scales without overflow', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(body: AppLogo(size: 64)),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('CallActionButton', () {
    testWidgets('shows label by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: CallActionButton(
              label: 'Accept',
              semanticLabel: 'Accept support call',
              icon: Icons.call,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              onPressed: () {},
              focusOrder: 1,
            ),
          ),
        ),
      );

      expect(find.text('Accept'), findsOneWidget);
      expect(find.bySemanticsLabel('Accept support call'), findsOneWidget);
    });

    testWidgets('hides label when showLabel=false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: CallActionButton(
              label: 'Dial',
              semanticLabel: 'Accept support call - dial',
              icon: Icons.call,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              onPressed: () {},
              focusOrder: 1,
              showLabel: false,
            ),
          ),
        ),
      );

      expect(find.text('Dial'), findsNothing);
      expect(
        find.bySemanticsLabel('Accept support call - dial'),
        findsOneWidget,
      );
    });

    testWidgets('uses call action size from design tokens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: CallActionButton(
              label: 'Accept',
              semanticLabel: 'Accept support call',
              icon: Icons.call,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              onPressed: () {},
              focusOrder: 1,
            ),
          ),
        ),
      );

      final SizedBox sizedBox = tester.widget(
        find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox &&
              widget.width == AppComponentSizeTokens.base.callActionSize,
        ),
      );
      expect(sizedBox.width, AppComponentSizeTokens.base.callActionSize);
      expect(sizedBox.height, AppComponentSizeTokens.base.callActionSize);
    });

    testWidgets('respects focus order', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Column(
              children: [
                CallActionButton(
                  label: 'Dial',
                  semanticLabel: 'Dial',
                  icon: Icons.call,
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  onPressed: () {},
                  focusOrder: 1,
                ),
                CallActionButton(
                  label: 'Hang',
                  semanticLabel: 'Hang',
                  icon: Icons.call_end,
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  onPressed: () {},
                  focusOrder: 2,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FocusTraversalOrder), findsWidgets);
    });
  });
}
