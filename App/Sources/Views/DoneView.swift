import SwiftUI

struct DoneView: View {
    @Environment(Store.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HELD")
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(Ink.ember)
            Text("That is tonight.")
                .font(Ink.serif)
                .foregroundStyle(Ink.text)
            Text(tomorrow)
                .foregroundStyle(Ink.muted)
            Text("\(store.held) held · \(store.missed) missed")
                .foregroundStyle(Ink.muted)
            Button("Back to tonight") { store.goHome() }
                .buttonStyle(EmberButton())
                .padding(.top, 12)
            Spacer()
        }
        .padding(24)
    }

    private var tomorrow: String {
        if let next = store.corpus.nextLesson(heard: store.progress.heard) {
            return "Tomorrow: \(next.title)"
        }
        return "You have heard everything written so far."
    }
}
