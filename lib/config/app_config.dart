import 'app_environment.dart';

class AppConfig {
  AppConfig({required this.environment, this.audioManifestUrl = ''});

  factory AppConfig.fromEnvironment() {
    const envValue = String.fromEnvironment('APP_ENV', defaultValue: 'prod');
    const manifestUrl = String.fromEnvironment(
      'AUDIO_MANIFEST_URL',
      defaultValue: '',
    );
    return AppConfig(
      environment: AppEnvironment.fromDefine(envValue),
      audioManifestUrl: manifestUrl,
    );
  }

  final AppEnvironment environment;
  final String audioManifestUrl;

  bool get isDevelopment => environment == AppEnvironment.dev;

  String get appName => 'With You';

  String get environmentLabel => isDevelopment ? 'DEV' : 'PROD';

  String get releaseChannel => isDevelopment ? 'development' : 'production';
}
