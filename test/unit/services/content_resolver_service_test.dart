import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/services/content_resolver_service.dart';

void main() {
  const service = ContentResolverService();

  test('returns fixed caller names for each scenario', () {
    expect(service.resolveCallerName(Scenario.presence), 'Xiao Chen');
    expect(service.resolveCallerName(Scenario.socialPull), 'Xiao Li');
    expect(service.resolveCallerName(Scenario.exitPressure), 'Xiao Zhang');
  });

  test('lists all required audio stages', () {
    final entries = service.listRequiredAudio();

    expect(entries.length, 7);
    expect(
      entries.any(
        (entry) =>
            entry.scenario == Scenario.presence &&
            entry.stage == 1 &&
            entry.scenarioDirectory == 'presence',
      ),
      isTrue,
    );
  });

  test('resolves bundled audio paths by locale and stage', () {
    expect(
      service.resolveBundledAudioAssetPath(
        localeTag: 'zh-TW',
        scenario: Scenario.socialPull,
        stage: 2,
      ),
      'assets/audio/zh-TW/social_pull/stage_2.m4a',
    );
  });

  test('rejects undefined stage mappings', () {
    expect(
      () => service.resolveAudioContent(
        scenario: Scenario.presence,
        stage: 2,
      ),
      throwsArgumentError,
    );
  });
}
