import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';
import 'app_localizations_zh_tw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always with you'**
  String get homeSubtitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appLogoSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'withYou app logo'**
  String get appLogoSemanticLabel;

  /// No description provided for @homeOpenSettingsSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get homeOpenSettingsSemanticLabel;

  /// No description provided for @homeSupportStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose support style'**
  String get homeSupportStyleTitle;

  /// No description provided for @homeSupportStyleGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get homeSupportStyleGentle;

  /// No description provided for @homeSupportStyleSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get homeSupportStyleSteady;

  /// No description provided for @homeSupportStyleUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get homeSupportStyleUrgent;

  /// No description provided for @scenarioSelector.
  ///
  /// In en, this message translates to:
  /// **'Select Scenario'**
  String get scenarioSelector;

  /// No description provided for @scenarioPresence.
  ///
  /// In en, this message translates to:
  /// **'Presence'**
  String get scenarioPresence;

  /// No description provided for @scenarioSocialPull.
  ///
  /// In en, this message translates to:
  /// **'Social Pull'**
  String get scenarioSocialPull;

  /// No description provided for @scenarioExitPressure.
  ///
  /// In en, this message translates to:
  /// **'Exit Pressure'**
  String get scenarioExitPressure;

  /// No description provided for @incomingCall.
  ///
  /// In en, this message translates to:
  /// **'Incoming call'**
  String get incomingCall;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @audioLanguageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio language'**
  String get audioLanguageSectionTitle;

  /// No description provided for @audioLanguageSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'English and Simplified Chinese are ready offline. Korean downloads will come later.'**
  String get audioLanguageSectionSubtitle;

  /// No description provided for @audioLanguageReady.
  ///
  /// In en, this message translates to:
  /// **'Ready offline'**
  String get audioLanguageReady;

  /// No description provided for @audioLanguageNotDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Download required'**
  String get audioLanguageNotDownloaded;

  /// No description provided for @audioLanguageDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get audioLanguageDownloading;

  /// No description provided for @audioLanguageFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get audioLanguageFailed;

  /// No description provided for @audioLanguageDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get audioLanguageDownload;

  /// No description provided for @audioLanguageSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get audioLanguageSelected;

  /// No description provided for @audioLanguageFallbackHint.
  ///
  /// In en, this message translates to:
  /// **'If the selected language is not ready offline, playback falls back to available local Chinese, then English.'**
  String get audioLanguageFallbackHint;

  /// No description provided for @notificationsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSectionTitle;

  /// No description provided for @notificationsSectionEnabled.
  ///
  /// In en, this message translates to:
  /// **'Follow-up notifications are on.'**
  String get notificationsSectionEnabled;

  /// No description provided for @notificationsSectionNeedsPermission.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications for follow-up calls.'**
  String get notificationsSectionNeedsPermission;

  /// No description provided for @notificationsSectionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Notifications are unavailable on this device.'**
  String get notificationsSectionUnavailable;

  /// No description provided for @notificationsSectionTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications'**
  String get notificationsSectionTurnOn;

  /// No description provided for @notificationsSectionManage.
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get notificationsSectionManage;

  /// No description provided for @notificationsSectionHelper.
  ///
  /// In en, this message translates to:
  /// **'Needed for Steady and Urgent.'**
  String get notificationsSectionHelper;

  /// No description provided for @notificationsPermissionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications'**
  String get notificationsPermissionDialogTitle;

  /// No description provided for @notificationsPermissionDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Steady and urgent need notifications before the follow-up calls can arrive.'**
  String get notificationsPermissionDialogBody;

  /// No description provided for @notificationsPermissionDialogNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notificationsPermissionDialogNotNow;

  /// No description provided for @notificationsPermissionDialogContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get notificationsPermissionDialogContinue;

  /// No description provided for @notificationsPermissionStillOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are still off.'**
  String get notificationsPermissionStillOff;

  /// No description provided for @homeTriggerHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the logo to start'**
  String get homeTriggerHint;

  /// No description provided for @homeStartCallSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Start selected support call'**
  String get homeStartCallSemanticLabel;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium'**
  String get upgradeToPremium;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium active'**
  String get premiumActive;

  /// No description provided for @premiumActiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Premium is active. You can use all features.'**
  String get premiumActiveMessage;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium'**
  String get paywallTitle;

  /// No description provided for @paywallHeadline.
  ///
  /// In en, this message translates to:
  /// **'Unlock steady and urgent follow-up calls'**
  String get paywallHeadline;

  /// No description provided for @paywallBody.
  ///
  /// In en, this message translates to:
  /// **'Get extra support when you are stuck: steady follow-up calls keep the interruption going, urgent follow-up calls help you get out quickly, and the home-screen widget lets you trigger a call with one touch.'**
  String get paywallBody;

  /// No description provided for @paywallStoreNote.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase. Premium keeps steady, urgent, and widget support ready when you need it.'**
  String get paywallStoreNote;

  /// No description provided for @paywallSeePrice.
  ///
  /// In en, this message translates to:
  /// **'See price'**
  String get paywallSeePrice;

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get paywallRestore;

  /// No description provided for @paywallRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'No premium purchase was restored.'**
  String get paywallRestoreFailed;

  /// No description provided for @paywallBenefitSocialPullTitle.
  ///
  /// In en, this message translates to:
  /// **'Steady support'**
  String get paywallBenefitSocialPullTitle;

  /// No description provided for @paywallBenefitSocialPullBody.
  ///
  /// In en, this message translates to:
  /// **'Start a call now, then keep the interruption going with two follow-up calls.'**
  String get paywallBenefitSocialPullBody;

  /// No description provided for @paywallBenefitExitPressureTitle.
  ///
  /// In en, this message translates to:
  /// **'Urgent support'**
  String get paywallBenefitExitPressureTitle;

  /// No description provided for @paywallBenefitExitPressureBody.
  ///
  /// In en, this message translates to:
  /// **'Use a faster sequence of follow-up calls when you want to get out quickly.'**
  String get paywallBenefitExitPressureBody;

  /// No description provided for @paywallBenefitWidgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Home-screen widget'**
  String get paywallBenefitWidgetTitle;

  /// No description provided for @paywallBenefitWidgetBody.
  ///
  /// In en, this message translates to:
  /// **'Trigger your selected support call from the home screen with one touch when you need it fast.'**
  String get paywallBenefitWidgetBody;

  /// No description provided for @widgetSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Home-screen widget'**
  String get widgetSetupTitle;

  /// No description provided for @widgetSetupLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium to add a one-tap widget that starts your selected support call.'**
  String get widgetSetupLockedBody;

  /// No description provided for @widgetSetupReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the widget from your phone's widget gallery for one-tap support when you need it fast.'**
  String get widgetSetupReadyBody;

  /// No description provided for @widgetSetupUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Home-screen widgets are unavailable on this device.'**
  String get widgetSetupUnavailableBody;

  /// No description provided for @widgetSetupUnlockAction.
  ///
  /// In en, this message translates to:
  /// **'Unlock one-tap widget'**
  String get widgetSetupUnlockAction;

  /// No description provided for @widgetSetupReadyLabel.
  ///
  /// In en, this message translates to:
  /// **'Widget ready'**
  String get widgetSetupReadyLabel;

  /// No description provided for @paywallBenefitPresenceBody.
  ///
  /// In en, this message translates to:
  /// **'One immediate call for a light interruption.'**
  String get paywallBenefitPresenceBody;

  /// No description provided for @notificationFollowUpBody.
  ///
  /// In en, this message translates to:
  /// **'Tap to answer your support call.'**
  String get notificationFollowUpBody;

  /// No description provided for @audioLanguageUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get audioLanguageUpdateAvailable;

  /// No description provided for @languageTraditionalChinese.
  ///
  /// In en, this message translates to:
  /// **'繁体字'**
  String get languageTraditionalChinese;

  /// No description provided for @awaitingStageTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow-up scheduled'**
  String get awaitingStageTitle;

  /// No description provided for @awaitingStageBody.
  ///
  /// In en, this message translates to:
  /// **'Stage {stage} is waiting on the local notification timer.'**
  String awaitingStageBody(Object stage);

  /// No description provided for @awaitingStageReady.
  ///
  /// In en, this message translates to:
  /// **'The next follow-up can open now.'**
  String get awaitingStageReady;

  /// No description provided for @awaitingStageCountdown.
  ///
  /// In en, this message translates to:
  /// **'Ready in {remaining}'**
  String awaitingStageCountdown(Object remaining);

  /// No description provided for @callAvatarSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Caller avatar'**
  String get callAvatarSemanticLabel;

  /// No description provided for @callActionHang.
  ///
  /// In en, this message translates to:
  /// **'Hang'**
  String get callActionHang;

  /// No description provided for @callActionDial.
  ///
  /// In en, this message translates to:
  /// **'Dial'**
  String get callActionDial;

  /// No description provided for @callActionEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get callActionEnd;

  /// No description provided for @callDeclineSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Decline support call'**
  String get callDeclineSemanticLabel;

  /// No description provided for @callAcceptSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Accept support call'**
  String get callAcceptSemanticLabel;

  /// No description provided for @callEndSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'End support call'**
  String get callEndSemanticLabel;

  /// No description provided for @callerNamePresence.
  ///
  /// In en, this message translates to:
  /// **'Tommy'**
  String get callerNamePresence;

  /// No description provided for @callerNameSocialPull.
  ///
  /// In en, this message translates to:
  /// **'Benjamin'**
  String get callerNameSocialPull;

  /// No description provided for @callerNameExitPressure.
  ///
  /// In en, this message translates to:
  /// **'Zack'**
  String get callerNameExitPressure;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
