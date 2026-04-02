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
