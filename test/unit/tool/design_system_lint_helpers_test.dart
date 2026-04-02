import 'package:flutter_test/flutter_test.dart';
import 'package:with_you_custom_lints/src/design_system_lint_helpers.dart';

void main() {
  group('design system lint helpers', () {
    test('targets widgets and screens outside theme and l10n', () {
      expect(
        shouldLintPresentationPath('C:/repo/lib/widgets/button.dart'),
        isTrue,
      );
      expect(
        shouldLintPresentationPath('C:/repo/lib/screens/home_screen.dart'),
        isTrue,
      );
      expect(
        shouldLintPresentationPath('C:/repo/lib/theme/app_theme.dart'),
        isFalse,
      );
      expect(
        shouldLintPresentationPath('C:/repo/lib/l10n/app_localizations.dart'),
        isFalse,
      );
      expect(
        shouldLintPresentationPath('C:/repo/test/widgets/button_test.dart'),
        isFalse,
      );
      expect(
        shouldLintPresentationPath(
          'C:/repo/lib/widgets/themed_components.dart',
        ),
        isFalse,
      );
      expect(shouldLintPresentationPath('C:/repo/lib/app.dart'), isTrue);
    });

    test('classifies raw tappable controls and semantic-label widgets', () {
      expect(isRawTappableControlType('IconButton'), isTrue);
      expect(isRawTappableControlType('GestureDetector'), isTrue);
      expect(isRawTappableControlType('ThemedButton'), isFalse);
      expect(isRawDecorationType('BoxDecoration'), isTrue);
      expect(isRawDecorationType('BorderSide'), isTrue);
      expect(isRawDecorationType('Chip'), isFalse);
      expect(isTypographyStyleConstructor('TextStyle'), isTrue);
      expect(isTypographyStyleConstructor('ChipThemeData'), isFalse);

      expect(requiresSemanticLabel('ThemedButton'), isTrue);
      expect(requiresSemanticLabel('ThemedIconButton'), isTrue);
      expect(requiresSemanticLabel('CallActionButton'), isFalse);
    });
  });
}
