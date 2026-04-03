// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get homeSubtitle => '随时为你';

  @override
  String get settings => '设置';

  @override
  String get scenarioSelector => '选择场景';

  @override
  String get scenarioPresence => '陪伴掩护';

  @override
  String get scenarioSocialPull => '柔性牵引';

  @override
  String get scenarioExitPressure => '快速脱身';

  @override
  String get incomingCall => '来电';

  @override
  String get accept => '接听';

  @override
  String get decline => '拒绝';

  @override
  String get audioLanguageSectionTitle => '音频语言';

  @override
  String get audioLanguageSectionSubtitle => '请在需要之前先下载语言包，确保离线也能播放支援音频。';

  @override
  String get audioLanguageReady => '已就绪';

  @override
  String get audioLanguageNotDownloaded => '需要下载';

  @override
  String get audioLanguageDownloading => '正在下载...';

  @override
  String get audioLanguageFailed => '下载失败';

  @override
  String get audioLanguageDownload => '下载';

  @override
  String get audioLanguageSelected => '已选择';

  @override
  String get audioLanguageFallbackHint => '如果已选语言尚未离线就绪，播放会依次回退到本地可用的中文，再到英文。';

  @override
  String get notificationsSectionTitle => '通知';

  @override
  String get notificationsSectionEnabled => '后续来电通知已开启。';

  @override
  String get notificationsSectionNeedsPermission => '后续来电需要在系统中开启通知。';

  @override
  String get notificationsSectionUnavailable => '此设备无法使用通知。';

  @override
  String get notificationsSectionTurnOn => '开启通知';

  @override
  String get notificationsSectionManage => '打开系统设置';

  @override
  String get notificationsSectionHelper => '柔性牵引和快速脱身场景依赖后续来电通知。';

  @override
  String get notificationFollowUpBody => '点按即可接听你的支援来电。';

  @override
  String get callerNamePresence => '小陈';

  @override
  String get callerNameSocialPull => '小李';

  @override
  String get callerNameExitPressure => '小张';
}
