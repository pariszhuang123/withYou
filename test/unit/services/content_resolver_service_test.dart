import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/services/content_resolver_service.dart';

void main() {
  const service = ContentResolverService();

  test('returns localized caller names for each locale', () {
    expect(
      service.resolveCallerName(scenario: Scenario.presence, localeTag: 'en'),
      'Tommy',
    );
    expect(
      service.resolveCallerName(scenario: Scenario.socialPull, localeTag: 'en'),
      'Lily',
    );
    expect(
      service.resolveCallerName(
        scenario: Scenario.exitPressure,
        localeTag: 'en',
      ),
      'Zack',
    );
    expect(
      service.resolveCallerName(scenario: Scenario.presence, localeTag: 'zh'),
      '小陈',
    );
    expect(
      service.resolveCallerName(scenario: Scenario.socialPull, localeTag: 'zh'),
      '小李',
    );
    expect(
      service.resolveCallerName(
        scenario: Scenario.exitPressure,
        localeTag: 'zh',
      ),
      '小张',
    );
    expect(
      service.resolveCallerName(
        scenario: Scenario.presence,
        localeTag: 'zh-TW',
      ),
      '小陳',
    );
    expect(
      service.resolveCallerName(
        scenario: Scenario.socialPull,
        localeTag: 'zh-TW',
      ),
      '小李',
    );
    expect(
      service.resolveCallerName(
        scenario: Scenario.exitPressure,
        localeTag: 'zh-TW',
      ),
      '小張',
    );
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

  test('resolves bundled ringtone path', () {
    expect(
      service.resolveBundledRingtoneAssetPath(),
      'assets/audio/system/ringtone_loop.m4a',
    );
  });

  test('rejects undefined stage mappings', () {
    expect(
      () => service.resolveAudioContent(scenario: Scenario.presence, stage: 2),
      throwsArgumentError,
    );
  });
}
