import 'package:flutter/widgets.dart';

import '../contracts/audio_contracts.dart';
import '../contracts/call_flow_contracts.dart';
import '../l10n/app_localizations.dart';

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
  String resolveCallerName({
    required Scenario scenario,
    required String localeTag,
  }) {
    final localizations = _localizationsFor(localeTag);
    switch (scenario) {
      case Scenario.presence:
        return localizations.callerNamePresence;
      case Scenario.socialPull:
        return localizations.callerNameSocialPull;
      case Scenario.exitPressure:
        return localizations.callerNameExitPressure;
    }
  }

  @override
  String resolveFollowUpNotificationBody({
    required Scenario scenario,
    required int stage,
    required String localeTag,
  }) {
    final localizations = _localizationsFor(localeTag);
    return localizations.notificationFollowUpBody;
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

  @override
  String resolveBundledRingtoneAssetPath() {
    return 'assets/audio/system/ringtone_loop.mp3';
  }

  AppLocalizations _localizationsFor(String localeTag) {
    final localeParts = localeTag.replaceAll('_', '-').split('-');
    return lookupAppLocalizations(
      Locale.fromSubtags(
        languageCode: localeParts.first,
        countryCode: localeParts.length > 1 ? localeParts[1] : null,
      ),
    );
  }
}
