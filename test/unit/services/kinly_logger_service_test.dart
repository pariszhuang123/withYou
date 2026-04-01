import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/services/kinly_logger_service.dart';

void main() {
  const service = KinlyLoggerService();

  test('log methods complete without throwing', () {
    expect(() => service.debug('debug message'), returnsNormally);
    expect(() => service.info('info message'), returnsNormally);
    expect(() => service.warn('warn message'), returnsNormally);
    expect(() => service.error('error message'), returnsNormally);
  });
}
