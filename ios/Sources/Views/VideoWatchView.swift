import AVKit
import SwiftUI

struct VideoWatchView: View {
    @Environment(Store.self) private var store
    let url: URL
    @State private var player = AVPlayer()

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Ink.bg.ignoresSafeArea()
            VideoPlayer(player: player)
                .ignoresSafeArea()
            Button("Exit") { store.goHome() }
                .font(.headline)
                .foregroundStyle(Ink.gold)
                .padding(16)
        }
        .onAppear {
            player.replaceCurrentItem(with: AVPlayerItem(url: url))
            player.play()
        }
        .onDisappear {
            player.pause()
        }
    }
}
