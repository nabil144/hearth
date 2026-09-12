import SwiftUI
import UIKit
import HearthEngine

struct LessonView: View {
    @Environment(Store.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !store.reviewing, let lesson = store.currentLesson, case .lesson(_, let beat) = store.screen {
                dots(count: lesson.beats.count, now: beat)
                HStack(alignment: .top) {
                    (Text("Chapter \(lesson.n) of \(store.chapterCount) · ") + Text(lesson.title).bold())
                        .font(.subheadline)
                        .foregroundStyle(Ink.muted)
                    Spacer(minLength: 12)
                    Text("\(beat + 1) / \(lesson.beats.count)")
                        .font(.subheadline)
                        .foregroundStyle(Ink.muted)
                }
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    content
                    if store.silent {
                        Text("no audio yet, tap to continue")
                            .font(.subheadline)
                            .foregroundStyle(Ink.muted)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private var content: some View {
        if store.isRecall, let card = store.currentCard {
            CardView(card: card, eyebrow: "Recall · \(store.i + 1) of \(store.queue.count)", spoken: nil)
        } else if let beat = store.currentBeat {
            switch beat {
            case .still(let art, let text):
                still(art, text)
            case .check(_, let spoken):
                if let card = store.currentCard {
                    CardView(card: card, eyebrow: "Family check", spoken: spoken)
                }
            case .variant(let id, let spoken):
                variant(id, spoken)
            case .recall:
                if let card = store.currentCard {
                    CardView(card: card, eyebrow: "Recall · \(store.i + 1) of \(store.queue.count)", spoken: nil)
                }
            }
        }
    }

    private func still(_ art: StillArt?, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Ink.card
                if let art, let url = BundleCorpus.stillURL(art.src), let img = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Text("Still").font(.caption).foregroundStyle(Ink.muted)
                }
                HStack(spacing: 0) {
                    Color.clear.contentShape(Rectangle()).onTapGesture { store.back() }
                    Color.clear.contentShape(Rectangle()).onTapGesture { store.forward() }
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(4 / 5, contentMode: .fit)
            .frame(maxHeight: 340)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Ink.line))
            Text(text)
                .font(.system(size: 18, design: .serif))
                .foregroundStyle(Ink.text)
                .padding(.top, 8)
            if let art {
                credit(art)
            }
        }
    }

    @ViewBuilder
    private func credit(_ art: StillArt) -> some View {
        let label = [art.title, art.credit].filter { !$0.isEmpty }.joined(separator: ", ")
        if let url = URL(string: art.url), !art.url.isEmpty {
            Link(label, destination: url)
                .font(.caption)
                .foregroundStyle(Ink.gold)
        } else if !label.isEmpty {
            Text(label)
                .font(.caption)
                .foregroundStyle(Ink.muted)
        }
    }

    private func variant(_ id: String, _ spoken: String) -> some View {
        let v = store.corpus.variantsById[id]
        return VStack(alignment: .leading, spacing: 12) {
            Text(spoken).font(.subheadline).foregroundStyle(Ink.muted)
            VStack(alignment: .leading, spacing: 10) {
                Text("TWO VERSIONS")
                    .font(.caption.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(Ink.ember)
                Text(v?.question ?? "")
                    .font(Ink.question)
                    .foregroundStyle(Ink.text)
                HStack(alignment: .top, spacing: 10) {
                    ForEach(v?.claims ?? [], id: \.self) { cid in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(store.corpus.sideName(cid))
                                .font(.caption.weight(.bold))
                                .tracking(0.8)
                                .foregroundStyle(Ink.gold)
                            Text(store.corpus.claimsById[cid]?.text ?? "")
                                .font(.subheadline)
                                .foregroundStyle(Ink.text)
                            Text(store.corpus.cite(cid))
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Ink.line))
                                .foregroundStyle(Ink.gold)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Ink.card2, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                Text(v?.note ?? "").font(.subheadline).foregroundStyle(Ink.muted)
                Button("Continue") { store.forward() }
                    .buttonStyle(EmberButton())
                    .padding(.top, 8)
            }
            .padding(20)
            .background(Ink.card, in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Ink.line))
        }
    }

    private func dots(count: Int, now: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<count, id: \.self) { n in
                Capsule()
                    .fill(n < now ? Ink.gold : n == now ? Ink.ember : Ink.line)
                    .frame(height: 3)
            }
        }
    }
}
