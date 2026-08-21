import WidgetKit
import SwiftUI

private let widgetGroupId = "group.com.yourcompany.kanjilesson"

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), imagePath: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), imagePath: getImagePath())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date(), imagePath: getImagePath())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
    
    private func getImagePath() -> String? {
        let prefs = UserDefaults(suiteName: widgetGroupId)
        let currentView = prefs?.integer(forKey: "current_view") ?? 0
        let imageKey = currentView == 0 ? "kanji_image_path" : "streak_image_path"
        return prefs?.string(forKey: imageKey)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let imagePath: String?
}

struct KanjiLessonWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Group {
            if let path = entry.imagePath, let uiImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("Kanji Lesson")
            }
        }
    }
}

@main
struct KanjiLessonWidget: Widget {
    let kind: String = "KanjiLessonWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            KanjiLessonWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Kanji Lesson")
        .description("Kanji of the Day & Streak")
    }
}
