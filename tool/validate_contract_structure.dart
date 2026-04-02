import 'dart:io';

final RegExp _abstractContractPattern = RegExp(
  r'abstract\s+class\s+([A-Za-z0-9_]+Contract)\b',
);
final RegExp _metadataRowPattern = RegExp(
  r'^\|\s*([^|]+?)\s*\|\s*`?([^|`]+?)`?\s*\|$',
);

const _allowedRootBarrels = <String>{
  'app_contracts.dart',
  'audio_contracts.dart',
  'call_flow_contracts.dart',
  'commerce_contracts.dart',
  'platform_contracts.dart',
  'readiness_contracts.dart',
  'contracts.dart',
};

const _allowedContractModules = <String>{
  'app',
  'audio',
  'call_flow',
  'commerce',
  'platform',
  'readiness',
};

const _requiredMetadataFields = <String>{
  'Version',
  'Status',
  'Last Updated',
  'Generated',
  'ADR',
  'Module',
  'Source',
};

Future<void> main() async {
  final repoRoot = Directory.current;
  final contractsDir = Directory(
    '${repoRoot.path}${Platform.pathSeparator}lib${Platform.pathSeparator}contracts',
  );
  final docsContractsDir = Directory(
    '${repoRoot.path}${Platform.pathSeparator}docs${Platform.pathSeparator}contracts',
  );

  final errors = <String>[];

  if (!await contractsDir.exists()) {
    stderr.writeln('Missing contracts directory: ${contractsDir.path}');
    exitCode = 1;
    return;
  }

  final contractFiles = <File>[];
  await for (final entity in contractsDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      contractFiles.add(entity);
    }
  }

  for (final file in contractFiles) {
    final relativePath = relativeRepoPath(repoRoot.path, file.path);
    final segments = file.uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .skipWhile((segment) => segment != 'contracts')
        .skip(1)
        .toList();
    final name = segments.last;
    final isBarrel = segments.length == 1 && _allowedRootBarrels.contains(name);

    if (segments.length == 1 && !isBarrel) {
      errors.add(
        'Only contract barrel files may live at lib/contracts/: $relativePath',
      );
      continue;
    }

    if (isBarrel) {
      continue;
    }

    if (segments.length != 2) {
      errors.add(
        'Contract files must live one folder below lib/contracts/: $relativePath',
      );
      continue;
    }

    final module = segments.first;
    if (!_allowedContractModules.contains(module)) {
      errors.add(
        'Unknown contract module `$module` for $relativePath. Allowed modules: '
        '${_allowedContractModules.join(', ')}',
      );
      continue;
    }

    if (!isValidContractFileName(name)) {
      errors.add('Contract file must end with `_contract.dart`: $relativePath');
    }

    final content = await file.readAsString();
    final matches = _abstractContractPattern.allMatches(content).toList();
    if (matches.isEmpty) {
      errors.add(
        'Contract file must declare an abstract class ending in `Contract`: $relativePath',
      );
    }

    final expectedDoc = expectedDocPathForContractFile(
      '$module${Platform.pathSeparator}$name',
    );
    final docFile = File(
      '${docsContractsDir.path}${Platform.pathSeparator}$expectedDoc',
    );
    if (!await docFile.exists()) {
      errors.add(
        'Missing contract doc for $relativePath: docs/contracts/$expectedDoc',
      );
      continue;
    }

    final docContent = await docFile.readAsString();
    final metadata = parseMetadataTable(docContent);
    final missingFields = _requiredMetadataFields
        .where((field) => !metadata.containsKey(field))
        .toList();
    if (missingFields.isNotEmpty) {
      errors.add(
        'Contract doc is missing metadata fields (${missingFields.join(', ')}): '
        'docs/contracts/$expectedDoc',
      );
    }

    if (metadata['Module'] != module) {
      errors.add(
        'Contract doc module metadata must match `$module`: docs/contracts/$expectedDoc',
      );
    }

    if (metadata['Source'] != 'lib/contracts/$module/$name') {
      errors.add(
        'Contract doc source metadata must match lib/contracts/$module/$name: '
        'docs/contracts/$expectedDoc',
      );
    }

    if (!docContent.contains('## Purpose')) {
      errors.add(
        'Contract doc must contain a `## Purpose` section: docs/contracts/$expectedDoc',
      );
    }
  }

  for (final barrel in _allowedRootBarrels) {
    final file = File('${contractsDir.path}${Platform.pathSeparator}$barrel');
    if (!await file.exists()) {
      errors.add('Missing contract barrel: lib/contracts/$barrel');
    }
  }

  for (final module in _allowedContractModules) {
    final moduleDir = Directory(
      '${contractsDir.path}${Platform.pathSeparator}$module',
    );
    if (!await moduleDir.exists()) {
      errors.add('Missing contract module directory: lib/contracts/$module');
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln('Contract structure validation failed:');
    for (final error in errors) {
      stderr.writeln('- $error');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Contract structure validation passed.');
}

Map<String, String> parseMetadataTable(String content) {
  final metadata = <String, String>{};
  for (final line in content.split('\n')) {
    final trimmed = line.trim();
    final match = _metadataRowPattern.firstMatch(trimmed);
    if (match == null) {
      continue;
    }

    final key = match.group(1)?.trim();
    final value = match.group(2)?.trim();
    if (key == null ||
        value == null ||
        key == 'Field' ||
        key.startsWith('---')) {
      continue;
    }
    metadata[key] = value;
  }
  return metadata;
}

String relativeRepoPath(String repoRootPath, String filePath) {
  final root = repoRootPath.replaceAll('\\', '/');
  final path = filePath.replaceAll('\\', '/');
  if (path.startsWith(root)) {
    return path.substring(root.length + 1);
  }
  return path;
}

bool isValidContractFileName(String contractFileName) {
  return contractFileName.endsWith('_contract.dart');
}

String expectedDocPathForContractFile(String contractFilePath) {
  final normalizedPath = contractFilePath.replaceAll('\\', '/');
  final lastSeparator = normalizedPath.lastIndexOf('/');
  final module = normalizedPath.substring(0, lastSeparator);
  final fileName = normalizedPath.substring(lastSeparator + 1);
  final normalizedFile = fileName.replaceFirst('_contract.dart', '');
  return '$module/${normalizedFile.replaceAll('_', '-')}.md';
}
