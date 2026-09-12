import Foundation

public struct Tradition: Codable, Sendable, Equatable, Identifiable {
    public var id: String
    public var name: String
    public var sensitivity: String
}

public struct Source: Codable, Sendable, Equatable, Identifiable {
    public var id: String
    public var tradition: String
    public var work: String
    public var locator: String
    public var paraphrase: String
}

public struct Entity: Codable, Sendable, Equatable, Identifiable {
    public var id: String
    public var kind: String
    public var name: String
    public var parents: [String]
}

public struct Claim: Codable, Sendable, Equatable, Identifiable {
    public var id: String
    public var confidence: String
    public var source: String
    public var entities: [String]
    public var text: String
}

public struct Variant: Codable, Sendable, Equatable, Identifiable {
    public var id: String
    public var question: String
    public var claims: [String]
    public var note: String
}

public struct Card: Codable, Sendable, Equatable, Identifiable {
    public var id: String
    public var claim: String
    public var prompt: String
    public var options: [String]
    public var answer: Int
}

public struct StillArt: Codable, Sendable, Equatable {
    public var src: String
    public var title: String
    public var maker: String
    public var date: String
    public var credit: String
    public var url: String
}

public enum Beat: Codable, Sendable, Equatable {
    case still(art: StillArt?, text: String)
    case check(card: String, text: String)
    case variant(String, text: String)
    case recall

    public var kind: String {
        switch self {
        case .still: return "still"
        case .check: return "check"
        case .variant: return "variant"
        case .recall: return "recall"
        }
    }

    public var spoken: String? {
        switch self {
        case .still(_, let text), .check(_, let text), .variant(_, let text): return text
        case .recall: return nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind, still, text, card, variant
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(String.self, forKey: .kind) {
        case "still":
            self = .still(art: try c.decodeIfPresent(StillArt.self, forKey: .still), text: try c.decode(String.self, forKey: .text))
        case "check":
            self = .check(card: try c.decode(String.self, forKey: .card), text: try c.decode(String.self, forKey: .text))
        case "variant":
            self = .variant(try c.decode(String.self, forKey: .variant), text: try c.decode(String.self, forKey: .text))
        case "recall":
            self = .recall
        default:
            throw DecodingError.dataCorruptedError(forKey: .kind, in: c, debugDescription: "unknown beat kind")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(kind, forKey: .kind)
        switch self {
        case .still(let art, let text):
            try c.encodeIfPresent(art, forKey: .still)
            try c.encode(text, forKey: .text)
        case .check(let card, let text):
            try c.encode(card, forKey: .card)
            try c.encode(text, forKey: .text)
        case .variant(let id, let text):
            try c.encode(id, forKey: .variant)
            try c.encode(text, forKey: .text)
        case .recall:
            break
        }
    }
}

public struct Lesson: Codable, Sendable, Equatable, Identifiable {
    public var id: String
    public var n: Int
    public var tradition: String
    public var title: String
    public var hook: String
    public var minutes: Int
    public var sources: [String]
    public var claims: [String]
    public var variant: String?
    public var beats: [Beat]

    public var isWritten: Bool { !beats.isEmpty }
}

public struct Corpus: Codable, Sendable, Equatable {
    public init(
        traditions: [Tradition] = [],
        sources: [Source] = [],
        entities: [Entity] = [],
        claims: [Claim] = [],
        variants: [Variant] = [],
        cards: [Card] = [],
        lessons: [Lesson] = []
    ) {
        self.traditions = traditions
        self.sources = sources
        self.entities = entities
        self.claims = claims
        self.variants = variants
        self.cards = cards
        self.lessons = lessons
    }

    public var traditions: [Tradition]
    public var sources: [Source]
    public var entities: [Entity]
    public var claims: [Claim]
    public var variants: [Variant]
    public var cards: [Card]
    public var lessons: [Lesson]

    public var traditionsById: [String: Tradition] { Dictionary(uniqueKeysWithValues: traditions.map { ($0.id, $0) }) }
    public var sourcesById: [String: Source] { Dictionary(uniqueKeysWithValues: sources.map { ($0.id, $0) }) }
    public var entitiesById: [String: Entity] { Dictionary(uniqueKeysWithValues: entities.map { ($0.id, $0) }) }
    public var claimsById: [String: Claim] { Dictionary(uniqueKeysWithValues: claims.map { ($0.id, $0) }) }
    public var variantsById: [String: Variant] { Dictionary(uniqueKeysWithValues: variants.map { ($0.id, $0) }) }
    public var cardsById: [String: Card] { Dictionary(uniqueKeysWithValues: cards.map { ($0.id, $0) }) }
    public var lessonsById: [String: Lesson] { Dictionary(uniqueKeysWithValues: lessons.map { ($0.id, $0) }) }

    public var written: [Lesson] { lessons.filter(\.isWritten) }

    public func cite(_ claimId: String) -> String {
        guard let claim = claimsById[claimId], let source = sourcesById[claim.source] else { return "" }
        return "\(source.work) \(source.locator)"
    }

    public func sideName(_ claimId: String) -> String {
        guard let claim = claimsById[claimId], let source = sourcesById[claim.source] else { return "" }
        return source.work.split { $0 == " " || $0 == "," }.first.map(String.init) ?? ""
    }

    public func works(of lesson: Lesson) -> String {
        var seen = Set<String>()
        var out: [String] = []
        for id in lesson.sources {
            guard let w = sourcesById[id]?.work, seen.insert(w).inserted else { continue }
            out.append(w)
        }
        return out.joined(separator: ", ")
    }

    public func nextLesson(heard: [String: String]) -> Lesson? {
        written.first { heard[$0.id] == nil }
    }

    public static func decode(_ data: Data) throws -> Corpus {
        try JSONDecoder().decode(Corpus.self, from: data)
    }
}
