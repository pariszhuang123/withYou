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

    service = AudioLanguagePackManagerService(
      appStateContract: appStateRepository,
      repository: packRepository,
      contentResolverContract: const ContentResolverService(),
      logger: logger,
      directoryProvider: () async => tempDirectory,
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
      final localeTag = await service.ensureSelectedLocale(const <Locale>[
        Locale('zh', 'TW'),
      ]);

      expect(localeTag, 'zh');
      expect(await appStateRepository.getSelectedAudioLocaleTag(), 'zh');
    },
  );

  test('listAvailableLanguages only exposes bundled locales', () async {
    await appStateRepository.setSelectedAudioLocaleTag('zh');

    final languages = await service.listAvailableLanguages();

    expect(
      languages.map((entry) => entry.language.localeTag).toList(),
      <String>['en', 'zh'],
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
}
