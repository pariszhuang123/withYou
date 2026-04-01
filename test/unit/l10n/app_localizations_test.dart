import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/l10n/app_localizations.dart';
import 'package:with_you/l10n/app_localizations_en.dart';
import 'package:with_you/l10n/app_localizations_zh.dart';
import 'package:with_you/l10n/app_localizations_zh_tw.dart';

void main() {
  test('lookupAppLocalizations resolves English strings', () {
    final localizations = lookupAppLocalizations(const Locale('en'));

    expect(localizations, isA<AppLocalizationsEn>());
    expect(localizations.homeSubtitle, 'Always with you');
    expect(localizations.audioLanguageSectionTitle, 'Audio language');
  });

  test('lookupAppLocalizations resolves Simplified Chinese strings', () {
    final localizations = lookupAppLocalizations(const Locale('zh'));

    expect(localizations, isA<AppLocalizationsZh>());
    expect(localizations.homeSubtitle, '随时为你');
    expect(localizations.audioLanguageSectionTitle, '音频语言');
  });

  test('lookupAppLocalizations resolves Traditional Chinese strings', () {
    final localizations = lookupAppLocalizations(const Locale('zh', 'TW'));

    expect(localizations, isA<AppLocalizationsZhTw>());
    expect(localizations.homeSubtitle, '隨時為你');
    expect(localizations.audioLanguageSectionTitle, '音訊語言');
  });

  test('delegate reports support and loads localized instances', () async {
    expect(AppLocalizations.delegate.isSupported(const Locale('en')), isTrue);
    expect(AppLocalizations.delegate.isSupported(const Locale('zh')), isTrue);
    expect(AppLocalizations.delegate.isSupported(const Locale('zh', 'TW')), isTrue);
    expect(AppLocalizations.delegate.isSupported(const Locale('ja')), isFalse);

    final english = await AppLocalizations.delegate.load(const Locale('en'));
    final chinese = await AppLocalizations.delegate.load(const Locale('zh'));
    final chineseTw = await AppLocalizations.delegate.load(const Locale('zh', 'TW'));

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
