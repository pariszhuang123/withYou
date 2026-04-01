abstract class KinlyLoggerContract {
  void debug(String message, {String category = 'app', Object? error});

  void info(String message, {String category = 'app'});

  void warn(String message, {String category = 'app', Object? error});

  void error(
    String message, {
    String category = 'app',
    Object? error,
    StackTrace? stackTrace,
  });
}
