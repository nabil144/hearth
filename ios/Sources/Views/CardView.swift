import SwiftUI
import HearthEngine

struct CardView: View {
    @Environment(Store.self) private var store
    let card: Card
    let eyebrow: String
    let spoken: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow)
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(Ink.ember)
            if let spoken, !spoken.isEmpty {
                Text(spoken)
                    .font(.subheadline)
                    .foregroundStyle(Ink.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(card.prompt)
                .font(Ink.question)
                .foregroundStyle(Ink.text)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(card.options.indices, id: \.self) { n in
                Button { store.grade(card, option: n) } label: {
                    Text(card.options[n])
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Ink.card2, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(border(n), lineWidth: store.choice == n ? 2 : 1)
                        )
                        .foregroundStyle(ink(n))
                }
                .buttonStyle(.plain)
                .disabled(store.choice != nil)
            }
            if store.feedback == .held {
                Text("Held.")
                    .foregroundStyle(Ink.ok)
                    .padding(.top, 4)
            }
            if case .miss(let text, let cite) = store.feedback {
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(Ink.text)
                    .padding(.top, 4)
                Text(cite)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Ink.line))
                    .foregroundStyle(Ink.gold)
                Button("Continue") { store.forward() }
                    .buttonStyle(EmberButton())
                    .padding(.top, 8)
            }
        }
        .padding(20)
        .background(Ink.card, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Ink.line))
    }

    private func border(_ n: Int) -> Color {
        guard store.choice == n else { return Ink.line }
        return store.feedback == .held ? Ink.ok : Ink.bad
    }

    private func ink(_ n: Int) -> Color {
        if store.choice == n, store.feedback != .held { return Ink.bad }
        return Ink.text
    }
}
