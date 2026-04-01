import 'dart:convert';
import 'dart:io';

import '../contracts/app_state_contract.dart';

typedef DirectoryProvider = Future<Directory> Function();

class AppStateRepository implements AppStateContract {
  AppStateRepository({required DirectoryProvider directoryProvider})
    : _directoryProvider = directoryProvider;

  final DirectoryProvider _directoryProvider;

  static const String _fileName = 'app_state.json';
  static const String _selectedAudioLocaleKey = 'selectedAudioLocaleTag';

  @override
  Future<String?> getSelectedAudioLocaleTag() async {
    final data = await _readState();
    return data[_selectedAudioLocaleKey] as String?;
  }

  @override
  Future<void> setSelectedAudioLocaleTag(String localeTag) async {
    final data = await _readState();
    data[_selectedAudioLocaleKey] = localeTag;
    await _writeState(data);
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    await directory.create(recursive: true);
    return File('${directory.path}${Platform.pathSeparator}$_fileName');
  }

  Future<Map<String, Object?>> _readState() async {
    final file = await _file();
    if (!await file.exists()) {
      return <String, Object?>{};
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return <String, Object?>{};
    }

    final decoded = jsonDecode(raw);
    return Map<String, Object?>.from(decoded as Map);
  }

  Future<void> _writeState(Map<String, Object?> data) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(data));
  }
}
