import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/l10n/app_localizations.dart';
import 'package:with_you/l10n/app_localizations_en.dart';
import 'package:with_you/l10n/app_localizations_zh.dart';
import 'package:with_you/l10n/app_localizations_zh_tw.dart';

const _stayWithMe = '\u{1F440} Stay with me';
const _easeMeOut = '\u{1F552} Ease me out';
const _getMeOut = '\u{1F6AA} Get me out';

void _expectCoreStateLabels(AppLocalizations localizations) {
  expect(localizations.homeSupportStyleGentle, _stayWithMe);
  expect(localizations.homeSupportStyleSteady, _easeMeOut);
  expect(localizations.homeSupportStyleUrgent, _getMeOut);
  expect(localizations.scenarioPresence, _stayWithMe);
  expect(localizations.scenarioSocialPull, _easeMeOut);
  expect(localizations.scenarioExitPressure, _getMeOut);
}

void main() {
  test('lookupAppLocalizations resolves English strings', () {
    final localizations = lookupAppLocalizations(const Locale('en'));

    expect(localizations, isA<AppLocalizationsEn>());
    _expectCoreStateLabels(localizations);
    expect(localizations.homeTriggerHint, 'Tap when you need me.');
    expect(
      localizations.paywallHeadline,
      'Unlock follow-up calls for $_easeMeOut and $_getMeOut',
    );
    expect(localizations.audioLanguageSectionTitle, 'Audio language');
    expect(
      localizations.awaitingStageBody('2'),
      'Stage 2 is waiting on the local notification timer.',
    );
    expect(localizations.awaitingStageCountdown('00:30'), 'Ready in 00:30');
    expect(localizations.callActionEnd, 'End');
  });

  test('lookupAppLocalizations resolves Simplified Chinese strings', () {
    final localizations = lookupAppLocalizations(const Locale('zh'));

    expect(localizations, isA<AppLocalizationsZh>());
    _expectCoreStateLabels(localizations);
    expect(localizations.homeTriggerHint, isNotEmpty);
    expect(localizations.paywallHeadline, contains(_easeMeOut));
    expect(localizations.paywallHeadline, contains(_getMeOut));
    expect(localizations.audioLanguageSectionTitle, isNotEmpty);
    expect(localizations.awaitingStageBody(2), contains('2'));
    expect(localizations.awaitingStageCountdown('00:30'), contains('00:30'));
  });

  test('lookupAppLocalizations resolves Traditional Chinese strings', () {
    final localizations = lookupAppLocalizations(const Locale('zh', 'TW'));

    expect(localizations, isA<AppLocalizationsZhTw>());
    _expectCoreStateLabels(localizations);
    expect(localizations.homeTriggerHint, isNotEmpty);
    expect(localizations.paywallHeadline, contains(_easeMeOut));
    expect(localizations.paywallHeadline, contains(_getMeOut));
    expect(localizations.audioLanguageSectionTitle, isNotEmpty);
    expect(localizations.awaitingStageBody(2), contains('2'));
    expect(localizations.awaitingStageCountdown('00:30'), contains('00:30'));
  });

  test('delegate reports support and loads localized instances', () async {
    expect(AppLocalizations.delegate.isSupported(const Locale('en')), isTrue);
    expect(AppLocalizations.delegate.isSupported(const Locale('zh')), isTrue);
    expect(
      AppLocalizations.delegate.isSupported(const Locale('zh', 'TW')),
      isTrue,
    );
    expect(AppLocalizations.delegate.isSupported(const Locale('ja')), isFalse);

    final english = await AppLocalizations.delegate.load(const Locale('en'));
    final chinese = await AppLocalizations.delegate.load(const Locale('zh'));
    final chineseTw = await AppLocalizations.delegate.load(
      const Locale('zh', 'TW'),
    );

    expect(english.localeName, 'en');
    expect(chinese.localeName, 'zh');
    expect(chineseTw.localeName, 'zh_TW');
  });

  test('lookupAppLocalizations rejects unsupported locales', () {
    expect(
      () => lookupAppLocalizations(const Locale('ja')),
      throwsA(isA<FlutterError>()),
    );
  });
}
