// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

class AppLocalizationsZhTw extends AppLocalizations {
  AppLocalizationsZhTw([String locale = 'zh_TW']) : super(locale);

  @override
  String get homeSubtitle => '隨時為你';

  @override
  String get settings => '設定';

  @override
  String get scenarioSelector => '選擇情境';

  @override
  String get scenarioPresence => '陪伴掩護';

  @override
  String get scenarioSocialPull => '柔性牽引';

  @override
  String get scenarioExitPressure => '快速脫身';

  @override
  String get incomingCall => '來電';

  @override
  String get accept => '接聽';

  @override
  String get decline => '拒絕';

  @override
  String get audioLanguageSectionTitle => '音訊語言';

  @override
  String get audioLanguageSectionSubtitle =>
      '請先下載語言包，確保需要時可直接離線播放支援音訊。';

  @override
  String get audioLanguageReady => '已就緒';

  @override
  String get audioLanguageNotDownloaded => '需要下載';

  @override
  String get audioLanguageDownloading => '下載中...';

  @override
  String get audioLanguageFailed => '下載失敗';

  @override
  String get audioLanguageDownload => '下載';

  @override
  String get audioLanguageSelected => '已選擇';

  @override
  String get audioLanguageFallbackHint =>
      '若所選語言尚未完成離線準備，播放會依序回退到本機可用的中文，再到英文。';
}
