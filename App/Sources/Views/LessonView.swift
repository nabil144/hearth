import SwiftUI
import UIKit
import HearthEngine

struct LessonView: View {
    @Environment(Store.self) private var store

    var body: some View {
        VStack(spacing: 12) {
            if !store.reviewing, let lesson = store.currentLesson, case .lesson(_, let beat) = store.screen {
                dots(count: lesson.beats.count, now: beat)
                HStack {
                    Text("Chapter \(lesson.n) of \(store.corpus.lessons.count) · \(lesson.title)")
                        .font(.subheadline)
                        .foregroundStyle(Ink.muted)
                    Spacer()
                    Text("\(beat + 1) / \(lesson.beats.count)")
                        .font(.subheadline)
                        .foregroundStyle(Ink.muted)
                }
            }
            ScrollView {
                content.padding(.bottom, 24)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    @ViewBuilder
    private var content: some View {
        if let card = store.currentCard, store.reviewing || store.isRecall {
            CardView(card: card, eyebrow: "Recall · \(store.queueIndex + 1) of \(store.queue.count)", spoken: nil)
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
                    CardView(card: card, eyebrow: "Recall · \(store.queueIndex + 1) of \(store.queue.count)", spoken: nil)
                }
            }
        }
    }

    private func still(_ art: StillArt?, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Ink.card
                if let art, let url = BundleCorpus.stillURL(art.src), let img = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    Text("Still").foregroundStyle(Ink.muted)
                }
                HStack(spacing: 0) {
                    Color.clear.contentShape(Rectangle()).onTapGesture { store.back() }
                    Color.clear.contentShape(Rectangle()).onTapGesture { store.forward() }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            Text(text)
                .font(.system(.title3, design: .serif))
                .foregroundStyle(Ink.text)
            if let art {
                Text("\(art.title), \(art.credit)")
                    .font(.caption)
                    .foregroundStyle(Ink.gold)
            }
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
                    .font(.system(.title2, design: .serif).weight(.bold))
                    .foregroundStyle(Ink.text)
                HStack(alignment: .top, spacing: 10) {
                    ForEach(v?.claims ?? [], id: \.self) { cid in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(store.corpus.sideName(cid)).font(.caption.weight(.bold)).foregroundStyle(Ink.gold)
                            Text(store.corpus.claimsById[cid]?.text ?? "").font(.subheadline).foregroundStyle(Ink.text)
                            Text(store.corpus.cite(cid)).font(.caption).foregroundStyle(Ink.gold)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Ink.card2, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                Text(v?.note ?? "").font(.subheadline).foregroundStyle(Ink.muted)
                Button("Continue") { store.forward() }
                    .buttonStyle(EmberButton())
            }
            .padding(20)
            .background(Ink.card, in: RoundedRectangle(cornerRadius: 22))
        }
    }

    private func dots(count: Int, now: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(i < now ? Ink.gold : i == now ? Ink.ember : Ink.line)
                    .frame(height: 3)
            }
        }
    }
}
