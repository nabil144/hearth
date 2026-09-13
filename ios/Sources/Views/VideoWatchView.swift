import AVFoundation
import AVKit
import SwiftUI

struct VideoWatchView: View {
    @Environment(Store.self) private var store
    let url: URL
    @State private var player = AVPlayer()
    @State private var playing = true
    @State private var note = "Loading from your computer…"

    var body: some View {
        ZStack {
            Ink.bg.ignoresSafeArea()
            VideoPlayer(player: player)
                .ignoresSafeArea()
            VStack {
                HStack {
                    Button("Exit") { store.goHome() }
                        .font(.headline)
                        .foregroundStyle(Ink.gold)
                    Spacer()
                }
                if !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(Ink.muted)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                Spacer()
                HStack(spacing: 10) {
                    Button("-10s") { seek(-10) }
                    Button(playing ? "Pause" : "Play") { toggle() }
                    Button("+10s") { seek(10) }
                }
                .font(.headline)
                .foregroundStyle(Ink.onEmber)
                .buttonStyle(.borderedProminent)
                .tint(Ink.ember)
            }
            .padding(16)
            .padding(.bottom, 12)
        }
        .onAppear {
            let item = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: item)
            player.play()
            playing = true
            Task {
                try? await Task.sleep(for: .seconds(6))
                if item.status == .readyToPlay {
                    note = ""
                } else {
                    note = "Cannot reach the film. Same Wi-Fi as this computer, allow local network, and keep python3 tools/serve-film.py running."
                }
            }
        }
        .onDisappear {
            player.pause()
        }
    }

    private func toggle() {
        if playing {
            player.pause()
            playing = false
        } else {
            player.play()
            playing = true
        }
    }

    private func seek(_ seconds: Double) {
        let t = player.currentTime().seconds
        let duration = player.currentItem?.duration.seconds ?? t
        let next = min(max(0, t + seconds), duration.isFinite ? duration : max(0, t + seconds))
        player.seek(to: CMTime(seconds: next, preferredTimescale: 600))
    }
}
