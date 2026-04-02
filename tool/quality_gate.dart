import 'dart:io';

const double _defaultCoverageThreshold = 80;

Future<void> main(List<String> args) async {
  var requireCoverage = true;
  var coverageThreshold = _defaultCoverageThreshold;

  for (final arg in args) {
    if (arg == '--no-coverage') {
      requireCoverage = false;
      continue;
    }
    if (arg.startsWith('--coverage-threshold=')) {
      final rawValue = arg.substring('--coverage-threshold='.length);
      coverageThreshold = double.parse(rawValue);
      continue;
    }
    stderr.writeln('Unknown argument: $arg');
    exitCode = 64;
    return;
  }

  await _runDartScript(
    'tool${Platform.pathSeparator}validate_contract_structure.dart',
  );
  await _runDartCommand(<String>['run', 'custom_lint']);
  await _runFlutterCommand(<String>['analyze', '--fatal-infos']);

  final testArguments = <String>['test'];
  if (requireCoverage) {
    testArguments.add('--coverage');
  }
  await _runFlutterCommand(testArguments);

  if (requireCoverage) {
    final coverage = await readLineCoverage(
      'coverage${Platform.pathSeparator}lcov.info',
    );
    stdout.writeln('Line coverage: ${coverage.toStringAsFixed(2)}%');
    if (coverage < coverageThreshold) {
      stderr.writeln(
        'Coverage ${coverage.toStringAsFixed(2)}% is below the required '
        '${coverageThreshold.toStringAsFixed(2)}% threshold.',
      );
      exitCode = 1;
      return;
    }
  }
}

Future<void> _runFlutterCommand(List<String> arguments) async {
  await _runCommand(_flutterExecutable, arguments);
}

Future<void> _runDartCommand(List<String> arguments) async {
  await _runCommand(_dartExecutable, arguments);
}

Future<void> _runDartScript(String scriptPath) async {
  await _runCommand(_dartExecutable, <String>[scriptPath]);
}

Future<void> _runCommand(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    environment: <String, String>{
      ...Platform.environment,
      'DART_SUPPRESS_ANALYTICS': 'true',
    },
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    exit(exitCode);
  }
}

Future<double> readLineCoverage(String lcovPath) async {
  final file = File(lcovPath);
  if (!await file.exists()) {
    throw StateError('Coverage file not found: $lcovPath');
  }

  final content = await file.readAsString();
  return parseLineCoverage(content);
}

double parseLineCoverage(String lcovContent) {
  var foundAny = false;
  var linesFound = 0;
  var linesHit = 0;

  for (final line in lcovContent.split('\n')) {
    if (line.startsWith('LF:')) {
      linesFound += int.parse(line.substring(3).trim());
      foundAny = true;
    } else if (line.startsWith('LH:')) {
      linesHit += int.parse(line.substring(3).trim());
      foundAny = true;
    }
  }

  if (!foundAny || linesFound == 0) {
    throw StateError('No line coverage data found in lcov content.');
  }

  return (linesHit / linesFound) * 100;
}

String get _flutterExecutable => Platform.isWindows ? 'flutter.bat' : 'flutter';

String get _dartExecutable => Platform.isWindows ? 'dart.bat' : 'dart';
