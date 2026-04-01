import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/kinly_logger_contract.dart';
import 'package:with_you/contracts/fake_call_timing_contract.dart';
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
  late Map<Uri, List<int>> downloads;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('audio_pack_manager_test');
    appStateRepository = AppStateRepository(
      directoryProvider: () async => tempDirectory,
    );
    packRepository = AudioLanguagePackRepository(
      directoryProvider: () async => tempDirectory,
    );
    logger = _TestLogger();
    downloads = <Uri, List<int>>{};

    service = AudioLanguagePackManagerService(
      appStateContract: appStateRepository,
      repository: packRepository,
      contentResolverContract: const ContentResolverService(),
      logger: logger,
      directoryProvider: () async => tempDirectory,
      manifestLoader: () async => _buildManifest(downloads),
      remoteFileDownloader: (uri) async => downloads[uri]!,
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('ensureSelectedLocale prefers exact locale then persists it', () async {
    final localeTag = await service.ensureSelectedLocale(
      const <Locale>[Locale('zh', 'TW')],
    );

    expect(localeTag, 'zh-TW');
    expect(await appStateRepository.getSelectedAudioLocaleTag(), 'zh-TW');
  });

  test('listAvailableLanguages marks bundled languages as ready offline', () async {
    await appStateRepository.setSelectedAudioLocaleTag('zh');

    final languages = await service.listAvailableLanguages();
    final zh = languages.firstWhere((entry) => entry.language.localeTag == 'zh');
    final zhTw = languages.firstWhere(
      (entry) => entry.language.localeTag == 'zh-TW',
    );

    expect(zh.status, AudioLanguagePackStatus.downloaded);
    expect(zh.isReadyOffline, isTrue);
    expect(zhTw.status, AudioLanguagePackStatus.notDownloaded);
  });

  test('downloadLanguagePack saves all files locally and marks locale ready', () async {
    await service.downloadLanguagePack('zh-TW');

    final record = await packRepository.getPack('zh-TW');
    expect(record, isNotNull);
    expect(record!.status, AudioLanguagePackStatus.downloaded);

    final file = File(
      '${record.localRootPath!}${Platform.pathSeparator}social_pull${Platform.pathSeparator}stage_2.m4a',
    );
    expect(await file.exists(), isTrue);
  });

  test('resolvePlayableAudio uses downloaded exact locale before zh fallback', () async {
    await appStateRepository.setSelectedAudioLocaleTag('zh-TW');
    await service.downloadLanguagePack('zh-TW');

    final resolved = await service.resolvePlayableAudio(
      scenario: Scenario.socialPull,
      stage: 1,
    );

    expect(resolved.localeTag, 'zh-TW');
    expect(resolved.source, isA<FileAudioSource>());
  });

  test('resolvePlayableAudio falls back to bundled zh when exact locale is absent', () async {
    await appStateRepository.setSelectedAudioLocaleTag('zh-TW');

    final resolved = await service.resolvePlayableAudio(
      scenario: Scenario.presence,
      stage: 1,
    );

    expect(resolved.localeTag, 'zh');
    expect((resolved.source as BundledAudioSource).assetPath, contains('assets/audio/zh/'));
    expect(logger.warnings.single, contains('Falling back'));
  });
}

Future<Map<String, Object?>> _buildManifest(Map<Uri, List<int>> downloads) async {
  final entries = <Map<String, Object?>>[];
  final scenarios = <(String, int)>[
    ('presence', 1),
    ('socialPull', 1),
    ('socialPull', 2),
    ('socialPull', 3),
    ('exitPressure', 1),
    ('exitPressure', 2),
    ('exitPressure', 3),
  ];

  for (final entry in scenarios) {
    final fileUri = Uri.parse(
      'https://example.com/${entry.$1}_stage_${entry.$2}.m4a',
    );
    final bytes = utf8.encode('${entry.$1}-${entry.$2}');
    downloads[fileUri] = bytes;
    entries.add(<String, Object?>{
      'scenario': entry.$1,
      'stage': entry.$2,
      'url': fileUri.toString(),
      'checksum': sha256.convert(bytes).toString(),
    });
  }

  return <String, Object?>{
    'languages': <String, Object?>{
      'zh-TW': <String, Object?>{
        'version': '2026-04-02',
        'checksum': 'pack-checksum',
        'entries': entries,
      },
    },
  };
}
