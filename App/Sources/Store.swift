import Foundation
import Observation
import HearthEngine

enum Screen: Equatable {
    case tonight
    case lesson(id: String, beat: Int)
    case done
}

enum Feedback: Equatable {
    case held
    case miss(text: String, cite: String)
}

@Observable
final class Store {
    var corpus: Corpus
    var progress: Progress
    var screen: Screen = .tonight
    var queue: [Card] = []
    var queueIndex = 0
    var held = 0
    var missed = 0
    var choice: Int?
    var feedback: Feedback?
    var reviewing = false
    private var holdAdvance: DispatchWorkItem?
    private let fileURL: URL
    let voice = Voice()

    init(corpus: Corpus? = nil, directory: URL? = nil) {
        if let corpus {
            self.corpus = corpus
        } else {
            self.corpus = (try? BundleCorpus.load()) ?? Corpus(traditions: [], sources: [], entities: [], claims: [], variants: [], cards: [], lessons: [])
        }
        let base = directory ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Hearth", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        fileURL = base.appendingPathComponent("progress.json")
        progress = Self.load(from: fileURL)
        voice.activate()
        voice.onEnded = { [weak self] in
            DispatchQueue.main.async { self?.audioEnded() }
        }
    }

    var tonight: Lesson? { corpus.nextLesson(heard: progress.heard) }
    var warm: [Lesson] { corpus.written.filter { progress.heard[$0.id] != nil } }

    func listen(_ id: String) {
        clearSession()
        reviewing = false
        screen = .lesson(id: id, beat: 0)
        playCurrent()
    }

    func review() {
        let allowed = Set(progress.heard.keys.flatMap { corpus.lessonsById[$0]?.claims ?? [] })
        let due = progress.cards
            .filter { rec in
                rec.value.due <= CalendarDay.ymd()
                    && corpus.cardsById[rec.key] != nil
                    && allowed.contains(corpus.cardsById[rec.key]!.claim)
            }
            .sorted { $0.value.due < $1.value.due }
            .compactMap { corpus.cardsById[$0.key] }
        guard !due.isEmpty else { return }
        clearSession()
        reviewing = true
        queue = Array(due.prefix(3))
        screen = .lesson(id: tonight?.id ?? corpus.written.last?.id ?? "", beat: 0)
    }

    func goHome() {
        holdAdvance?.cancel()
        voice.stop()
        clearSession()
        reviewing = false
        screen = .tonight
    }

    func forward() {
        holdAdvance?.cancel()
        choice = nil
        feedback = nil
        if reviewing || isRecall {
            queueIndex += 1
            if queueIndex >= queue.count { finish(); return }
            playCurrent()
            return
        }
        guard case .lesson(let id, let beat) = screen, let lesson = corpus.lessonsById[id] else { return }
        let next = min(lesson.beats.count - 1, beat + 1)
        screen = .lesson(id: id, beat: next)
        if case .recall = lesson.beats[next] { armRecall(lesson) }
        playCurrent()
    }

    func back() {
        holdAdvance?.cancel()
        choice = nil
        feedback = nil
        if reviewing {
            if queueIndex > 0 { queueIndex -= 1 }
            else { goHome() }
            return
        }
        if isRecall {
            if queueIndex > 0 { queueIndex -= 1; return }
        }
        guard case .lesson(let id, let beat) = screen else { return }
        screen = .lesson(id: id, beat: max(0, beat - 1))
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
            let work = DispatchWorkItem { [weak self] in self?.forward() }
            holdAdvance = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: work)
        } else {
            Review.gradeMissed(&progress, cardId: card.id)
            missed += 1
            let claim = corpus.claimsById[card.claim]
            feedback = .miss(text: claim?.text ?? "", cite: corpus.cite(card.claim))
            save()
        }
    }

    var currentLesson: Lesson? {
        guard case .lesson(let id, _) = screen else { return nil }
        return corpus.lessonsById[id]
    }

    var currentBeat: Beat? {
        guard case .lesson(_, let beat) = screen else { return nil }
        return currentLesson?.beats[safe: beat]
    }

    var currentCard: Card? {
        if reviewing || isRecall { return queue[safe: queueIndex] }
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
        queueIndex = 0
        if queue.isEmpty { finish() }
    }

    private func finish() {
        voice.stop()
        if !reviewing, case .lesson(let id, _) = screen {
            progress.heard[id] = CalendarDay.ymd()
            save()
        }
        screen = .done
    }

    private func playCurrent() {
        voice.stop()
        guard !reviewing, case .lesson(let id, let beat) = screen, let kind = currentBeat else { return }
        if case .recall = kind { return }
        voice.play(lesson: id, beat: beat)
    }

    private func audioEnded() {
        if case .still = currentBeat { forward() }
    }

    private func clearSession() {
        holdAdvance?.cancel()
        queue = []
        queueIndex = 0
        held = 0
        missed = 0
        choice = nil
        feedback = nil
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private static func load(from url: URL) -> Progress {
        guard let data = try? Data(contentsOf: url) else { return Progress() }
        do {
            return try JSONDecoder().decode(Progress.self, from: data)
        } catch {
            let aside = url.deletingLastPathComponent()
                .appendingPathComponent("progress.broken-\(Int(Date().timeIntervalSince1970)).json")
            try? FileManager.default.moveItem(at: url, to: aside)
            return Progress()
        }
    }
}

private extension Array {
    subscript(safe i: Int) -> Element? {
        indices.contains(i) ? self[i] : nil
    }
}
