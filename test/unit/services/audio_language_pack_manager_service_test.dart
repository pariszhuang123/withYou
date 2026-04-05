import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/contracts/platform_contracts.dart';
import 'package:with_you/models/audio_language.dart';
import 'package:with_you/models/playable_audio_source.dart';
import 'package:with_you/repositories/app_state_repository.dart';
import 'package:with_you/repositories/audio_language_pack_repository.dart';
import 'package:with_you/services/audio_language_pack_manager_service.dart';
import 'package:with_you/services/content_resolver_service.dart';

class _TestLogger implements KinlyLoggerContract {
  final List<String> warnings = [];
  final List<String> errors = [];

  @override
  void debug(String message, {String category = 'app', Object? error}) {}

  @override
  void error(
    String message, {
    String category = 'app',
    Object? error,
    StackTrace? stackTrace,
  }) {
    errors.add(message);
  }

  @override
  void info(String message, {String category = 'app'}) {}

  @override
  void warn(String message, {String category = 'app', Object? error}) {
    warnings.add(message);
  }
}

void main() {
  late Directory tempDirectory;
  late AppStateRepository appStateRepository;
  late AudioLanguagePackRepository packRepository;
  late _TestLogger logger;
  late Set<String> availableAssets;
  late AudioLanguagePackManagerService service;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'audio_pack_manager_test',
    );
    appStateRepository = AppStateRepository(
      directoryProvider: () async => tempDirectory,
    );
    packRepository = AudioLanguagePackRepository(
      directoryProvider: () async => tempDirectory,
    );
    logger = _TestLogger();
    availableAssets = <String>{};

    service = AudioLanguagePackManagerService(
      appStateContract: appStateRepository,
      repository: packRepository,
      contentResolverContract: const ContentResolverService(),
      logger: logger,
      directoryProvider: () async => tempDirectory,
      assetAvailabilityChecker: (assetPath) async =>
          availableAssets.contains(assetPath),
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test(
    'ensureSelectedLocale collapses traditional Chinese locales to zh',
    () async {
      availableAssets.add('assets/audio/zh/presence/stage_1.m4a');

      final localeTag = await service.ensureSelectedLocale(const <Locale>[
        Locale('zh', 'TW'),
      ]);

      expect(localeTag, 'zh');
      expect(await appStateRepository.getSelectedAudioLocaleTag(), 'zh');
    },
  );

  test('listAvailableLanguages only exposes bundled locales', () async {
    await appStateRepository.setSelectedAudioLocaleTag('zh');
    for (final descriptor
        in const ContentResolverService().listRequiredAudio()) {
      availableAssets.add(
        'assets/audio/zh/${descriptor.scenarioDirectory}/stage_${descriptor.stage}.m4a',
      );
    }

    final languages = await service.listAvailableLanguages();

    expect(
      languages.map((entry) => entry.language.localeTag).toList(),
      <String>['zh'],
    );
    expect(
      languages.every(
        (entry) => entry.status == AudioLanguagePackStatus.downloaded,
      ),
      isTrue,
    );
    expect(languages.every((entry) => entry.isReadyOffline), isTrue);
  });

  test('downloadLanguagePack rejects unsupported locales', () async {
    expect(
      () => service.downloadLanguagePack('zh-TW'),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('resolvePlayableAudio uses bundled zh for selected zh locale', () async {
    await appStateRepository.setSelectedAudioLocaleTag('zh');
    availableAssets.add('assets/audio/zh/presence/stage_1.m4a');

    final resolved = await service.resolvePlayableAudio(
      scenario: Scenario.presence,
      stage: 1,
    );

    expect(resolved.localeTag, 'zh');
    expect(resolved.source, isA<BundledAudioSource>());
  });

  test(
    'resolvePlayableAudio falls back to bundled zh when selected locale is absent',
    () async {
      await appStateRepository.setSelectedAudioLocaleTag('zh-TW');
      availableAssets.add('assets/audio/zh/presence/stage_1.m4a');

      final resolved = await service.resolvePlayableAudio(
        scenario: Scenario.presence,
        stage: 1,
      );

      expect(resolved.localeTag, 'zh');
      expect(
        (resolved.source as BundledAudioSource).assetPath,
        contains('assets/audio/zh/'),
      );
      expect(logger.warnings.single, contains('Falling back'));
    },
  );

  test(
    'resolvePlayableAudio skips unavailable selected bundled asset and falls back',
    () async {
      await appStateRepository.setSelectedAudioLocaleTag('zh');
      availableAssets.add('assets/audio/en/presence/stage_1.m4a');

      final resolved = await service.resolvePlayableAudio(
        scenario: Scenario.presence,
        stage: 1,
      );

      expect(resolved.localeTag, 'en');
      expect(
        (resolved.source as BundledAudioSource).assetPath,
        'assets/audio/en/presence/stage_1.m4a',
      );
      expect(logger.warnings, hasLength(2));
      expect(
        logger.warnings.first,
        contains('Bundled audio asset unavailable'),
      );
      expect(logger.warnings.last, contains('Falling back from zh to en'));
    },
  );

  test(
    'resolvePlayableAudio throws when no bundled fallback asset exists',
    () async {
      await appStateRepository.setSelectedAudioLocaleTag('zh');

      await expectLater(
        service.resolvePlayableAudio(scenario: Scenario.presence, stage: 1),
        throwsA(isA<StateError>()),
      );
      expect(logger.errors.single, contains('No local audio source available'));
    },
  );

  test(
    'ensureSelectedLocale falls back to bundled zh when english audio pack is incomplete',
    () async {
      for (final descriptor
          in const ContentResolverService().listRequiredAudio()) {
        availableAssets.add(
          'assets/audio/zh/${descriptor.scenarioDirectory}/stage_${descriptor.stage}.m4a',
        );
      }

      final localeTag = await service.ensureSelectedLocale(const <Locale>[
        Locale('en'),
      ]);

      expect(localeTag, 'zh');
      expect(await appStateRepository.getSelectedAudioLocaleTag(), 'zh');
    },
  );
}
