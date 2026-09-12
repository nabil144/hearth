import SwiftUI
import HearthEngine

struct CardView: View {
    @Environment(Store.self) private var store
    let card: Card
    let eyebrow: String
    let spoken: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let spoken, !spoken.isEmpty {
                Text(spoken).font(.subheadline).foregroundStyle(Ink.muted)
            }
            VStack(alignment: .leading, spacing: 10) {
                Text(eyebrow)
                    .font(.caption.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(Ink.ember)
                Text(card.prompt)
                    .font(.system(.title2, design: .serif).weight(.bold))
                    .foregroundStyle(Ink.text)
                ForEach(card.options.indices, id: \.self) { i in
                    Button { store.grade(card, option: i) } label: {
                        Text(card.options[i])
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(Ink.card2, in: RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(border(i), lineWidth: store.choice == i ? 2 : 0)
                            )
                            .foregroundStyle(store.choice == i && store.feedback != .held ? Ink.bad : Ink.text)
                    }
                    .buttonStyle(.plain)
                    .disabled(store.choice != nil)
                }
                if store.feedback == .held {
                    Text("Held.").foregroundStyle(Ink.ok)
                }
                if case .miss(let text, let cite) = store.feedback {
                    Text(text).foregroundStyle(Ink.text)
                    Text(cite)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Ink.line))
                        .foregroundStyle(Ink.gold)
                    Button("Continue") { store.forward() }
                        .buttonStyle(EmberButton())
                }
            }
            .padding(20)
            .background(Ink.card, in: RoundedRectangle(cornerRadius: 22))
        }
    }

    private func border(_ i: Int) -> Color {
        guard store.choice == i else { return .clear }
        return store.feedback == .held ? Ink.ok : Ink.bad
    }
}
