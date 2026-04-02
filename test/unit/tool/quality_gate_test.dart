import 'package:flutter_test/flutter_test.dart';

import '../../../tool/quality_gate.dart' as quality_gate;

void main() {
  group('quality gate coverage parser', () {
    test('parses aggregate line coverage from lcov content', () {
      const lcov = '''
TN:
SF:lib/a.dart
LF:10
LH:8
end_of_record
SF:lib/b.dart
LF:5
LH:5
end_of_record
''';

      final coverage = quality_gate.parseLineCoverage(lcov);

      expect(coverage, closeTo(86.67, 0.01));
    });

    test('throws when lcov content has no executable lines', () {
      expect(
        () => quality_gate.parseLineCoverage('TN:\nSF:lib/a.dart\nLF:0\nLH:0\n'),
        throwsStateError,
      );
    });
  });
}
