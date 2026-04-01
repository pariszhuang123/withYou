import 'dart:developer' as developer;

import '../contracts/kinly_logger_contract.dart';

class KinlyLoggerService implements KinlyLoggerContract {
  const KinlyLoggerService();

  @override
  void debug(String message, {String category = 'app', Object? error}) {
    developer.log(message, name: 'kinly.$category.debug', error: error);
  }

  @override
  void info(String message, {String category = 'app'}) {
    developer.log(message, name: 'kinly.$category.info');
  }

  @override
  void warn(String message, {String category = 'app', Object? error}) {
    developer.log(message, name: 'kinly.$category.warn', error: error);
  }

  @override
  void error(
    String message, {
    String category = 'app',
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'kinly.$category.error',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
