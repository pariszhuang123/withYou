import 'package:flutter/widgets.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'contracts/app_locale_resolver_contract.dart';
import 'contracts/audio_language_pack_manager_contract.dart';
import 'di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  await setupServiceLocator(config: config);
  runApp(
    WithYouApp(
      config: config,
      appLocaleResolverContract: sl<AppLocaleResolverContract>(),
      audioLanguagePackManagerContract: sl<AudioLanguagePackManagerContract>(),
    ),
  );
}
