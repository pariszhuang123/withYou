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

    test('targets lib code for user-facing text lint outside l10n', () {
      expect(
        shouldLintUserFacingTextPath('C:/repo/lib/widgets/button.dart'),
        isTrue,
      );
      expect(
        shouldLintUserFacingTextPath(
          'C:/repo/lib/widgets/themed_components.dart',
        ),
        isTrue,
      );
      expect(
        shouldLintUserFacingTextPath('C:/repo/lib/services/router.dart'),
        isTrue,
      );
      expect(
        shouldLintUserFacingTextPath('C:/repo/lib/l10n/app_localizations.dart'),
        isFalse,
      );
      expect(
        shouldLintUserFacingTextPath('C:/repo/test/widgets/button_test.dart'),
        isFalse,
      );
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

    test('detects likely user-facing text and ignores punctuation-only values', () {
      expect(containsLikelyUserFacingText('Open settings'), isTrue);
      expect(containsLikelyUserFacingText('简体中文'), isTrue);
      expect(containsLikelyUserFacingText('...'), isFalse);
      expect(containsLikelyUserFacingText('00:15'), isFalse);
      expect(containsLikelyUserFacingText('assets/audio/system'), isTrue);
    });

    test('classifies user-facing text argument and parameter names', () {
      expect(isUserFacingTextConstructor('Text'), isTrue);
      expect(isUserFacingTextConstructor('Tooltip'), isFalse);
      expect(isUserFacingTextNamedArgument('semanticLabel'), isTrue);
      expect(isUserFacingTextNamedArgument('tooltip'), isTrue);
      expect(isUserFacingTextNamedArgument('value'), isFalse);
      expect(isUserFacingTextDefaultParameter('avatarLabel'), isTrue);
      expect(isUserFacingTextDefaultParameter('localeTag'), isFalse);
    });
  });
}
