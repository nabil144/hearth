import SwiftUI

struct RootView: View {
    @Environment(Store.self) private var store

    var body: some View {
        ZStack {
            Ink.bg.ignoresSafeArea()
            switch store.screen {
            case .tonight: TonightView()
            case .lesson: LessonView()
            case .done: DoneView()
            }
        }
        .preferredColorScheme(.dark)
    }
}
