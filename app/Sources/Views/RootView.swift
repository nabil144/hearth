import SwiftUI

struct RootView: View {
    @Environment(Store.self) private var store

    var body: some View {
        ZStack {
            Ink.bg.ignoresSafeArea()
            Group {
                switch store.screen {
                case .tonight: TonightView()
                case .lesson: LessonView()
                case .done: DoneView()
                }
            }
            .frame(maxWidth: 430)
            .frame(maxWidth: .infinity)
        }
        .preferredColorScheme(.dark)
    }
}
