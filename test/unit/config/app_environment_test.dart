import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/config/app_environment.dart';

void main() {
  group('AppEnvironment.fromDefine', () {
    test('maps development values to dev', () {
      expect(AppEnvironment.fromDefine('dev'), AppEnvironment.dev);
      expect(AppEnvironment.fromDefine('development'), AppEnvironment.dev);
    });

    test('maps production values to prod', () {
      expect(AppEnvironment.fromDefine('prod'), AppEnvironment.prod);
      expect(AppEnvironment.fromDefine('production'), AppEnvironment.prod);
      expect(AppEnvironment.fromDefine(''), AppEnvironment.prod);
    });

    test('rejects unsupported values', () {
      expect(
        () => AppEnvironment.fromDefine('staging'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
