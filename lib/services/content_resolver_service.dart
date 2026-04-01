import '../contracts/content_resolver_contract.dart';
import '../contracts/fake_call_timing_contract.dart';

class ContentResolverService implements ContentResolverContract {
  const ContentResolverService();

  static const List<AudioContentDescriptor> _requiredAudio =
      <AudioContentDescriptor>[
        AudioContentDescriptor(
          scenario: Scenario.presence,
          stage: 1,
          scenarioDirectory: 'presence',
        ),
        AudioContentDescriptor(
          scenario: Scenario.socialPull,
          stage: 1,
          scenarioDirectory: 'social_pull',
        ),
        AudioContentDescriptor(
          scenario: Scenario.socialPull,
          stage: 2,
          scenarioDirectory: 'social_pull',
        ),
        AudioContentDescriptor(
          scenario: Scenario.socialPull,
          stage: 3,
          scenarioDirectory: 'social_pull',
        ),
        AudioContentDescriptor(
          scenario: Scenario.exitPressure,
          stage: 1,
          scenarioDirectory: 'exit_pressure',
        ),
        AudioContentDescriptor(
          scenario: Scenario.exitPressure,
          stage: 2,
          scenarioDirectory: 'exit_pressure',
        ),
        AudioContentDescriptor(
          scenario: Scenario.exitPressure,
          stage: 3,
          scenarioDirectory: 'exit_pressure',
        ),
      ];

  @override
  List<AudioContentDescriptor> listRequiredAudio() => _requiredAudio;

  @override
  String resolveCallerName(Scenario scenario) {
    switch (scenario) {
      case Scenario.presence:
        return 'Xiao Chen';
      case Scenario.socialPull:
        return 'Xiao Li';
      case Scenario.exitPressure:
        return 'Xiao Zhang';
    }
  }

  @override
  AudioContentDescriptor resolveAudioContent({
    required Scenario scenario,
    required int stage,
  }) {
    for (final descriptor in _requiredAudio) {
      if (descriptor.scenario == scenario && descriptor.stage == stage) {
        return descriptor;
      }
    }

    throw ArgumentError.value(
      stage,
      'stage',
      'No audio content defined for ${scenario.name} stage $stage',
    );
  }

  @override
  String resolveBundledAudioAssetPath({
    required String localeTag,
    required Scenario scenario,
    required int stage,
  }) {
    final descriptor = resolveAudioContent(scenario: scenario, stage: stage);
    return 'assets/audio/$localeTag/${descriptor.scenarioDirectory}/stage_$stage.m4a';
  }
}
