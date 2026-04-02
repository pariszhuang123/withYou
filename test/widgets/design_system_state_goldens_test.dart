import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/theme/app_theme.dart';
import 'package:with_you/theme/design_tokens.dart';
import 'package:with_you/widgets/themed_components.dart';

void main() {
  group('Design system state goldens', () {
    const boundaryKey = Key('design-system-state-boundary');

    Future<void> pumpStateGolden(
      WidgetTester tester, {
      required ThemeData theme,
      required Widget child,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 932);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: boundaryKey,
                child: SizedBox(width: 430, height: 932, child: child),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
    }

    testWidgets('disabled action state matches golden', (tester) async {
      await pumpStateGolden(
        tester,
        theme: AppTheme.light(),
        child: const Center(
          child: ThemedButton(
            onPressed: null,
            semanticLabel: 'Start support call',
            size: ThemedButtonSize.homeTrigger,
            child: Text('Start support call'),
          ),
        ),
      );

      await expectLater(
        find.byKey(boundaryKey),
        matchesGoldenFile('goldens/design_system_disabled_action.png'),
      );
    });

    testWidgets('loading surface state matches golden', (tester) async {
      await pumpStateGolden(
        tester,
        theme: AppTheme.light(),
        child: Center(
          child: SizedBox(
            width: 320,
            child: ThemedSurfacePanel(
              child: Builder(
                builder: (context) {
                  final spacing = Theme.of(context).appSpacing;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preparing offline support audio',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: spacing.small),
                      Row(
                        children: [
                          const CircularProgressIndicator(),
                          SizedBox(width: spacing.medium),
                          Expanded(
                            child: Text(
                              'Downloading the selected language pack for future emergency use.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byKey(boundaryKey),
        matchesGoldenFile('goldens/design_system_loading_surface.png'),
      );
    });

    testWidgets('error surface state matches golden', (tester) async {
      await pumpStateGolden(
        tester,
        theme: AppTheme.dark(),
        child: Center(
          child: SizedBox(
            width: 320,
            child: ThemedSurfacePanel(
              backgroundColor: AppColorTokens.dark.surfaceCritical,
              child: Builder(
                builder: (context) {
                  final spacing = Theme.of(context).appSpacing;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Download failed',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: spacing.small),
                      Text(
                        'Offline audio is not ready yet. Retry before relying on this language pack.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: spacing.medium),
                      ThemedButton(
                        onPressed: () {},
                        semanticLabel: 'Retry language pack download',
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byKey(boundaryKey),
        matchesGoldenFile('goldens/design_system_error_surface.png'),
      );
    });
  });
}
