import '../call_flow/fake_call_timing_contract.dart';

class AudioContentDescriptor {
  const AudioContentDescriptor({
    required this.scenario,
    required this.stage,
    required this.scenarioDirectory,
  });

  final Scenario scenario;
  final int stage;
  final String scenarioDirectory;
}

abstract class ContentResolverContract {
  String resolveCallerName({
    required Scenario scenario,
    required String localeTag,
  });

  String resolveFollowUpNotificationBody({
    required Scenario scenario,
    required int stage,
    required String localeTag,
  });

  AudioContentDescriptor resolveAudioContent({
    required Scenario scenario,
    required int stage,
  });

  List<AudioContentDescriptor> listRequiredAudio();

  String resolveBundledAudioAssetPath({
    required String localeTag,
    required Scenario scenario,
    required int stage,
  });

  String resolveBundledRingtoneAssetPath();
}
