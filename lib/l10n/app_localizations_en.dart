// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeSubtitle => 'Always with you';

  @override
  String get settings => 'Settings';

  @override
  String get appLogoSemanticLabel => 'withYou app logo';

  @override
  String get homeOpenSettingsSemanticLabel => 'Open settings';

  @override
  String get homeSupportStyleTitle => 'What do you need right now?';

  @override
  String get homeSupportStyleGentle => '👀 Stay with me';

  @override
  String get homeSupportStyleSteady => '🕒 Ease me out';

  @override
  String get homeSupportStyleUrgent => '🚪 Get me out';

  @override
  String get scenarioSelector => 'Select Scenario';

  @override
  String get scenarioPresence => '👀 Stay with me';

  @override
  String get scenarioSocialPull => '🕒 Ease me out';

  @override
  String get scenarioExitPressure => '🚪 Get me out';

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
  String get notificationsSectionHelper =>
      'Needed for 🕒 Ease me out and 🚪 Get me out.';

  @override
  String get notificationsPermissionDialogTitle => 'Turn on notifications';

  @override
  String get notificationsPermissionDialogBody =>
      '🕒 Ease me out and 🚪 Get me out need notifications before follow-up calls can come through.';

  @override
  String get notificationsPermissionDialogNotNow => 'Not now';

  @override
  String get notificationsPermissionDialogContinue => 'Continue';

  @override
  String get notificationsPermissionStillOff => 'Notifications are still off.';

  @override
  String get homeTriggerHint => 'Tap when you need me.';

  @override
  String get homeStartCallSemanticLabel => 'Start selected support call';

  @override
  String get upgradeToPremium => 'Unlock Premium';

  @override
  String get premiumActive => 'Premium active';

  @override
  String get premiumActiveMessage =>
      'Premium is active. You can use all features.';

  @override
  String get paywallTitle => 'Unlock Premium';

  @override
  String get paywallHeadline =>
      'Unlock follow-up calls for 🕒 Ease me out and 🚪 Get me out';

  @override
  String get paywallBody =>
      'Get extra support when you need it: 🕒 Ease me out keeps the interruption going, 🚪 Get me out helps you leave faster, and the home-screen widget lets you trigger a call with one touch.';

  @override
  String get paywallStoreNote =>
      'One-time purchase. Premium keeps 🕒 Ease me out, 🚪 Get me out, and widget support ready when you need it.';

  @override
  String get paywallSeePrice => 'See price';

  @override
  String get paywallRestore => 'Restore purchase';

  @override
  String get paywallRestoreFailed => 'No premium purchase was restored.';

  @override
  String get paywallBenefitSocialPullTitle => '🕒 Ease me out';

  @override
  String get paywallBenefitSocialPullBody =>
      'Start a call now, then keep the interruption going with two follow-up calls.';

  @override
  String get paywallBenefitExitPressureTitle => '🚪 Get me out';

  @override
  String get paywallBenefitExitPressureBody =>
      'Use a faster sequence of follow-up calls when you need to leave now.';

  @override
  String get paywallBenefitWidgetTitle => 'Home-screen widget';

  @override
  String get paywallBenefitWidgetBody =>
      'Trigger your selected support call from the home screen with one touch when you need it fast.';

  @override
  String get widgetSetupTitle => 'Home-screen widget';

  @override
  String get widgetSetupLockedBody =>
      'Unlock Premium to add a one-tap widget that starts your selected support call.';

  @override
  String get widgetSetupReadyBody =>
      'Add the widget from your phone\'s widget gallery for one-tap support when you need it fast.';

  @override
  String get widgetSetupUnavailableBody =>
      'Home-screen widgets are unavailable on this device.';

  @override
  String get widgetSetupUnlockAction => 'Unlock one-tap widget';

  @override
  String get widgetSetupReadyLabel => 'Widget ready';

  @override
  String get paywallBenefitPresenceBody =>
      'One immediate call when you just need someone with you.';

  @override
  String get notificationFollowUpBody => 'Tap to answer your support call.';

  @override
  String get audioLanguageUpdateAvailable => 'Update available';

  @override
  String get languageTraditionalChinese => '繁体字';

  @override
  String get awaitingStageTitle => 'I’ll check in again soon.';

  @override
  String awaitingStageBody(Object stage) {
    return 'Stage $stage is waiting on the local notification timer.';
  }

  @override
  String get awaitingStageReady => 'The next follow-up can open now.';

  @override
  String awaitingStageCountdown(Object remaining) {
    return 'Ready in $remaining';
  }

  @override
  String get callAvatarSemanticLabel => 'Caller avatar';

  @override
  String get callActionHang => 'Hang';

  @override
  String get callActionDial => 'Dial';

  @override
  String get callActionEnd => 'End';

  @override
  String get callDeclineSemanticLabel => 'Decline support call';

  @override
  String get callAcceptSemanticLabel => 'Accept support call';

  @override
  String get callEndSemanticLabel => 'End support call';

  @override
  String get callerNamePresence => 'Tommy';

  @override
  String get callerNameSocialPull => 'Benjamin';

  @override
  String get callerNameExitPressure => 'Zack';
}
