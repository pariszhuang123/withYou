import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final repoRoot = Directory.current;
  final libDirectory = Directory('${repoRoot.path}${Platform.pathSeparator}lib');
  final diDirectory = Directory(
    '${libDirectory.path}${Platform.pathSeparator}di',
  ).absolute.path;

  test('only the DI layer imports concrete implementations', () async {
    final violations = await _collectViolations(
      root: libDirectory,
      filePredicate: (file) => !file.absolute.path.startsWith(diDirectory),
      importPredicate: (importPath) =>
          importPath.contains('/services/') ||
          importPath.contains('/repositories/') ||
          importPath.contains('/platform/') ||
          importPath.contains('/database/'),
      description: 'imports a concrete implementation',
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('only the DI layer accesses GetIt or service_locator directly', () async {
    final violations = await _collectViolations(
      root: libDirectory,
      filePredicate: (file) => !file.absolute.path.startsWith(diDirectory),
      importPredicate: (importPath) =>
          importPath == 'package:get_it/get_it.dart' ||
          importPath.endsWith('/di/service_locator.dart') ||
          importPath == 'di/service_locator.dart' ||
          importPath == '../di/service_locator.dart',
      description: 'imports service location infrastructure',
    );

    final getItUsages = await _collectContentViolations(
      root: libDirectory,
      filePredicate: (file) => !file.absolute.path.startsWith(diDirectory),
      pattern: RegExp(r'\bGetIt\.(I|instance)\b'),
      description: 'references GetIt directly',
    );

    expect(
      [...violations, ...getItUsages],
      isEmpty,
      reason: [...violations, ...getItUsages].join('\n'),
    );
  });
}

Future<List<String>> _collectViolations({
  required Directory root,
  required bool Function(File file) filePredicate,
  required bool Function(String importPath) importPredicate,
  required String description,
}) async {
  final violations = <String>[];
  final importRegex = RegExp(r'''^import\s+['"]([^'"]+)['"];''', multiLine: true);

  await for (final entity in root.list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }
    if (!filePredicate(entity)) {
      continue;
    }

    final content = await entity.readAsString();
    for (final match in importRegex.allMatches(content)) {
      final importPath = match.group(1)!;
      if (importPredicate(importPath)) {
        violations.add('${_relativePath(entity.path)} $description: $importPath');
      }
    }
  }

  return violations;
}

Future<List<String>> _collectContentViolations({
  required Directory root,
  required bool Function(File file) filePredicate,
  required RegExp pattern,
  required String description,
}) async {
  final violations = <String>[];

  await for (final entity in root.list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }
    if (!filePredicate(entity)) {
      continue;
    }

    final content = await entity.readAsString();
    if (pattern.hasMatch(content)) {
      violations.add('${_relativePath(entity.path)} $description');
    }
  }

  return violations;
}

String _relativePath(String path) {
  final root = Directory.current.absolute.path;
  if (path.startsWith(root)) {
    return path.substring(root.length + 1);
  }
  return path;
}
