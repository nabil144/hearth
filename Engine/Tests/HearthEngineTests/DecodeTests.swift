import XCTest
@testable import HearthEngine

final class DecodeTests: XCTestCase {
    var root: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }

    func testGreekJSONDecodes() throws {
        let url = root.appendingPathComponent("content/greek.json")
        let corpus = try Corpus.decode(Data(contentsOf: url))
        XCTAssertEqual(corpus.lessons.count, 12)
        XCTAssertEqual(corpus.written.count, 3)
        XCTAssertEqual(corpus.written.map(\.id), ["greek-03", "greek-04", "greek-05"])
        for lesson in corpus.written {
            XCTAssertEqual(lesson.beats.last, .recall)
            XCTAssertEqual(lesson.beats.filter { $0.kind == "recall" }.count, 1)
            for beat in lesson.beats {
                if case .check(let id, _) = beat {
                    let card = try XCTUnwrap(corpus.cardsById[id])
                    XCTAssertTrue(lesson.claims.contains(card.claim), "\(lesson.id) check \(id)")
                }
                if case .still(let art, let text) = beat {
                    XCTAssertFalse(text.isEmpty)
                    XCTAssertNotNil(art)
                }
            }
        }
        XCTAssertEqual(try XCTUnwrap(corpus.nextLesson(heard: [:])).id, "greek-03")
        XCTAssertEqual(try XCTUnwrap(corpus.nextLesson(heard: ["greek-03": "2026-09-12"])).id, "greek-04")
        XCTAssertNil(corpus.nextLesson(heard: ["greek-03": "1", "greek-04": "1", "greek-05": "1"]))
    }
}

final class ProgressTests: XCTestCase {
    func testLocalDayNotUTCSlice() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 3 * 3600)!
        let twoAM = cal.date(from: DateComponents(year: 2026, month: 9, day: 12, hour: 2))!
        let utc = ISO8601DateFormatter()
        utc.timeZone = TimeZone(secondsFromGMT: 0)
        XCTAssertTrue(utc.string(from: twoAM).hasPrefix("2026-09-11"))
        XCTAssertEqual(CalendarDay.ymd(twoAM, calendar: cal), "2026-09-12")
    }

    func testHeldGapsAndMissTomorrow() {
        var p = Memory()
        Review.gradeHeld(&p, cardId: "k-stone", today: "2026-09-12")
        XCTAssertEqual(p.cards["k-stone"]?.due, CalendarDay.plus(days: 1))
        Review.gradeHeld(&p, cardId: "k-stone", today: "2026-09-12")
        XCTAssertEqual(p.cards["k-stone"]?.held, 2)
        var miss = Memory()
        Review.gradeMissed(&miss, cardId: "k-stone", today: "2026-09-12")
        XCTAssertEqual(miss.cards["k-stone"]?.due, CalendarDay.plus(days: 1))
        XCTAssertEqual(miss.cards["k-stone"]?.missed, 1)
    }

    func testPickRecallSkipsTheCheckCard() throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("content/greek.json")
        let corpus = try Corpus.decode(Data(contentsOf: url))
        let lesson = try XCTUnwrap(corpus.lessonsById["greek-04"])
        let picked = Review.pickRecall(corpus: corpus, lesson: lesson, progress: Memory())
        XCTAssertEqual(picked.count, 3)
        XCTAssertFalse(picked.contains { $0.id == "k-siblings" })
    }
}

final class FamilyTests: XCTestCase {
    var corpus: Corpus {
        get throws {
            let url = URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("content/greek.json")
            return try Corpus.decode(Data(contentsOf: url))
        }
    }

    func testEmptyHearingLeavesTheLineDim() throws {
        let family = Family.of(corpus: try corpus, heard: [:], focus: nil)
        XCTAssertEqual(family.met, 0)
        XCTAssertEqual(family.total, 15)
        XCTAssertEqual(family.rows.map { $0.map(\.id) }, [
            ["chaos", "gaia"],
            ["ouranos"],
            ["kronos", "rhea", "hundred-handers"],
            ["demeter", "hades", "hera", "hestia", "poseidon", "zeus"],
        ])
        XCTAssertFalse(family.rows.flatMap { $0 }.contains { $0.id == "aphrodite" })
        XCTAssertEqual(family.portrait?.id, "chaos")
        XCTAssertTrue(family.loose.isEmpty)
    }

    func testChapterThreeLightsTheHouseOfKronos() throws {
        let family = Family.of(corpus: try corpus, heard: ["greek-03": "2026-09-13"], focus: nil)
        XCTAssertEqual(family.met, 10)
        XCTAssertEqual(family.rows[0].first { $0.id == "gaia" }?.meet, .met)
        XCTAssertEqual(family.rows[0].first { $0.id == "chaos" }?.meet, .unmet)
        XCTAssertEqual(try XCTUnwrap(family.rows[3].first { $0.id == "zeus" }).generation, 3)
        XCTAssertEqual(try XCTUnwrap(family.rows[3].first { $0.id == "zeus" }).meet, .met)
        XCTAssertEqual(family.portrait?.id, "gaia")
        XCTAssertEqual(family.portrait?.cite, "Hesiod, Theogony lines 453-491")
        XCTAssertEqual(Set(family.loose.map(\.id)), ["v-aphrodite", "v-kingship"])
        XCTAssertEqual(family.branches.map { $0.map(\.id) }, [
            ["keto", "phorkys"],
            ["medusa"],
        ])
        XCTAssertTrue(family.branches.flatMap { $0 }.allSatisfy { $0.meet == .unmet })
    }

    func testFocusPicksThePortraitAndCanOpenAHiddenFork() throws {
        let family = Family.of(corpus: try corpus, heard: [:], focus: "medusa")
        XCTAssertEqual(family.portrait?.id, "medusa")
        XCTAssertTrue(family.loose.contains { $0.id == "v-medusa" })
    }
}
