import Foundation

public struct CardRecord: Codable, Sendable, Equatable {
    public var due: String
    public var held: Int
    public var missed: Int

    public init(due: String, held: Int = 0, missed: Int = 0) {
        self.due = due
        self.held = held
        self.missed = missed
    }
}

public struct Progress: Codable, Sendable, Equatable {
    public var heard: [String: String]
    public var cards: [String: CardRecord]

    public init(heard: [String: String] = [:], cards: [String: CardRecord] = [:]) {
        self.heard = heard
        self.cards = cards
    }
}

public enum CalendarDay {
    public static let gaps = [1, 3, 7, 30]

    public static func ymd(_ date: Date = Date(), calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }

    public static func plus(days: Int, from date: Date = Date(), calendar: Calendar = .current) -> String {
        ymd(calendar.date(byAdding: .day, value: days, to: date) ?? date, calendar: calendar)
    }
}

public enum Review {
    public static func gradeHeld(_ progress: inout Progress, cardId: String, today: String = CalendarDay.ymd()) {
        var r = progress.cards[cardId] ?? CardRecord(due: today)
        r.held += 1
        r.due = CalendarDay.plus(days: CalendarDay.gaps[min(r.held - 1, 3)])
        progress.cards[cardId] = r
    }

    public static func gradeMissed(_ progress: inout Progress, cardId: String, today: String = CalendarDay.ymd()) {
        var r = progress.cards[cardId] ?? CardRecord(due: today)
        r.missed += 1
        r.due = CalendarDay.plus(days: 1)
        progress.cards[cardId] = r
    }

    public static func pickRecall(corpus: Corpus, lesson: Lesson, progress: Progress, today: String = CalendarDay.ymd(), limit: Int = 3) -> [Card] {
        let skip = lesson.beats.compactMap { beat -> String? in
            if case .check(let id, _) = beat { return id }
            return nil
        }.first
        var allowed = Set(progress.heard.keys.flatMap { corpus.lessonsById[$0]?.claims ?? [] })
        allowed.formUnion(lesson.claims)
        let due = progress.cards
            .filter { rec in
                rec.value.due <= today
                    && corpus.cardsById[rec.key] != nil
                    && allowed.contains(corpus.cardsById[rec.key]!.claim)
            }
            .sorted { $0.value.due < $1.value.due }
            .compactMap { corpus.cardsById[$0.key] }
        let fill = corpus.cards.filter { lesson.claims.contains($0.claim) && $0.id != skip }
        var seen = Set<String>()
        var out: [Card] = []
        for c in due + fill {
            if seen.contains(c.id) { continue }
            seen.insert(c.id)
            out.append(c)
            if out.count == limit { break }
        }
        return out
    }
}
