import 'dart:convert';
import 'dart:io';

import '../contracts/app_contracts.dart';
import '../contracts/call_flow_contracts.dart';

class AppStateRepository implements AppStateContract {
  AppStateRepository({required DirectoryProvider directoryProvider})
    : _directoryProvider = directoryProvider;

  final DirectoryProvider _directoryProvider;

  static const String _fileName = 'app_state.json';
  static const String _selectedAudioLocaleKey = 'selectedAudioLocaleTag';
  static const String _selectedScenarioKey = 'selectedScenario';
  static const String _hasPremiumAccessKey = 'hasPremiumAccess';

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

  @override
  Future<Scenario?> getSelectedScenario() async {
    final data = await _readState();
    final rawScenario = data[_selectedScenarioKey];
    if (rawScenario is! String || rawScenario.isEmpty) {
      return null;
    }

    try {
      return Scenario.values.byName(rawScenario);
    } on ArgumentError {
      return null;
    }
  }

  @override
  Future<void> setSelectedScenario(Scenario scenario) async {
    final data = await _readState();
    data[_selectedScenarioKey] = scenario.name;
    await _writeState(data);
  }

  @override
  Future<bool> hasPremiumAccess() async {
    final data = await _readState();
    return data[_hasPremiumAccessKey] as bool? ?? false;
  }

  @override
  Future<void> setPremiumAccess(bool hasPremiumAccess) async {
    final data = await _readState();
    data[_hasPremiumAccessKey] = hasPremiumAccess;
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
