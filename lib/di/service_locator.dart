import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';
import '../contracts/app_contracts.dart';
import '../contracts/audio_contracts.dart';
import '../contracts/call_flow_contracts.dart';
import '../contracts/commerce_contracts.dart';
import '../contracts/platform_contracts.dart';
import '../contracts/readiness_contracts.dart';
import '../platform/notification_service.dart';
import '../repositories/app_state_repository.dart';
import '../repositories/audio_language_pack_repository.dart';
import '../repositories/pending_follow_up_repository.dart';
import '../services/app_locale_resolver_service.dart';
import '../services/audio_language_pack_manager_service.dart';
import '../services/audio_playback_service.dart';
import '../services/call_flow_coordinator_service.dart';
import '../services/call_template_service.dart';
import '../services/content_resolver_service.dart';
import '../services/fake_call_timing_service.dart';
import '../services/kinly_logger_service.dart';
import '../services/notification_readiness_service.dart';
import '../services/premium_access_service.dart';
import '../services/scene_readiness_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator({required AppConfig config}) async {
  await sl.reset();

  sl.registerSingleton<AppConfig>(config);
  sl.registerLazySingleton<KinlyLoggerContract>(
    () => const KinlyLoggerService(),
  );
  sl.registerLazySingleton<AppLocaleResolverContract>(
    () => const AppLocaleResolverService(),
  );
  sl.registerLazySingleton<ContentResolverContract>(
    () => const ContentResolverService(),
  );
  sl.registerLazySingleton<CallTemplateContract>(
    () => const CallTemplateService(),
  );
  sl.registerLazySingleton<NotificationContract>(() => NotificationService());
  sl.registerLazySingleton<AudioPlaybackContract>(() => AudioPlaybackService());

  Future<Directory> directoryProvider() async {
    final baseDirectory = await getApplicationSupportDirectory();
    return Directory('${baseDirectory.path}${Platform.pathSeparator}with_you');
  }

  sl.registerLazySingleton<AppStateContract>(
    () => AppStateRepository(directoryProvider: directoryProvider),
  );
  sl.registerLazySingleton<PremiumAccessContract>(
    () => PremiumAccessService(appStateContract: sl<AppStateContract>()),
  );
  sl.registerLazySingleton<AudioLanguagePackRepositoryContract>(
    () => AudioLanguagePackRepository(directoryProvider: directoryProvider),
  );
  sl.registerLazySingleton<PendingFollowUpRepositoryContract>(
    () => PendingFollowUpRepository(directoryProvider: directoryProvider),
  );
  sl.registerLazySingleton<NotificationReadinessContract>(
    () => NotificationReadinessService(
      notificationContract: sl<NotificationContract>(),
    ),
  );
  sl.registerLazySingleton<SceneReadinessContract>(
    () => SceneReadinessService(
      notificationReadinessContract: sl<NotificationReadinessContract>(),
      premiumAccessContract: sl<PremiumAccessContract>(),
    ),
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
  sl.registerLazySingleton<FakeCallTimingContract>(
    () => FakeCallTimingService(
      notificationContract: sl<NotificationContract>(),
      audioPlaybackContract: sl<AudioPlaybackContract>(),
      audioLanguagePackManagerContract: sl<AudioLanguagePackManagerContract>(),
      contentResolverContract: sl<ContentResolverContract>(),
    ),
  );
  sl.registerLazySingleton<CallFlowCoordinatorContract>(
    () => CallFlowCoordinatorService(
      timingContract: sl<FakeCallTimingContract>(),
      contentResolverContract: sl<ContentResolverContract>(),
      notificationContract: sl<NotificationContract>(),
      pendingFollowUpRepository: sl<PendingFollowUpRepositoryContract>(),
    ),
  );
}
