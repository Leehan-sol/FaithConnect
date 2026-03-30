import Foundation

struct BibleVerseResponse: Decodable {
    let pk: Int
    let translation: String
    let book: Int
    let chapter: Int
    let verse: Int
    let text: String
}

struct BibleVerseService {

    private static let baseURL = "https://bolls.life"

    // 랜덤 성경 구절 조회 (KRV - 한글)
    static func fetchRandomVerse() async -> BibleVerseEntry {
        guard let url = URL(string: "\(baseURL)/get-random-verse/KRV/") else {
            return .fallback
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return .fallback
            }

            let decoded = try JSONDecoder().decode(BibleVerseResponse.self, from: data)

            let cleanText = decoded.text.replacingOccurrences(
                of: "<[^>]+>",
                with: "",
                options: .regularExpression
            ).trimmingCharacters(in: .whitespacesAndNewlines)

            return BibleVerseEntry(
                date: .now,
                bookName: bookName(for: decoded.book),
                chapter: decoded.chapter,
                verse: decoded.verse,
                text: cleanText,
                isPlaceholder: false
            )
        } catch {
            return .fallback
        }
    }

    // MARK: - 성경 책 번호 → 한글 이름 매핑
    static func bookName(for bookNumber: Int) -> String {
        let books: [Int: String] = [
            // 구약
            1: "창세기", 2: "출애굽기", 3: "레위기", 4: "민수기", 5: "신명기",
            6: "여호수아", 7: "사사기", 8: "룻기", 9: "사무엘상", 10: "사무엘하",
            11: "열왕기상", 12: "열왕기하", 13: "역대상", 14: "역대하", 15: "에스라",
            16: "느헤미야", 17: "에스더", 18: "욥기", 19: "시편", 20: "잠언",
            21: "전도서", 22: "아가", 23: "이사야", 24: "예레미야", 25: "예레미야애가",
            26: "에스겔", 27: "다니엘", 28: "호세아", 29: "요엘", 30: "아모스",
            31: "오바댜", 32: "요나", 33: "미가", 34: "나훔", 35: "하박국",
            36: "스바냐", 37: "학개", 38: "스가랴", 39: "말라기",
            // 신약
            40: "마태복음", 41: "마가복음", 42: "누가복음", 43: "요한복음", 44: "사도행전",
            45: "로마서", 46: "고린도전서", 47: "고린도후서", 48: "갈라디아서", 49: "에베소서",
            50: "빌립보서", 51: "골로새서", 52: "데살로니가전서", 53: "데살로니가후서",
            54: "디모데전서", 55: "디모데후서", 56: "디도서", 57: "빌레몬서",
            58: "히브리서", 59: "야고보서", 60: "베드로전서", 61: "베드로후서",
            62: "요한일서", 63: "요한이서", 64: "요한삼서", 65: "유다서", 66: "요한계시록"
        ]
        return books[bookNumber] ?? "성경"
    }
}
