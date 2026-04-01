import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/config/app_config.dart';
import 'package:with_you/config/app_environment.dart';

void main() {
  test('dev config exposes development metadata', () {
    final config = AppConfig(
      environment: AppEnvironment.dev,
      audioManifestUrl: 'https://example.com/audio.json',
    );

    expect(config.isDevelopment, isTrue);
    expect(config.appName, 'With You');
    expect(config.environmentLabel, 'DEV');
    expect(config.releaseChannel, 'development');
    expect(config.audioManifestUrl, 'https://example.com/audio.json');
  });

  test('prod config exposes production metadata', () {
    final config = AppConfig(environment: AppEnvironment.prod);

    expect(config.isDevelopment, isFalse);
    expect(config.appName, 'With You');
    expect(config.environmentLabel, 'PROD');
    expect(config.releaseChannel, 'production');
    expect(config.audioManifestUrl, isEmpty);
  });
}
