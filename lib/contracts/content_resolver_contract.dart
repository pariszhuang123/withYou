import 'fake_call_timing_contract.dart';

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
  String resolveCallerName(Scenario scenario);

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
}
