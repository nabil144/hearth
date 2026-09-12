import SwiftUI

@main
struct HearthApp: App {
    @State private var store: Store

    init() {
        _store = State(initialValue: Store())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
    }
}
