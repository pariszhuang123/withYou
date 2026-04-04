import 'package:analyzer/dart/ast/ast.dart';

bool shouldLintPresentationPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  if (!normalized.contains('/lib/')) {
    return false;
  }
  if (isDesignSystemPrimitivePath(normalized)) {
    return false;
  }
  if (normalized.contains('/lib/theme/')) {
    return false;
  }
  if (normalized.contains('/lib/l10n/')) {
    return false;
  }
  return normalized.contains('/lib/widgets/') ||
      normalized.contains('/lib/screens/') ||
      normalized.endsWith('/lib/app.dart');
}

bool shouldLintUserFacingTextPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  if (!normalized.contains('/lib/')) {
    return false;
  }
  if (normalized.contains('/lib/l10n/')) {
    return false;
  }
  return true;
}

bool isDesignSystemPrimitivePath(String normalizedPath) {
  return normalizedPath.endsWith('/lib/widgets/themed_components.dart');
}

bool isRawTappableControlType(String typeName) {
  return <String>{
    'GestureDetector',
    'InkWell',
    'InkResponse',
    'IconButton',
    'ElevatedButton',
    'FilledButton',
    'OutlinedButton',
    'TextButton',
    'FloatingActionButton',
  }.contains(typeName);
}

bool isRawDecorationType(String typeName) {
  return <String>{
    'BoxDecoration',
    'ShapeDecoration',
    'BorderSide',
  }.contains(typeName);
}

bool isTypographyStyleConstructor(String typeName) {
  return typeName == 'TextStyle';
}

bool requiresSemanticLabel(String typeName) {
  return <String>{'ThemedButton', 'ThemedIconButton'}.contains(typeName);
}

bool hasNamedArgument(InstanceCreationExpression node, String argumentName) {
  for (final argument in node.argumentList.arguments) {
    if (argument is NamedExpression &&
        argument.name.label.name == argumentName) {
      return true;
    }
  }
  return false;
}

bool hasLiteralSpacingArgument(InstanceCreationExpression node) {
  for (final argument in node.argumentList.arguments) {
    if (argument is NamedExpression) {
      if (isNumericLiteral(argument.expression)) {
        return true;
      }
      continue;
    }

    if (isNumericLiteral(argument)) {
      return true;
    }
  }
  return false;
}

bool hasLiteralSizedBoxDimension(InstanceCreationExpression node) {
  for (final argument in node.argumentList.arguments) {
    if (argument is! NamedExpression) {
      continue;
    }

    final name = argument.name.label.name;
    if ((name == 'height' || name == 'width') &&
        isNumericLiteral(argument.expression)) {
      return true;
    }
  }
  return false;
}

bool hasLiteralBorderRadiusArgument(InstanceCreationExpression node) {
  final typeName = node.constructorName.type.name.lexeme;
  if (typeName != 'BorderRadius' && typeName != 'Radius') {
    return false;
  }

  for (final argument in node.argumentList.arguments) {
    if (argument is NamedExpression) {
      if (isNumericLiteral(argument.expression)) {
        return true;
      }
      continue;
    }

    if (isNumericLiteral(argument)) {
      return true;
    }
  }

  return false;
}

bool hasRawTypographyOverride(MethodInvocation node) {
  if (node.methodName.name != 'copyWith') {
    return false;
  }

  for (final argument in node.argumentList.arguments) {
    if (argument is! NamedExpression) {
      continue;
    }

    final name = argument.name.label.name;
    if (name == 'fontSize' ||
        name == 'fontWeight' ||
        name == 'height' ||
        name == 'letterSpacing') {
      return true;
    }
  }

  return false;
}

bool hasLiteralIconSize(InstanceCreationExpression node) {
  final typeName = node.constructorName.type.name.lexeme;
  if (typeName != 'Icon') {
    return false;
  }

  for (final argument in node.argumentList.arguments) {
    if (argument is! NamedExpression) {
      continue;
    }

    if (argument.name.label.name == 'size' &&
        isNumericLiteral(argument.expression)) {
      return true;
    }
  }

  return false;
}

bool isNumericLiteral(Expression expression) {
  return switch (expression.unParenthesized) {
    IntegerLiteral() => true,
    DoubleLiteral() => true,
    _ => false,
  };
}

bool hasRawUserFacingTextInCreation(InstanceCreationExpression node) {
  final typeName = node.constructorName.type.name.lexeme;

  if (isUserFacingTextConstructor(typeName)) {
    final positionalArguments = node.argumentList.arguments.where(
      (argument) => argument is! NamedExpression,
    );
    for (final argument in positionalArguments) {
      if (containsLiteralUserFacingText(argument)) {
        return true;
      }
    }
  }

  for (final argument in node.argumentList.arguments) {
    if (argument is! NamedExpression) {
      continue;
    }

    if (!isUserFacingTextNamedArgument(argument.name.label.name)) {
      continue;
    }

    if (containsLiteralUserFacingText(argument.expression)) {
      return true;
    }
  }

  return false;
}

bool hasRawUserFacingTextDefault(DefaultFormalParameter node) {
  final parameter = node.parameter;
  final name = switch (parameter) {
    SimpleFormalParameter() => parameter.name?.lexeme,
    FieldFormalParameter() => parameter.name.lexeme,
    SuperFormalParameter() => parameter.name.lexeme,
    _ => null,
  };

  if (name == null || !isUserFacingTextDefaultParameter(name)) {
    return false;
  }

  final defaultValue = node.defaultValue;
  if (defaultValue == null) {
    return false;
  }

  return containsLiteralUserFacingText(defaultValue);
}

bool isUserFacingTextConstructor(String typeName) {
  return <String>{'Text', 'SelectableText', 'TextSpan'}.contains(typeName);
}

bool isUserFacingTextNamedArgument(String name) {
  return <String>{
    'label',
    'semanticLabel',
    'tooltip',
    'labelText',
    'hintText',
    'helperText',
    'errorText',
    'title',
    'subtitle',
    'body',
    'message',
    'helper',
    'avatarLabel',
  }.contains(name);
}

bool isUserFacingTextDefaultParameter(String name) {
  return <String>{
    'label',
    'semanticLabel',
    'tooltip',
    'title',
    'subtitle',
    'body',
    'message',
    'helper',
    'avatarLabel',
  }.contains(name);
}

bool containsLiteralUserFacingText(Expression expression) {
  return switch (expression.unParenthesized) {
    SimpleStringLiteral(:final value) => containsLikelyUserFacingText(value),
    StringInterpolation(:final elements) => elements
        .whereType<InterpolationString>()
        .any((element) => containsLikelyUserFacingText(element.value)),
    AdjacentStrings(:final strings) => strings.any(containsLiteralUserFacingText),
    _ => false,
  };
}

bool containsLikelyUserFacingText(String value) {
  return _userFacingTextPattern.hasMatch(value);
}

final RegExp _userFacingTextPattern = RegExp(
  r'[A-Za-z\u00C0-\u024F\u0370-\u03FF\u0400-\u04FF\u3040-\u30FF\u3400-\u9FFF\uAC00-\uD7AF]',
);
