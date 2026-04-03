import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh_tw.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  String get homeSubtitle;
  String get settings;
  String get scenarioSelector;
  String get scenarioPresence;
  String get scenarioSocialPull;
  String get scenarioExitPressure;
  String get incomingCall;
  String get accept;
  String get decline;
  String get audioLanguageSectionTitle;
  String get audioLanguageSectionSubtitle;
  String get audioLanguageReady;
  String get audioLanguageNotDownloaded;
  String get audioLanguageDownloading;
  String get audioLanguageFailed;
  String get audioLanguageDownload;
  String get audioLanguageSelected;
  String get audioLanguageFallbackHint;
  String get notificationsSectionTitle;
  String get notificationsSectionEnabled;
  String get notificationsSectionNeedsPermission;
  String get notificationsSectionUnavailable;
  String get notificationsSectionTurnOn;
  String get notificationsSectionManage;
  String get notificationsSectionHelper;
  String get homeTriggerHint;
  String get homeStartCallSemanticLabel;
  String get upgradeToPremium;
  String get premiumActive;
  String get premiumActiveMessage;
  String get paywallTitle;
  String get paywallHeadline;
  String get paywallBody;
  String get paywallStoreNote;
  String get paywallSeePrice;
  String get paywallRestore;
  String get paywallRestoreFailed;
  String get paywallBenefitSocialPullTitle;
  String get paywallBenefitSocialPullBody;
  String get paywallBenefitExitPressureTitle;
  String get paywallBenefitExitPressureBody;
  String get paywallBenefitWidgetTitle;
  String get paywallBenefitWidgetBody;
  String get notificationFollowUpBody;
  String get callerNamePresence;
  String get callerNameSocialPull;
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
  bool isSupported(Locale locale) {
    if (locale.languageCode == 'en') {
      return true;
    }
    if (locale.languageCode == 'zh') {
      return true;
    }
    return false;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  final countryCode = locale.countryCode?.toUpperCase();
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      if (countryCode == 'TW') {
        return AppLocalizationsZhTw();
      }
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". '
    'This is likely an issue with the localizations generation tool.',
  );
}
