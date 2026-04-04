import SwiftUI
import WidgetKit

private struct WithYouWidgetEntry: TimelineEntry {
  let date: Date
  let isPremiumActive: Bool
}

private struct WithYouWidgetProvider: TimelineProvider {
  private let appGroupId = "group.com.example.withYou.shared"
  private let premiumActiveKey = "with_you_widget_premium_active"

  func placeholder(in context: Context) -> WithYouWidgetEntry {
    WithYouWidgetEntry(date: Date(), isPremiumActive: false)
  }

  func getSnapshot(in context: Context, completion: @escaping (WithYouWidgetEntry) -> Void) {
    completion(WithYouWidgetEntry(date: Date(), isPremiumActive: isPremiumActive()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<WithYouWidgetEntry>) -> Void) {
    completion(
      Timeline(
        entries: [WithYouWidgetEntry(date: Date(), isPremiumActive: isPremiumActive())],
        policy: .never
      )
    )
  }

  private func isPremiumActive() -> Bool {
    let defaults = UserDefaults(suiteName: appGroupId) ?? .standard
    return defaults.bool(forKey: premiumActiveKey)
  }
}

private struct WithYouWidgetEntryView: View {
  private let launchURL = URL(string: "withyou://widget-launch")!

  var entry: WithYouWidgetProvider.Entry

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 28, style: .continuous)
        .fill(
          entry.isPremiumActive
            ? Color(red: 0.98, green: 0.985, blue: 0.988)
            : Color(red: 0.94, green: 0.95, blue: 0.955)
        )

      Image("WidgetLogo")
        .resizable()
        .scaledToFit()
        .padding(24)
        .saturation(entry.isPremiumActive ? 1 : 0)
        .opacity(entry.isPremiumActive ? 1 : 0.42)

      if !entry.isPremiumActive {
        VStack {
          HStack {
            Spacer()
            Image(systemName: "lock.fill")
              .font(.system(size: 14, weight: .semibold))
              .foregroundStyle(.white)
              .padding(8)
              .background(Color(red: 0.33, green: 0.39, blue: 0.43))
              .clipShape(Circle())
          }
          Spacer()
        }
        .padding(10)
      }
    }
    .widgetURL(launchURL)
    .accessibilityLabel("Start a support call")
  }
}

struct WithYouWidget: Widget {
  let kind = "WithYouWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: WithYouWidgetProvider()) { entry in
      WithYouWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("With You")
    .description("Start a support call with one tap.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

@main
struct WithYouWidgetBundle: WidgetBundle {
  var body: some Widget {
    WithYouWidget()
  }
}
