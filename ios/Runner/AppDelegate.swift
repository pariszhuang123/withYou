import Flutter
import UIKit
import UserNotifications
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler, UNUserNotificationCenterDelegate {
  private let methodChannelName = "with_you/notifications/methods"
  private let eventChannelName = "with_you/notifications/events"
  private let pendingEventsKey = "with_you_pending_notification_events"
  private let widgetEventChannelName = "with_you/widget_launch/events"
  private let pendingWidgetEventsKey = "with_you_pending_widget_launch_events"
  private let widgetVisualStateMethodChannelName = "with_you/widget_visual_state/methods"
  private let widgetAppGroupId = "group.com.example.withYou.shared"
  private let widgetPremiumActiveKey = "with_you_widget_premium_active"
  private let widgetScheme = "withyou"
  private let widgetHost = "widget-launch"
  private var eventSink: FlutterEventSink?
  fileprivate var widgetEventSink: FlutterEventSink?
  private var widgetStreamHandler: WidgetLaunchStreamHandler?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    UNUserNotificationCenter.current().delegate = self

    if let controller = window?.rootViewController as? FlutterViewController {
      let methodChannel = FlutterMethodChannel(
        name: methodChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      methodChannel.setMethodCallHandler { [weak self] call, result in
        self?.handleMethodCall(call, result: result)
      }

      let eventChannel = FlutterEventChannel(
        name: eventChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      eventChannel.setStreamHandler(self)

      let widgetEventChannel = FlutterEventChannel(
        name: widgetEventChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      let widgetStreamHandler = WidgetLaunchStreamHandler(appDelegate: self)
      self.widgetStreamHandler = widgetStreamHandler
      widgetEventChannel.setStreamHandler(widgetStreamHandler)

      let widgetVisualStateChannel = FlutterMethodChannel(
        name: widgetVisualStateMethodChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      widgetVisualStateChannel.setMethodCallHandler { [weak self] call, result in
        self?.handleWidgetVisualStateMethodCall(call, result: result)
      }
    }

    if let url = launchOptions?[.url] as? URL {
      _ = handleWidgetURL(url)
    }

    reconcileMissedNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if handleWidgetURL(url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    reconcileMissedNotifications()
  }

  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      notificationsEnabled { enabled in
        DispatchQueue.main.async {
          self.flushPendingEvents()
          result(enabled)
        }
      }
    case "requestPermission":
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
        _, _ in
        self.notificationsEnabled { enabled in
          DispatchQueue.main.async {
            self.flushPendingEvents()
            result(enabled)
          }
        }
      }
    case "openSystemSettings":
      DispatchQueue.main.async {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
          result(nil)
          return
        }
        UIApplication.shared.open(url) { _ in
          result(nil)
        }
      }
    case "scheduleFollowUp":
      guard let arguments = call.arguments as? [String: Any],
            let sessionId = arguments["sessionId"] as? String,
            let scenario = arguments["scenario"] as? String,
            let stage = arguments["stage"] as? Int,
            let delaySeconds = arguments["delaySeconds"] as? Int,
            let title = arguments["title"] as? String,
            let body = arguments["body"] as? String else {
        result(
          FlutterError(code: "bad_args", message: "Invalid notification arguments", details: nil)
        )
        return
      }

      let content = UNMutableNotificationContent()
      content.title = title
      content.body = body
      content.sound = .default
      content.userInfo = [
        "sessionId": sessionId,
        "scenario": scenario,
        "stage": stage,
        "fireAtEpochMs": Int(Date().timeIntervalSince1970 * 1000) + (delaySeconds * 1000),
      ]

      let request = UNNotificationRequest(
        identifier: notificationIdentifier(sessionId: sessionId, stage: stage),
        content: content,
        trigger: UNTimeIntervalNotificationTrigger(
          timeInterval: TimeInterval(max(delaySeconds, 1)),
          repeats: false
        )
      )

      UNUserNotificationCenter.current().add(request) { error in
        DispatchQueue.main.async {
          if let error {
            result(
              FlutterError(
                code: "schedule_failed",
                message: "Failed to schedule follow-up notification",
                details: error.localizedDescription
              )
            )
          } else {
            result(nil)
          }
        }
      }
    case "cancelAll":
      guard let arguments = call.arguments as? [String: Any],
            let sessionId = arguments["sessionId"] as? String else {
        result(
          FlutterError(code: "bad_args", message: "Invalid cancel arguments", details: nil)
        )
        return
      }

      let identifiers = (1...3).map { notificationIdentifier(sessionId: sessionId, stage: $0) }
      UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
      UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleWidgetVisualStateMethodCall(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    switch call.method {
    case "syncPremiumAccess":
      guard let arguments = call.arguments as? [String: Any],
            let isActive = arguments["isActive"] as? Bool else {
        result(
          FlutterError(code: "bad_args", message: "Invalid widget visual state arguments", details: nil)
        )
        return
      }

      sharedWidgetDefaults().set(isActive, forKey: widgetPremiumActiveKey)
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func notificationIdentifier(sessionId: String, stage: Int) -> String {
    return "with_you_\(sessionId)_\(stage)"
  }

  private func notificationsEnabled(completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .authorized, .provisional, .ephemeral:
        completion(true)
      case .denied, .notDetermined:
        completion(false)
      @unknown default:
        completion(false)
      }
    }
  }

  private func emitEvent(_ event: [String: Any]) {
    if let eventSink {
      eventSink(event)
      return
    }

    let existing = UserDefaults.standard.array(forKey: pendingEventsKey) as? [[String: Any]] ?? []
    UserDefaults.standard.set(existing + [event], forKey: pendingEventsKey)
  }

  private func flushPendingEvents() {
    guard let eventSink else { return }
    let existing = UserDefaults.standard.array(forKey: pendingEventsKey) as? [[String: Any]] ?? []
    for event in existing {
      eventSink(event)
    }
    UserDefaults.standard.removeObject(forKey: pendingEventsKey)
  }

  private func emitWidgetEvent(_ event: [String: String]) {
    if let widgetEventSink {
      widgetEventSink(event)
      return
    }

    let existing = UserDefaults.standard.array(forKey: pendingWidgetEventsKey) as? [[String: String]] ?? []
    UserDefaults.standard.set(existing + [event], forKey: pendingWidgetEventsKey)
  }

  fileprivate func flushPendingWidgetEvents() {
    guard let widgetEventSink else { return }
    let existing = UserDefaults.standard.array(forKey: pendingWidgetEventsKey) as? [[String: String]] ?? []
    for event in existing {
      widgetEventSink(event)
    }
    UserDefaults.standard.removeObject(forKey: pendingWidgetEventsKey)
  }

  private func handleWidgetURL(_ url: URL) -> Bool {
    guard url.scheme == widgetScheme, url.host == widgetHost else {
      return false
    }

    let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    let scenario = components?.queryItems?.first(where: { $0.name == "scenario" })?.value ?? ""
    emitWidgetEvent(["scenario": scenario])
    return true
  }

  private func sharedWidgetDefaults() -> UserDefaults {
    UserDefaults(suiteName: widgetAppGroupId) ?? .standard
  }

  private func reconcileMissedNotifications() {
    UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
      let nowEpochMs = Int(Date().timeIntervalSince1970 * 1000)
      let stale = notifications.filter { notification in
        guard let fireAtEpochMs = notification.request.content.userInfo["fireAtEpochMs"] as? Int else {
          return false
        }
        return nowEpochMs - fireAtEpochMs >= 120_000
      }

      guard !stale.isEmpty else { return }

      let identifiers = stale.map(\.request.identifier)
      UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)

      DispatchQueue.main.async {
        for notification in stale {
          guard let sessionId = notification.request.content.userInfo["sessionId"] as? String,
                let scenario = notification.request.content.userInfo["scenario"] as? String,
                let stage = notification.request.content.userInfo["stage"] as? Int else {
            continue
          }

          self.emitEvent([
            "sessionId": sessionId,
            "scenario": scenario,
            "stage": stage,
            "action": "missed",
          ])
        }
      }
    }
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound, .badge])
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    if let sessionId = userInfo["sessionId"] as? String,
       let scenario = userInfo["scenario"] as? String,
       let stage = userInfo["stage"] as? Int {
      emitEvent([
        "sessionId": sessionId,
        "scenario": scenario,
        "stage": stage,
        "action": "tapped",
      ])
      center.removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
    }
    completionHandler()
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    flushPendingEvents()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }
}

final class WidgetLaunchStreamHandler: NSObject, FlutterStreamHandler {
  init(appDelegate: AppDelegate) {
    self.appDelegate = appDelegate
  }

  private weak var appDelegate: AppDelegate?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    appDelegate?.widgetEventSink = events
    appDelegate?.flushPendingWidgetEvents()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    appDelegate?.widgetEventSink = nil
    return nil
  }
}
