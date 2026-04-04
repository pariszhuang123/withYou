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
    expect(localizations.homeTriggerHint, 'Tap the logo to start');
    expect(
      localizations.paywallHeadline,
      'Unlock steady and urgent follow-up calls',
    );
    expect(localizations.audioLanguageSectionTitle, 'Audio language');
    expect(localizations.appLogoSemanticLabel, 'withYou app logo');
    expect(localizations.languageTraditionalChinese, '繁体字');
    expect(
      localizations.awaitingStageBody('2'),
      'Stage 2 is waiting on the local notification timer.',
    );
    expect(localizations.awaitingStageCountdown('00:30'), 'Ready in 00:30');
    expect(localizations.callActionEnd, 'End');
    expect(localizations.callerNamePresence, 'Tommy');
    expect(localizations.callerNameSocialPull, 'Benjamin');
    expect(localizations.callerNameExitPressure, 'Zack');
  });

  test('lookupAppLocalizations resolves Simplified Chinese strings', () {
    final localizations = lookupAppLocalizations(const Locale('zh'));

    expect(localizations, isA<AppLocalizationsZh>());
    expect(localizations.homeSubtitle, '随时为你');
    expect(localizations.homeTriggerHint, '点击标志即可开始');
    expect(localizations.paywallHeadline, '解锁柔性支援和快速支援的后续来电');
    expect(localizations.audioLanguageSectionTitle, '音频语言');
    expect(localizations.languageTraditionalChinese, '繁体字');
    expect(localizations.awaitingStageBody(2), '第 2 阶段正在等待本地通知计时器。');
    expect(localizations.awaitingStageCountdown('00:30'), '00:30 后可用');
    expect(localizations.callActionDial, '接听');
    expect(localizations.callerNamePresence, '小陈');
    expect(localizations.callerNameSocialPull, '小李');
    expect(localizations.callerNameExitPressure, '小张');
  });

  test('lookupAppLocalizations resolves Traditional Chinese strings', () {
    final localizations = lookupAppLocalizations(const Locale('zh', 'TW'));

    expect(localizations, isA<AppLocalizationsZhTw>());
    expect(localizations.homeSubtitle, '隨時為你');
    expect(localizations.homeTriggerHint, '點一下標誌即可開始');
    expect(localizations.paywallHeadline, '解鎖柔性支援和快速支援的後續來電');
    expect(localizations.audioLanguageSectionTitle, '音訊語言');
    expect(localizations.languageTraditionalChinese, '繁体字');
    expect(localizations.awaitingStageBody(2), '第 2 階段正在等待本機通知計時器。');
    expect(localizations.awaitingStageCountdown('00:30'), '00:30 後可用');
    expect(localizations.callActionDial, '接聽');
    expect(localizations.callerNamePresence, '小陳');
    expect(localizations.callerNameSocialPull, '小李');
    expect(localizations.callerNameExitPressure, '小張');
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
