import SwiftUI
import WidgetKit

struct BibleVerseWidgetView: View {
    var entry: BibleVerseEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallBibleVerseView(entry: entry)
        case .systemMedium:
            MediumBibleVerseView(entry: entry)
        default:
            SmallBibleVerseView(entry: entry)
        }
    }
}

// MARK: - Small 위젯(1)
struct SmallBibleVerseView: View {
    let entry: BibleVerseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image("heartIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                Text("오늘의 말씀")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .foregroundColor(Color("customBlue1"))

            Text(entry.text)
                .font(.caption)
                .minimumScaleFactor(0.6)
                .frame(maxHeight: .infinity)
                .foregroundColor(.primary)

            HStack {
                Spacer()
                Text(entry.reference)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .redacted(reason: entry.isPlaceholder ? .placeholder : [])
    }
}

// MARK: - Small 위젯(2)
struct IconWidgetView: View {
    var body: some View {
        GeometryReader { geo in
            Image("heartIcon")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width * 1.3, height: geo.size.height * 1.3)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .clipped()
        }
    }
}

// MARK: - Medium 위젯
struct MediumBibleVerseView: View {
    let entry: BibleVerseEntry

    var body: some View {
        HStack(spacing: 14) {
            Image("heartIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .padding(6)
                .background(Color("customBlue1").opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text("오늘의 말씀")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("customBlue1"))

                Spacer(minLength: 0)

                Text(entry.text)
                    .font(.footnote)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(.primary)

                Spacer(minLength: 0)

                HStack {
                    Spacer()
                    Text(entry.reference)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.leading, 10)
        .padding(.trailing, 14)
        .padding(.vertical, 14)
        .redacted(reason: entry.isPlaceholder ? .placeholder : [])
    }
}
