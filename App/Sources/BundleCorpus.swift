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
        let file = URL(fileURLWithPath: src).lastPathComponent
        let stem = URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent
        if let url = Bundle.main.url(forResource: stem, withExtension: "jpg", subdirectory: "stills") {
            return url
        }
        guard let root = Bundle.main.resourcePath else { return nil }
        let relative = URL(fileURLWithPath: root).appendingPathComponent(src)
        if FileManager.default.fileExists(atPath: relative.path) { return relative }
        let nested = URL(fileURLWithPath: root).appendingPathComponent("stills").appendingPathComponent(file)
        return FileManager.default.fileExists(atPath: nested.path) ? nested : nil
    }

    static func audioURL(lesson: String, beat: Int) -> URL? {
        if let url = Bundle.main.url(forResource: "\(beat)", withExtension: "mp3", subdirectory: "audio/\(lesson)") {
            return url
        }
        guard let root = Bundle.main.resourcePath else { return nil }
        let url = URL(fileURLWithPath: root).appendingPathComponent("audio/\(lesson)/\(beat).mp3")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }
}
