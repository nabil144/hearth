import Foundation
import Observation
import HearthEngine

enum Screen: Equatable {
    case tonight
    case lesson(lessonId: String, beat: Int)
    case done
}

enum Feedback: Equatable {
    case held
    case miss(text: String, cite: String)
}

@MainActor
@Observable
final class Store {
    var corpus: Corpus
    var progress: Memory
    var screen: Screen = .tonight
    var queue: [Card] = []
    var i = 0
    var held = 0
    var missed = 0
    var choice: Int?
    var feedback: Feedback?
    var reviewing = false
    var silent = false
    private var holdAdvance: Task<Void, Never>?
    private let fileURL: URL
    let voice = Voice()

    init(corpus: Corpus? = nil, directory: URL? = nil) {
        if let corpus {
            self.corpus = corpus
        } else {
            self.corpus = (try? BundleCorpus.load()) ?? Corpus()
        }
        let base = directory ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Hearth", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        fileURL = base.appendingPathComponent("progress.json")
        progress = Self.load(from: fileURL)
        voice.activate()
        voice.onEnded = { [weak self] in
            self?.audioEnded()
        }
    }

    var tonight: Lesson? { corpus.nextLesson(heard: progress.heard) }
    var warm: [Lesson] { corpus.written.filter { progress.heard[$0.id] != nil } }

    var chapterCount: Int {
        let tradition = corpus.written.first?.tradition ?? "greek"
        let n = corpus.lessons.filter { $0.tradition == tradition }.count
        return n == 0 ? 12 : n
    }

    func listen(_ lessonId: String) {
        resetSession()
        reviewing = false
        screen = .lesson(lessonId: lessonId, beat: 0)
        playCurrent()
    }

    func review() {
        let today = CalendarDay.ymd()
        let allowed = Set(progress.heard.keys.flatMap { corpus.lessonsById[$0]?.claims ?? [] })
        let due = progress.cards
            .filter { rec in
                rec.value.due <= today
                    && corpus.cardsById[rec.key] != nil
                    && allowed.contains(corpus.cardsById[rec.key]!.claim)
            }
            .sorted { $0.value.due < $1.value.due }
            .compactMap { corpus.cardsById[$0.key] }
        guard !due.isEmpty else { return }
        resetSession()
        reviewing = true
        queue = Array(due.prefix(3))
        screen = .lesson(lessonId: "", beat: 0)
    }

    func goHome() {
        holdAdvance?.cancel()
        voice.stop()
        resetSession()
        reviewing = false
        screen = .tonight
    }

    func forward() {
        holdAdvance?.cancel()
        choice = nil
        feedback = nil
        silent = false
        if reviewing || isRecall {
            i += 1
            if i >= queue.count { finish(); return }
            playCurrent()
            return
        }
        guard case .lesson(let lessonId, let beat) = screen, let lesson = corpus.lessonsById[lessonId] else { return }
        let next = min(lesson.beats.count - 1, beat + 1)
        screen = .lesson(lessonId: lessonId, beat: next)
        if case .recall = lesson.beats[next] { armRecall(lesson) }
        playCurrent()
    }

    func back() {
        holdAdvance?.cancel()
        choice = nil
        feedback = nil
        silent = false
        if reviewing {
            if i > 0 { i -= 1 }
            else { goHome() }
            return
        }
        if isRecall {
            if i > 0 { i -= 1; return }
        }
        guard case .lesson(let lessonId, let beat) = screen else { return }
        screen = .lesson(lessonId: lessonId, beat: max(0, beat - 1))
        playCurrent()
    }

    func grade(_ card: Card, option: Int) {
        if choice != nil { return }
        choice = option
        if option == card.answer {
            Review.gradeHeld(&progress, cardId: card.id)
            held += 1
            feedback = .held
            save()
            holdAdvance = Task { [weak self] in
                try? await Task.sleep(for: .seconds(1.2))
                guard !Task.isCancelled else { return }
                self?.forward()
            }
        } else {
            Review.gradeMissed(&progress, cardId: card.id)
            missed += 1
            let claim = corpus.claimsById[card.claim]
            feedback = .miss(text: claim?.text ?? "", cite: corpus.cite(card.claim))
            save()
        }
    }

    var currentLesson: Lesson? {
        guard case .lesson(let lessonId, _) = screen else { return nil }
        return corpus.lessonsById[lessonId]
    }

    var currentBeat: Beat? {
        guard case .lesson(_, let beat) = screen, let beats = currentLesson?.beats, beats.indices.contains(beat) else {
            return nil
        }
        return beats[beat]
    }

    var currentCard: Card? {
        if reviewing || isRecall { return queue.indices.contains(i) ? queue[i] : nil }
        if case .check(let id, _) = currentBeat { return corpus.cardsById[id] }
        return nil
    }

    var isRecall: Bool {
        if reviewing { return true }
        if case .recall = currentBeat { return true }
        return false
    }

    private func armRecall(_ lesson: Lesson) {
        if !queue.isEmpty { return }
        queue = Review.pickRecall(corpus: corpus, lesson: lesson, progress: progress)
        i = 0
        if queue.isEmpty { finish() }
    }

    private func finish() {
        voice.stop()
        if !reviewing, case .lesson(let lessonId, _) = screen, !lessonId.isEmpty {
            progress.heard[lessonId] = CalendarDay.ymd()
            save()
        }
        screen = .done
    }

    private func playCurrent() {
        silent = false
        voice.stop()
        guard !reviewing, case .lesson(let lessonId, let beat) = screen, let kind = currentBeat else { return }
        if case .recall = kind { return }
        silent = !voice.play(lesson: lessonId, beat: beat)
    }

    private func audioEnded() {
        if case .still = currentBeat { forward() }
    }

    private func resetSession() {
        holdAdvance?.cancel()
        queue = []
        i = 0
        held = 0
        missed = 0
        choice = nil
        feedback = nil
        silent = false
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private static func load(from url: URL) -> Memory {
        guard let data = try? Data(contentsOf: url) else { return Memory() }
        do {
            return try JSONDecoder().decode(Memory.self, from: data)
        } catch {
            let aside = url.deletingLastPathComponent()
                .appendingPathComponent("progress.broken-\(Int(Date().timeIntervalSince1970)).json")
            try? FileManager.default.moveItem(at: url, to: aside)
            return Memory()
        }
    }
}
