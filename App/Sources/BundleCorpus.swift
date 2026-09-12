import Foundation
import HearthEngine

enum BundleCorpus {
    static func load() throws -> Corpus {
        guard let url = Bundle.main.url(forResource: "greek", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try Corpus.decode(Data(contentsOf: url))
    }

    static func stillURL(_ src: String) -> URL? {
        let name = URL(fileURLWithPath: src).deletingPathExtension().lastPathComponent
        return Bundle.main.url(forResource: name, withExtension: "jpg", subdirectory: "stills")
    }

    static func audioURL(lesson: String, beat: Int) -> URL? {
        Bundle.main.url(forResource: "\(beat)", withExtension: "mp3", subdirectory: "audio/\(lesson)")
    }
}
