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
  String get homeTriggerHint => '点击标志即可开始';

  @override
  String get homeStartCallSemanticLabel => '开始当前支援来电';

  @override
  String get upgradeToPremium => '升级到高级版';

  @override
  String get premiumActive => '高级版已启用';

  @override
  String get premiumActiveMessage => '高级版已启用。你可以使用全部功能。';

  @override
  String get paywallTitle => '升级到高级版';

  @override
  String get paywallHeadline => '解锁柔性支援和快速支援的后续来电';

  @override
  String get paywallBody =>
      '当你被困住时，可获得更多支援：柔性支援的后续来电会持续制造打断，快速支援的后续来电能帮助你更快脱身，主屏幕小组件还能让你一键触发来电。';

  @override
  String get paywallStoreNote => '高级版会让柔性支援、快速支援和小组件支援在你需要时随时可用。';

  @override
  String get paywallSeePrice => '升级到高级版';

  @override
  String get paywallRestore => '恢复购买';

  @override
  String get paywallRestoreFailed => '没有恢复到高级版购买记录。';

  @override
  String get paywallBenefitSocialPullTitle => '柔性支援';

  @override
  String get paywallBenefitSocialPullBody => '先触发一通电话，再用两通后续来电持续制造打断。';

  @override
  String get paywallBenefitExitPressureTitle => '快速支援';

  @override
  String get paywallBenefitExitPressureBody => '当你想更快脱身时，可使用更紧凑的后续来电节奏。';

  @override
  String get paywallBenefitWidgetTitle => '主屏幕小组件';

  @override
  String get paywallBenefitWidgetBody => '在你需要时，从主屏幕一键触发所选的支援来电。';

  @override
  String get notificationFollowUpBody => '点按即可接听你的支援来电。';

  @override
  String get callerNamePresence => '小陈';

  @override
  String get callerNameSocialPull => '小李';

  @override
  String get callerNameExitPressure => '小张';
}
