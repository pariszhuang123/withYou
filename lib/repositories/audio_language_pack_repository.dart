import 'dart:convert';
import 'dart:io';

import '../contracts/app_contracts.dart';
import '../contracts/audio_contracts.dart';
import '../models/audio_language.dart';

class AudioLanguagePackRepository implements AudioLanguagePackRepositoryContract {
  AudioLanguagePackRepository({required DirectoryProvider directoryProvider})
    : _directoryProvider = directoryProvider;

  final DirectoryProvider _directoryProvider;

  static const String _fileName = 'audio_language_packs.json';

  @override
  Future<List<AudioLanguagePackRecord>> getAllPacks() async {
    final file = await _file();
    if (!await file.exists()) {
      return const <AudioLanguagePackRecord>[];
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return const <AudioLanguagePackRecord>[];
    }

    final decoded = jsonDecode(raw) as List<Object?>;
    return decoded
        .map(
          (entry) => AudioLanguagePackRecord.fromJson(
            Map<String, Object?>.from(entry! as Map),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<AudioLanguagePackRecord?> getPack(String localeTag) async {
    final all = await getAllPacks();
    for (final pack in all) {
      if (pack.localeTag == localeTag) {
        return pack;
      }
    }
    return null;
  }

  @override
  Future<void> savePack(AudioLanguagePackRecord record) async {
    final all = (await getAllPacks()).toList(growable: true);
    final existingIndex = all.indexWhere((entry) => entry.localeTag == record.localeTag);
    if (existingIndex == -1) {
      all.add(record);
    } else {
      all[existingIndex] = record;
    }

    final file = await _file();
    await file.writeAsString(
      jsonEncode(all.map((entry) => entry.toJson()).toList(growable: false)),
    );
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    await directory.create(recursive: true);
    return File('${directory.path}${Platform.pathSeparator}$_fileName');
  }
}
