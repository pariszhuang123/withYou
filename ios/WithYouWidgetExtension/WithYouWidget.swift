import SwiftUI
import WidgetKit

private struct WithYouWidgetEntry: TimelineEntry {
  let date: Date
}

private struct WithYouWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> WithYouWidgetEntry {
    WithYouWidgetEntry(date: Date())
  }

  func getSnapshot(in context: Context, completion: @escaping (WithYouWidgetEntry) -> Void) {
    completion(WithYouWidgetEntry(date: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<WithYouWidgetEntry>) -> Void) {
    completion(
      Timeline(
        entries: [WithYouWidgetEntry(date: Date())],
        policy: .never
      )
    )
  }
}

private struct WithYouWidgetEntryView: View {
  private let launchURL = URL(string: "withyou://widget-launch")!

  var entry: WithYouWidgetProvider.Entry

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 28, style: .continuous)
        .fill(Color(red: 0.98, green: 0.985, blue: 0.988))

      Image("WidgetLogo")
        .resizable()
        .scaledToFit()
        .padding(24)
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
