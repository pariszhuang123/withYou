import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';
import '../contracts/app_locale_resolver_contract.dart';
import '../contracts/app_state_contract.dart';
import '../contracts/audio_language_pack_manager_contract.dart';
import '../contracts/audio_language_pack_repository_contract.dart';
import '../contracts/content_resolver_contract.dart';
import '../contracts/kinly_logger_contract.dart';
import '../repositories/app_state_repository.dart';
import '../repositories/audio_language_pack_repository.dart';
import '../services/app_locale_resolver_service.dart';
import '../services/audio_language_pack_manager_service.dart';
import '../services/content_resolver_service.dart';
import '../services/kinly_logger_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator({required AppConfig config}) async {
  await sl.reset();

  sl.registerSingleton<AppConfig>(config);
  sl.registerLazySingleton<KinlyLoggerContract>(() => const KinlyLoggerService());
  sl.registerLazySingleton<AppLocaleResolverContract>(
    () => const AppLocaleResolverService(),
  );
  sl.registerLazySingleton<ContentResolverContract>(
    () => const ContentResolverService(),
  );

  Future<Directory> directoryProvider() async {
    final baseDirectory = await getApplicationSupportDirectory();
    return Directory('${baseDirectory.path}${Platform.pathSeparator}with_you');
  }

  sl.registerLazySingleton<AppStateContract>(
    () => AppStateRepository(directoryProvider: directoryProvider),
  );
  sl.registerLazySingleton<AudioLanguagePackRepositoryContract>(
    () => AudioLanguagePackRepository(directoryProvider: directoryProvider),
  );
  sl.registerLazySingleton<AudioLanguagePackManagerContract>(
    () => AudioLanguagePackManagerService(
      appStateContract: sl<AppStateContract>(),
      repository: sl<AudioLanguagePackRepositoryContract>(),
      contentResolverContract: sl<ContentResolverContract>(),
      logger: sl<KinlyLoggerContract>(),
      directoryProvider: directoryProvider,
      manifestUri: config.audioManifestUrl.isEmpty
          ? null
          : Uri.tryParse(config.audioManifestUrl),
    ),
  );
}
