import AVFoundation

final class Voice: NSObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    var onEnded: (() -> Void)?

    func activate() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback)
        try? session.setActive(true)
    }

    @discardableResult
    func play(lesson: String, beat: Int) -> Bool {
        stop()
        guard let url = BundleCorpus.audioURL(lesson: lesson, beat: beat) else { return false }
        guard let next = try? AVAudioPlayer(contentsOf: url) else { return false }
        player = next
        player?.delegate = self
        return player?.play() ?? false
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
