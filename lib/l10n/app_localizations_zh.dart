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
  String get appLogoSemanticLabel => 'withYou 应用标志';

  @override
  String get homeOpenSettingsSemanticLabel => 'Open settings';

  @override
  String get homeSupportStyleTitle => '你现在最需要什么？';

  @override
  String get homeSupportStyleGentle => '👀 Stay with me';

  @override
  String get homeSupportStyleSteady => '🕒 Ease me out';

  @override
  String get homeSupportStyleUrgent => '🚪 Get me out';

  @override
  String get scenarioSelector => '选择场景';

  @override
  String get scenarioPresence => '👀 Stay with me';

  @override
  String get scenarioSocialPull => '🕒 Ease me out';

  @override
  String get scenarioExitPressure => '🚪 Get me out';

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
  String get notificationsSectionHelper =>
      '🕒 Ease me out 和 🚪 Get me out 需要后续来电通知。';

  @override
  String get notificationsPermissionDialogTitle => '开启通知';

  @override
  String get notificationsPermissionDialogBody =>
      '🕒 Ease me out 和 🚪 Get me out 需要先开启通知，后续来电才能按时出现。';

  @override
  String get notificationsPermissionDialogNotNow => '暂不';

  @override
  String get notificationsPermissionDialogContinue => '继续';

  @override
  String get notificationsPermissionStillOff => '通知仍未开启。';

  @override
  String get homeTriggerHint => '需要时点一下我。';

  @override
  String get homeStartCallSemanticLabel => '开始当前支援来电';

  @override
  String get upgradeToPremium => '解锁高级版';

  @override
  String get premiumActive => '高级版已启用';

  @override
  String get premiumActiveMessage => '高级版已启用。你可以使用全部功能。';

  @override
  String get paywallTitle => '解锁高级版';

  @override
  String get paywallHeadline => '解锁 🕒 Ease me out 和 🚪 Get me out 的后续来电';

  @override
  String get paywallBody =>
      '当你需要更多支援时：🕒 Ease me out 会把打断自然延续下去，🚪 Get me out 会帮你更快离开，主屏幕小组件还能让你一键触发来电。';

  @override
  String get paywallStoreNote =>
      '一次购买，长期使用。高级版会让 🕒 Ease me out、🚪 Get me out 和小组件支援在你需要时随时可用。';

  @override
  String get paywallSeePrice => '查看价格';

  @override
  String get paywallRestore => '恢复购买';

  @override
  String get paywallRestoreFailed => '没有恢复到高级版购买记录。';

  @override
  String get paywallBenefitSocialPullTitle => '🕒 Ease me out';

  @override
  String get paywallBenefitSocialPullBody => '先触发一通电话，再用两通后续来电持续制造打断。';

  @override
  String get paywallBenefitExitPressureTitle => '🚪 Get me out';

  @override
  String get paywallBenefitExitPressureBody =>
      '当你需要马上离开时，可使用更紧凑的后续来电节奏。';

  @override
  String get paywallBenefitWidgetTitle => '主屏幕小组件';

  @override
  String get paywallBenefitWidgetBody => '在你需要时，从主屏幕一键触发所选的支援来电。';

  @override
  String get widgetSetupTitle => '主屏幕小组件';

  @override
  String get widgetSetupLockedBody => '解锁高级版后，即可添加一个一键启动所选支援来电的主屏幕小组件。';

  @override
  String get widgetSetupReadyBody => '从手机的小组件列表添加它，在你需要时一键触发支援来电。';

  @override
  String get widgetSetupUnavailableBody => '此设备当前无法使用主屏幕小组件。';

  @override
  String get widgetSetupUnlockAction => '解锁一键小组件';

  @override
  String get widgetSetupReadyLabel => '小组件已就绪';

  @override
  String get paywallBenefitPresenceBody => '当你只是需要有人陪着你时，用一通即时来电就够了。';

  @override
  String get notificationFollowUpBody => '点按即可接听你的支援来电。';

  @override
  String get audioLanguageUpdateAvailable => '有可用更新';

  @override
  String get languageTraditionalChinese => '繁体字';

  @override
  String get awaitingStageTitle => '我会再联系你。';

  @override
  String awaitingStageBody(Object stage) => '第 $stage 阶段正在等待本地通知计时器。';

  @override
  String get awaitingStageReady => '下一通后续来电现在可以打开。';

  @override
  String awaitingStageCountdown(Object remaining) => '$remaining 后可用';

  @override
  String get callAvatarSemanticLabel => '来电者头像';

  @override
  String get callActionHang => '挂断';

  @override
  String get callActionDial => '接听';

  @override
  String get callActionEnd => '结束';

  @override
  String get callDeclineSemanticLabel => '拒绝支援来电';

  @override
  String get callAcceptSemanticLabel => '接听支援来电';

  @override
  String get callEndSemanticLabel => '结束支援来电';

  @override
  String get callerNamePresence => '小陈';

  @override
  String get callerNameSocialPull => '小李';

  @override
  String get callerNameExitPressure => '小张';
}
