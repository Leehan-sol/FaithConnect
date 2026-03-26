import WidgetKit

struct BibleVerseProvider: TimelineProvider {

    func placeholder(in context: Context) -> BibleVerseEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (BibleVerseEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
            return
        }

        Task {
            let entry = await BibleVerseService.fetchRandomVerse()
            completion(entry)
        }
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<BibleVerseEntry>) -> Void) {
        Task {
            let entry = await BibleVerseService.fetchRandomVerse()

            // 1시간 후 새로운 말씀으로 갱신
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}
