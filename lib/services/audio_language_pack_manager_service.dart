import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../contracts/app_contracts.dart';
import '../contracts/audio_contracts.dart';
import '../contracts/call_flow_contracts.dart';
import '../contracts/platform_contracts.dart';
import '../models/audio_language.dart';
import '../models/playable_audio_source.dart';

typedef ManifestLoader = Future<Map<String, Object?>> Function();
typedef RemoteFileDownloader = Future<List<int>> Function(Uri uri);
typedef AssetAvailabilityChecker = Future<bool> Function(String assetPath);

class AudioLanguagePackManagerService
    implements AudioLanguagePackManagerContract {
  AudioLanguagePackManagerService({
    required AppStateContract appStateContract,
    required AudioLanguagePackRepositoryContract repository,
    required ContentResolverContract contentResolverContract,
    required KinlyLoggerContract logger,
    required DirectoryProvider directoryProvider,
    Uri? manifestUri,
    ManifestLoader? manifestLoader,
    RemoteFileDownloader? remoteFileDownloader,
    AssetAvailabilityChecker? assetAvailabilityChecker,
  }) : _appStateContract = appStateContract,
       _repository = repository,
       _contentResolverContract = contentResolverContract,
       _logger = logger,
       _directoryProvider = directoryProvider,
       _manifestUri = manifestUri,
       _manifestLoader = manifestLoader,
       _remoteFileDownloader = remoteFileDownloader,
       _assetAvailabilityChecker =
           assetAvailabilityChecker ?? _defaultAssetAvailabilityChecker;

  final AppStateContract _appStateContract;
  final AudioLanguagePackRepositoryContract _repository;
  final ContentResolverContract _contentResolverContract;
  final KinlyLoggerContract _logger;
  final DirectoryProvider _directoryProvider;
  final Uri? _manifestUri;
  final ManifestLoader? _manifestLoader;
  final RemoteFileDownloader? _remoteFileDownloader;
  final AssetAvailabilityChecker _assetAvailabilityChecker;

  static const List<AudioLanguage> _catalog = <AudioLanguage>[
    AudioLanguage(localeTag: 'en', displayName: 'English', isBundled: true),
    AudioLanguage(localeTag: 'zh', displayName: '简体中文', isBundled: true),
  ];

  @override
  Future<String> ensureSelectedLocale(List<Locale> preferredLocales) async {
    final availableLanguages = await _availableCatalog();
    final existing = await _appStateContract.getSelectedAudioLocaleTag();
    if (existing != null && _isKnownLocale(existing, availableLanguages)) {
      return existing;
    }

    final suggested = _resolveSuggestedLocale(
      preferredLocales,
      availableLanguages,
    );
    await _appStateContract.setSelectedAudioLocaleTag(suggested);
    return suggested;
  }

  @override
  Future<String?> getSelectedLocaleTag() {
    return _appStateContract.getSelectedAudioLocaleTag();
  }

  @override
  Future<void> selectLocale(String localeTag) async {
    final availableLanguages = await _availableCatalog();
    if (!_isKnownLocale(localeTag, availableLanguages)) {
      throw ArgumentError.value(
        localeTag,
        'localeTag',
        'Unsupported audio locale',
      );
    }
    await _appStateContract.setSelectedAudioLocaleTag(localeTag);
  }

  @override
  Future<List<AudioLanguageAvailability>> listAvailableLanguages() async {
    final availableLanguages = await _availableCatalog();
    final selected = await _appStateContract.getSelectedAudioLocaleTag();
    final records = await _repository.getAllPacks();
    final byLocale = <String, AudioLanguagePackRecord>{
      for (final record in records) record.localeTag: record,
    };

    return availableLanguages
        .map((language) {
          final status = language.isBundled
              ? AudioLanguagePackStatus.downloaded
              : byLocale[language.localeTag]?.status ??
                    AudioLanguagePackStatus.notDownloaded;
          return AudioLanguageAvailability(
            language: language,
            status: status,
            isSelected: language.localeTag == selected,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<void> downloadLanguagePack(String localeTag) async {
    AudioLanguage? language;
    for (final entry in _catalog) {
      if (entry.localeTag == localeTag) {
        language = entry;
        break;
      }
    }
    if (language == null) {
      throw ArgumentError.value(
        localeTag,
        'localeTag',
        'Unsupported audio locale',
      );
    }

    if (language.isBundled) {
      _logger.info(
        'Skipped download for bundled language $localeTag',
        category: 'audio',
      );
      return;
    }

    await _repository.savePack(
      AudioLanguagePackRecord(
        localeTag: localeTag,
        status: AudioLanguagePackStatus.downloading,
      ),
    );

    try {
      final manifest = await _loadManifest();
      final pack = _parseLanguagePack(manifest, localeTag);
      await _downloadPack(pack);
      await _repository.savePack(
        AudioLanguagePackRecord(
          localeTag: localeTag,
          status: AudioLanguagePackStatus.downloaded,
          version: pack.version,
          checksum: pack.checksum,
          localRootPath: (await _packDirectory(localeTag)).path,
          downloadedAtUtc: DateTime.now().toUtc(),
        ),
      );
      _logger.info('Downloaded language pack $localeTag', category: 'audio');
    } catch (error, stackTrace) {
      await _repository.savePack(
        AudioLanguagePackRecord(
          localeTag: localeTag,
          status: AudioLanguagePackStatus.failed,
        ),
      );
      _logger.error(
        'Failed to download language pack $localeTag',
        category: 'audio',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<ResolvedPlayableAudio> resolvePlayableAudio({
    required Scenario scenario,
    required int stage,
  }) async {
    final selectedLocale =
        await _appStateContract.getSelectedAudioLocaleTag() ?? 'en';
    final fallbackChain = _fallbackChain(selectedLocale);
    for (final localeTag in fallbackChain) {
      if (_isBundled(localeTag)) {
        final assetPath = _contentResolverContract.resolveBundledAudioAssetPath(
          localeTag: localeTag,
          scenario: scenario,
          stage: stage,
        );
        if (!await _assetAvailabilityChecker(assetPath)) {
          _logger.warn(
            'Bundled audio asset unavailable for $localeTag ${scenario.name} stage $stage at $assetPath',
            category: 'audio',
          );
          continue;
        }
        if (localeTag != selectedLocale) {
          _logger.warn(
            'Falling back from $selectedLocale to $localeTag for ${scenario.name} stage $stage',
            category: 'audio',
          );
        }
        return ResolvedPlayableAudio(
          localeTag: localeTag,
          source: BundledAudioSource(assetPath: assetPath),
        );
      }

      final record = await _repository.getPack(localeTag);
      if (record == null ||
          !record.isReadyOffline ||
          record.localRootPath == null) {
        continue;
      }

      final descriptor = _contentResolverContract.resolveAudioContent(
        scenario: scenario,
        stage: stage,
      );
      final file = File(
        '${record.localRootPath!}${Platform.pathSeparator}${descriptor.scenarioDirectory}${Platform.pathSeparator}stage_$stage.m4a',
      );
      if (await file.exists()) {
        if (localeTag != selectedLocale) {
          _logger.warn(
            'Falling back from $selectedLocale to $localeTag for ${scenario.name} stage $stage',
            category: 'audio',
          );
        }
        return ResolvedPlayableAudio(
          localeTag: localeTag,
          source: FileAudioSource(filePath: file.path),
        );
      }
    }

    _logger.error(
      'No local audio source available for ${scenario.name} stage $stage',
      category: 'audio',
    );
    throw StateError(
      'No local audio source available for ${scenario.name} stage $stage',
    );
  }

  String _resolveSuggestedLocale(
    List<Locale> preferredLocales,
    List<AudioLanguage> availableLanguages,
  ) {
    for (final locale in preferredLocales) {
      final exactTag = _localeTag(locale);
      if (_isKnownLocale(exactTag, availableLanguages)) {
        return exactTag;
      }
      if (locale.languageCode == 'zh' &&
          _isKnownLocale('zh', availableLanguages)) {
        return 'zh';
      }
    }

    if (_isKnownLocale('en', availableLanguages)) {
      return 'en';
    }
    if (availableLanguages.isNotEmpty) {
      return availableLanguages.first.localeTag;
    }
    return 'en';
  }

  List<String> _fallbackChain(String localeTag) {
    final chain = <String>[];
    if (_isKnownLocale(localeTag, _catalog)) {
      chain.add(localeTag);
    }

    final dashIndex = localeTag.indexOf('-');
    if (dashIndex > 0) {
      final base = localeTag.substring(0, dashIndex);
      if (!chain.contains(base) && _isKnownLocale(base, _catalog)) {
        chain.add(base);
      }
    }

    if (localeTag.startsWith('zh') && !chain.contains('zh')) {
      chain.add('zh');
    }

    if (!chain.contains('en')) {
      chain.add('en');
    }

    return chain;
  }

  bool _isKnownLocale(String localeTag, List<AudioLanguage> languages) {
    return languages.any((entry) => entry.localeTag == localeTag);
  }

  bool _isBundled(String localeTag) {
    return _catalog.any(
      (entry) => entry.localeTag == localeTag && entry.isBundled,
    );
  }

  String _localeTag(Locale locale) {
    final countryCode = locale.countryCode;
    if (countryCode != null && countryCode.isNotEmpty) {
      return '${locale.languageCode}-$countryCode';
    }
    return locale.languageCode;
  }

  Future<List<AudioLanguage>> _availableCatalog() async {
    final available = <AudioLanguage>[];
    for (final language in _catalog) {
      if (!language.isBundled || await _hasBundledAssets(language.localeTag)) {
        available.add(language);
      }
    }
    return available;
  }

  Future<bool> _hasBundledAssets(String localeTag) async {
    for (final descriptor in _contentResolverContract.listRequiredAudio()) {
      final assetPath = _contentResolverContract.resolveBundledAudioAssetPath(
        localeTag: localeTag,
        scenario: descriptor.scenario,
        stage: descriptor.stage,
      );
      if (await _assetAvailabilityChecker(assetPath)) {
        return true;
      }
    }
    return false;
  }

  Future<Map<String, Object?>> _loadManifest() async {
    if (_manifestLoader != null) {
      return _manifestLoader();
    }

    final manifestUri = _manifestUri;
    if (manifestUri == null || manifestUri.toString().isEmpty) {
      throw StateError('Audio manifest URL is not configured');
    }

    final bytes = await _downloadBytes(manifestUri);
    return Map<String, Object?>.from(jsonDecode(utf8.decode(bytes)) as Map);
  }

  _ManifestLanguagePack _parseLanguagePack(
    Map<String, Object?> manifest,
    String localeTag,
  ) {
    final rawLanguages = Map<String, Object?>.from(
      manifest['languages']! as Map,
    );
    final rawPack = rawLanguages[localeTag];
    if (rawPack == null) {
      throw StateError('No manifest pack found for $localeTag');
    }

    final packJson = Map<String, Object?>.from(rawPack as Map);
    final rawEntries = (packJson['entries']! as List<Object?>)
        .map((entry) => Map<String, Object?>.from(entry! as Map))
        .toList(growable: false);

    final entries = rawEntries
        .map(
          (entry) => _ManifestAudioEntry(
            scenario: Scenario.values.byName(entry['scenario']! as String),
            stage: entry['stage']! as int,
            url: Uri.parse(entry['url']! as String),
            checksum: entry['checksum'] as String?,
          ),
        )
        .toList(growable: false);

    final required = _contentResolverContract.listRequiredAudio();
    for (final descriptor in required) {
      final exists = entries.any(
        (entry) =>
            entry.scenario == descriptor.scenario &&
            entry.stage == descriptor.stage,
      );
      if (!exists) {
        throw StateError(
          'Language pack $localeTag is incomplete for ${descriptor.scenario.name} stage ${descriptor.stage}',
        );
      }
    }

    return _ManifestLanguagePack(
      localeTag: localeTag,
      version: packJson['version']! as String,
      checksum: packJson['checksum'] as String?,
      entries: entries,
    );
  }

  Future<void> _downloadPack(_ManifestLanguagePack pack) async {
    final packDirectory = await _packDirectory(pack.localeTag);
    if (await packDirectory.exists()) {
      await packDirectory.delete(recursive: true);
    }
    await packDirectory.create(recursive: true);

    for (final entry in pack.entries) {
      final descriptor = _contentResolverContract.resolveAudioContent(
        scenario: entry.scenario,
        stage: entry.stage,
      );
      final targetDirectory = Directory(
        '${packDirectory.path}${Platform.pathSeparator}${descriptor.scenarioDirectory}',
      );
      await targetDirectory.create(recursive: true);
      final targetFile = File(
        '${targetDirectory.path}${Platform.pathSeparator}stage_${entry.stage}.m4a',
      );
      final bytes = await _downloadBytes(entry.url);
      if (entry.checksum != null) {
        final digest = sha256.convert(bytes).toString();
        if (digest != entry.checksum) {
          throw StateError(
            'Checksum mismatch for ${pack.localeTag} ${entry.scenario.name} stage ${entry.stage}',
          );
        }
      }
      await targetFile.writeAsBytes(bytes, flush: true);
    }
  }

  Future<Directory> _packDirectory(String localeTag) async {
    final root = await _directoryProvider();
    final packsRoot = Directory(
      '${root.path}${Platform.pathSeparator}audio_language_packs',
    );
    await packsRoot.create(recursive: true);
    return Directory('${packsRoot.path}${Platform.pathSeparator}$localeTag');
  }

  Future<List<int>> _downloadBytes(Uri uri) async {
    if (_remoteFileDownloader != null) {
      return _remoteFileDownloader(uri);
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Request failed with status ${response.statusCode}',
          uri: uri,
        );
      }

      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
      }
      return bytes;
    } finally {
      client.close(force: true);
    }
  }

  static Future<bool> _defaultAssetAvailabilityChecker(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }
}

class _ManifestLanguagePack {
  const _ManifestLanguagePack({
    required this.localeTag,
    required this.version,
    required this.checksum,
    required this.entries,
  });

  final String localeTag;
  final String version;
  final String? checksum;
  final List<_ManifestAudioEntry> entries;
}

class _ManifestAudioEntry {
  const _ManifestAudioEntry({
    required this.scenario,
    required this.stage,
    required this.url,
    required this.checksum,
  });

  final Scenario scenario;
  final int stage;
  final Uri url;
  final String? checksum;
}
