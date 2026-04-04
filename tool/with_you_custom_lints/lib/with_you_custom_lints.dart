import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/design_system_lint_helpers.dart';

PluginBase createPlugin() => _WithYouCustomLintsPlugin();

class _WithYouCustomLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    return const <LintRule>[
      AvoidRawColorInPresentationRule(),
      AvoidRawSpacingInPresentationRule(),
      AvoidRawBorderRadiusInPresentationRule(),
      AvoidRawDecorationInPresentationRule(),
      AvoidRawTypographyStylesInPresentationRule(),
      AvoidRawIconSizeInPresentationRule(),
      AvoidRawUserFacingTextRule(),
      RequireSemanticLabelOnAppInteractiveWidgetsRule(),
      AvoidRawTappableControlsWithoutTokenConstraintsRule(),
    ];
  }
}

class AvoidRawColorInPresentationRule extends DartLintRule {
  const AvoidRawColorInPresentationRule() : super(code: _rawColorCode);

  static const _rawColorCode = LintCode(
    name: 'avoid_raw_color_in_presentation',
    problemMessage:
        'Do not use raw colors in presentation code. Read colors from ThemeData or design tokens.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (!shouldLintPresentationPath(resolver.path)) {
      return;
    }

    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name.lexeme;
      if (typeName == 'Color') {
        reporter.atNode(node, code);
      }
    });

    context.registry.addPrefixedIdentifier((node) {
      if (node.prefix.name == 'Colors') {
        reporter.atNode(node, code);
      }
    });
  }
}

class AvoidRawSpacingInPresentationRule extends DartLintRule {
  const AvoidRawSpacingInPresentationRule() : super(code: _rawSpacingCode);

  static const _rawSpacingCode = LintCode(
    name: 'avoid_raw_spacing_in_presentation',
    problemMessage:
        'Do not hardcode spacing in presentation code. Read spacing from theme tokens.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (!shouldLintPresentationPath(resolver.path)) {
      return;
    }

    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name.lexeme;

      if (typeName == 'EdgeInsets' && hasLiteralSpacingArgument(node)) {
        reporter.atNode(node, code);
      }

      if (typeName == 'SizedBox' && hasLiteralSizedBoxDimension(node)) {
        reporter.atNode(node, code);
      }
    });
  }
}

class RequireSemanticLabelOnAppInteractiveWidgetsRule extends DartLintRule {
  const RequireSemanticLabelOnAppInteractiveWidgetsRule()
    : super(code: _semanticLabelCode);

  static const _semanticLabelCode = LintCode(
    name: 'require_semantic_label_on_app_interactive_widgets',
    problemMessage:
        'App-defined interactive widgets must provide a semanticLabel.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (!shouldLintPresentationPath(resolver.path)) {
      return;
    }

    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name.lexeme;
      if (!requiresSemanticLabel(typeName)) {
        return;
      }

      if (!hasNamedArgument(node, 'semanticLabel')) {
        reporter.atNode(node, code);
      }
    });
  }
}

class AvoidRawBorderRadiusInPresentationRule extends DartLintRule {
  const AvoidRawBorderRadiusInPresentationRule()
    : super(code: _rawBorderRadiusCode);

  static const _rawBorderRadiusCode = LintCode(
    name: 'avoid_raw_border_radius_in_presentation',
    problemMessage:
        'Do not hardcode border radii in presentation code. Read radius values from component tokens or design-system primitives.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (!shouldLintPresentationPath(resolver.path)) {
      return;
    }

    context.registry.addInstanceCreationExpression((node) {
      if (hasLiteralBorderRadiusArgument(node)) {
        reporter.atNode(node, code);
      }
    });
  }
}

class AvoidRawDecorationInPresentationRule extends DartLintRule {
  const AvoidRawDecorationInPresentationRule()
    : super(code: _rawDecorationCode);

  static const _rawDecorationCode = LintCode(
    name: 'avoid_raw_decoration_in_presentation',
    problemMessage:
        'Do not build raw decoration primitives in presentation code. Use design-system surface, avatar, or chip components instead.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (!shouldLintPresentationPath(resolver.path)) {
      return;
    }

    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name.lexeme;
      if (isRawDecorationType(typeName)) {
        reporter.atNode(node, code);
      }
    });
  }
}

class AvoidRawTypographyStylesInPresentationRule extends DartLintRule {
  const AvoidRawTypographyStylesInPresentationRule()
    : super(code: _rawTypographyCode);

  static const _rawTypographyCode = LintCode(
    name: 'avoid_raw_typography_styles_in_presentation',
    problemMessage:
        'Do not define raw typography in presentation code. Use ThemeData text styles and token-owned typography instead.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (!shouldLintPresentationPath(resolver.path)) {
      return;
    }

    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name.lexeme;
      if (isTypographyStyleConstructor(typeName)) {
        reporter.atNode(node, code);
      }
    });

    context.registry.addMethodInvocation((node) {
      if (hasRawTypographyOverride(node)) {
        reporter.atNode(node, code);
      }
    });
  }
}

class AvoidRawIconSizeInPresentationRule extends DartLintRule {
  const AvoidRawIconSizeInPresentationRule() : super(code: _rawIconSizeCode);

  static const _rawIconSizeCode = LintCode(
    name: 'avoid_raw_icon_size_in_presentation',
    problemMessage:
        'Do not hardcode icon sizes in presentation code. Use IconTheme, component tokens, or design-system primitives.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (!shouldLintPresentationPath(resolver.path)) {
      return;
    }

    context.registry.addInstanceCreationExpression((node) {
      if (hasLiteralIconSize(node)) {
        reporter.atNode(node, code);
      }
    });
  }
}

class AvoidRawUserFacingTextRule extends DartLintRule {
  const AvoidRawUserFacingTextRule() : super(code: _rawUserFacingTextCode);

  static const _rawUserFacingTextCode = LintCode(
    name: 'avoid_raw_user_facing_text',
    problemMessage:
        'Do not hardcode user-facing text in lib code. Read visible strings from AppLocalizations.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (!shouldLintUserFacingTextPath(resolver.path)) {
      return;
    }

    context.registry.addInstanceCreationExpression((node) {
      if (hasRawUserFacingTextInCreation(node)) {
        reporter.atNode(node, code);
      }
    });

    context.registry.addDefaultFormalParameter((node) {
      if (hasRawUserFacingTextDefault(node)) {
        reporter.atNode(node, code);
      }
    });
  }
}

class AvoidRawTappableControlsWithoutTokenConstraintsRule extends DartLintRule {
  const AvoidRawTappableControlsWithoutTokenConstraintsRule()
    : super(code: _rawControlCode);

  static const _rawControlCode = LintCode(
    name: 'avoid_raw_tappable_controls_without_token_constraints',
    problemMessage:
        'Do not build raw tappable controls in presentation code. Use token-sized design-system components instead.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (!shouldLintPresentationPath(resolver.path)) {
      return;
    }

    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name.lexeme;
      if (isRawTappableControlType(typeName)) {
        reporter.atNode(node, code);
      }
    });
  }
}
