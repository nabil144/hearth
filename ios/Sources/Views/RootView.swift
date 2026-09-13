import SwiftUI

struct RootView: View {
    @Environment(Store.self) private var store

    var body: some View {
        ZStack {
            Ink.bg.ignoresSafeArea()
            Group {
                switch store.screen {
                case .tonight:
                    home
                case .lesson:
                    LessonView()
                case .watch(let id):
                    if let url = BundleCorpus.filmURL(lesson: id) {
                        VideoWatchView(url: url)
                    } else {
                        TonightView()
                    }
                case .done:
                    DoneView()
                }
            }
            .frame(maxWidth: 430)
            .frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if case .tonight = store.screen { tabBar }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var home: some View {
        switch store.tab {
        case .tonight: TonightView()
        case .family: FamilyView()
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabItem(.tonight, icon: "🔥", title: "Tonight")
            tabItem(.family, icon: "⟡", title: "Family")
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background {
            Rectangle()
                .fill(Ink.card.opacity(0.88))
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            Ink.line.frame(height: 1)
        }
    }

    private func tabItem(_ tab: Tab, icon: String, title: String) -> some View {
        let on = store.tab == tab
        return Button {
            store.showTab(tab)
        } label: {
            VStack(spacing: 4) {
                Text(icon)
                    .font(.title2)
                Text(title)
                    .font(.caption2)
            }
            .foregroundStyle(on ? Ink.ember : Ink.muted)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
