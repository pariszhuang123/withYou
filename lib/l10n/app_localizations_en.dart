// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeSubtitle => 'Always with you';

  @override
  String get settings => 'Settings';

  @override
  String get scenarioSelector => 'Select Scenario';

  @override
  String get scenarioPresence => 'Presence';

  @override
  String get scenarioSocialPull => 'Social Pull';

  @override
  String get scenarioExitPressure => 'Exit Pressure';

  @override
  String get incomingCall => 'Incoming call';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get audioLanguageSectionTitle => 'Audio language';

  @override
  String get audioLanguageSectionSubtitle =>
      'Download a language pack before you need it so support audio works offline.';

  @override
  String get audioLanguageReady => 'Ready offline';

  @override
  String get audioLanguageNotDownloaded => 'Download required';

  @override
  String get audioLanguageDownloading => 'Downloading...';

  @override
  String get audioLanguageFailed => 'Download failed';

  @override
  String get audioLanguageDownload => 'Download';

  @override
  String get audioLanguageSelected => 'Selected';

  @override
  String get audioLanguageFallbackHint =>
      'If the selected language is not ready offline, playback falls back to available local Chinese, then English.';
}
