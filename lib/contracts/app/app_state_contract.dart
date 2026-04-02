import 'dart:io';

import '../call_flow/fake_call_timing_contract.dart';

typedef DirectoryProvider = Future<Directory> Function();

abstract class AppStateContract {
  Future<String?> getSelectedAudioLocaleTag();

  Future<void> setSelectedAudioLocaleTag(String localeTag);

  Future<Scenario?> getSelectedScenario();

  Future<void> setSelectedScenario(Scenario scenario);

  Future<bool> hasPremiumAccess();

  Future<void> setPremiumAccess(bool hasPremiumAccess);
}
