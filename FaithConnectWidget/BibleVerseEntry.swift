import WidgetKit
import Foundation

struct BibleVerseEntry: TimelineEntry {
    let date: Date
    let bookName: String
    let chapter: Int
    let verse: Int
    let text: String
    let isPlaceholder: Bool

    var reference: String {
        "\(bookName) \(chapter):\(verse)"
    }
    
    static let placeholder = BibleVerseEntry(
        date: .now,
        bookName: "시편",
        chapter: 23,
        verse: 1,
        text: "여호와는 나의 목자시니 내게 부족함이 없으리로다",
        isPlaceholder: true
    )

    static let fallback = BibleVerseEntry(
        date: .now,
        bookName: "잠언",
        chapter: 3,
        verse: 5,
        text: "너는 마음을 다하여 여호와를 신뢰하고 네 명철을 의지하지 말라",
        isPlaceholder: false
    )
}
