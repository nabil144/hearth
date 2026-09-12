import AVFoundation
import HearthEngine

final class Voice: NSObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    var onEnded: (() -> Void)?

    func activate() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio)
        try? session.setActive(true)
    }

    func play(lesson: String, beat: Int) {
        stop()
        guard let url = BundleCorpus.audioURL(lesson: lesson, beat: beat) else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.delegate = self
        player?.play()
    }

    func stop() {
        player?.delegate = nil
        player?.stop()
        player = nil
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onEnded?()
    }
}
