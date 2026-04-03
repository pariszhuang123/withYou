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
      'English and Simplified Chinese are ready offline. Korean downloads will come later.';

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

  @override
  String get notificationsSectionTitle => 'Notifications';

  @override
  String get notificationsSectionEnabled => 'Follow-up notifications are on.';

  @override
  String get notificationsSectionNeedsPermission =>
      'Turn on notifications for follow-up calls.';

  @override
  String get notificationsSectionUnavailable =>
      'Notifications are unavailable on this device.';

  @override
  String get notificationsSectionTurnOn => 'Turn on notifications';

  @override
  String get notificationsSectionManage => 'Open system settings';

  @override
  String get notificationsSectionHelper => 'Needed for Steady and Urgent.';

  @override
  String get homeTriggerHint => 'Tap the logo to start';

  @override
  String get homeStartCallSemanticLabel => 'Start selected support call';

  @override
  String get upgradeToPremium => 'Upgrade to premium';

  @override
  String get premiumActive => 'Premium active';

  @override
  String get premiumActiveMessage =>
      'Premium is active. You can use all features.';

  @override
  String get paywallTitle => 'Upgrade to premium';

  @override
  String get paywallHeadline => 'Unlock steady and urgent follow-up calls';

  @override
  String get paywallBody =>
      'Get extra support when you are stuck: steady follow-up calls keep the interruption going, urgent follow-up calls help you get out quickly, and the home-screen widget lets you trigger a call with one touch.';

  @override
  String get paywallStoreNote =>
      'Premium keeps steady, urgent, and widget support ready when you need it.';

  @override
  String get paywallSeePrice => 'Upgrade to premium';

  @override
  String get paywallRestore => 'Restore purchase';

  @override
  String get paywallRestoreFailed => 'No premium purchase was restored.';

  @override
  String get paywallBenefitSocialPullTitle => 'Steady support';

  @override
  String get paywallBenefitSocialPullBody =>
      'Start a call now, then keep the interruption going with two follow-up calls.';

  @override
  String get paywallBenefitExitPressureTitle => 'Urgent support';

  @override
  String get paywallBenefitExitPressureBody =>
      'Use a faster sequence of follow-up calls when you want to get out quickly.';

  @override
  String get paywallBenefitWidgetTitle => 'Home-screen widget';

  @override
  String get paywallBenefitWidgetBody =>
      'Trigger your selected support call from the home screen with one touch when you need it fast.';

  @override
  String get notificationFollowUpBody => 'Tap to answer your support call.';

  @override
  String get callerNamePresence => 'Tommy';

  @override
  String get callerNameSocialPull => 'Benjamin';

  @override
  String get callerNameExitPressure => 'Zack';
}
