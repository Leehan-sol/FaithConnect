//
//  FaithConnectWidget.swift
//  FaithConnectWidget
//
//  Created by Apple on 3/25/26.
//

import WidgetKit
import SwiftUI

@main
struct FaithConnectWidgetBundle: WidgetBundle {
    var body: some Widget {
        BibleVerseWidget()
        IconWidget()
    }
}

// MARK: - 오늘의 말씀 위젯
struct BibleVerseWidget: Widget {
    let kind: String = "BibleVerseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BibleVerseProvider()) { entry in
            if #available(iOS 17.0, *) {
                BibleVerseWidgetView(entry: entry)
                    .containerBackground(for: .widget) {
                        Image("widgetBackground")
                            .resizable()
                            .scaledToFill()
                    }
            } else {
                BibleVerseWidgetView(entry: entry)
                    .background(
                        Image("widgetBackground")
                            .resizable()
                            .scaledToFill()
                    )
            }
        }
        .configurationDisplayName("오늘의 말씀")
        .description("랜덤 성경 말씀을 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - 아이콘 위젯용 Provider (API 호출 없음)
struct IconWidgetProvider: TimelineProvider {
    struct Entry: TimelineEntry {
        let date: Date
    }

    func placeholder(in context: Context) -> Entry {
        Entry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        completion(Entry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let timeline = Timeline(entries: [Entry(date: .now)], policy: .never)
        completion(timeline)
    }
}

// MARK: - 아이콘 위젯
struct IconWidget: Widget {
    let kind: String = "IconWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IconWidgetProvider()) { _ in
            if #available(iOS 17.0, *) {
                IconWidgetView()
                    .containerBackground(for: .widget) {
                        Image("widgetBackgroundWhite")
                            .resizable()
                            .scaledToFill()
                    }
            } else {
                IconWidgetView()
                    .background(
                        Image("widgetBackgroundWhite")
                            .resizable()
                            .scaledToFill()
                    )
            }
        }
        .configurationDisplayName("FaithConnect")
        .description("FaithConnect 바로가기")
        .supportedFamilies([.systemSmall])
    }
}
