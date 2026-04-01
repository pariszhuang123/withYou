import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/models/audio_language.dart';
import 'package:with_you/repositories/audio_language_pack_repository.dart';

void main() {
  late Directory tempDirectory;
  late AudioLanguagePackRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('audio_pack_repo_test');
    repository = AudioLanguagePackRepository(
      directoryProvider: () async => tempDirectory,
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('savePack upserts and reloads metadata', () async {
    await repository.savePack(
      AudioLanguagePackRecord(
        localeTag: 'zh-TW',
        status: AudioLanguagePackStatus.downloaded,
        version: '1',
        checksum: 'abc',
        localRootPath: '/tmp/zh-TW',
        downloadedAtUtc: DateTime.utc(2026, 4, 2),
      ),
    );

    final saved = await repository.getPack('zh-TW');

    expect(saved, isNotNull);
    expect(saved!.status, AudioLanguagePackStatus.downloaded);
    expect(saved.version, '1');
  });
}
