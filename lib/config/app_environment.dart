enum AppEnvironment {
  dev,
  prod;

  static AppEnvironment fromDefine(String value) {
    switch (value.toLowerCase()) {
      case 'dev':
      case 'development':
        return AppEnvironment.dev;
      case 'prod':
      case 'production':
      case '':
        return AppEnvironment.prod;
    }

    throw ArgumentError.value(
      value,
      'value',
      'Unsupported APP_ENV. Expected dev or prod.',
    );
  }
}
