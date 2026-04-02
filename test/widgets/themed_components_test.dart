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
          home: const Scaffold(
            body: ThemedSurfacePanel(child: Text('Panel')),
          ),
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
}
