import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/repositories/app_state_repository.dart';

void main() {
  late Directory tempDirectory;
  late AppStateRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('app_state_repo_test');
    repository = AppStateRepository(directoryProvider: () async => tempDirectory);
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('selected audio locale persists across reads', () async {
    expect(await repository.getSelectedAudioLocaleTag(), isNull);

    await repository.setSelectedAudioLocaleTag('zh-TW');

    expect(await repository.getSelectedAudioLocaleTag(), 'zh-TW');
  });

  test('selected scenario persists across reads', () async {
    expect(await repository.getSelectedScenario(), isNull);

    await repository.setSelectedScenario(Scenario.exitPressure);

    expect(await repository.getSelectedScenario(), Scenario.exitPressure);
  });

  test('premium access persists across reads', () async {
    expect(await repository.hasPremiumAccess(), isFalse);

    await repository.setPremiumAccess(true);

    expect(await repository.hasPremiumAccess(), isTrue);
  });
}
