import Foundation

public enum Meet: String, Sendable, Equatable {
    case unmet
    case met
}

public struct Kin: Sendable, Equatable, Identifiable {
    public var id: String
    public var name: String
    public var kind: String
    public var generation: Int
    public var meet: Meet
}

public struct Portrait: Sendable, Equatable {
    public var id: String
    public var name: String
    public var line: String
    public var cite: String
    public var confidence: String
}

public struct LooseEdge: Sendable, Equatable, Identifiable {
    public var id: String
    public var question: String
    public var sides: [Side]

    public struct Side: Sendable, Equatable {
        public var work: String
        public var text: String
    }
}

public struct Family: Sendable, Equatable {
    public var tradition: String
    public var rows: [[Kin]]
    public var branches: [[Kin]]
    public var met: Int
    public var total: Int
    public var portrait: Portrait?
    public var loose: [LooseEdge]

    public static func of(corpus: Corpus, heard: [String: String], focus: String?) -> Family {
        let metIds = Self.metIds(corpus: corpus, heard: heard)
        let people = corpus.entities.filter { $0.kind != "object" }
        let orphan = Set(people.filter { Self.isVariantOrphan($0, corpus: corpus, people: people) }.map(\.id))
        let tree = people.filter { !orphan.contains($0.id) }
        let gens = Self.generations(tree)
        let spineIds = Self.component(from: "gaia", in: tree).union(
            tree.contains(where: { $0.id == "chaos" }) ? ["chaos"] : []
        )
        let spine = tree.filter { spineIds.contains($0.id) }
        let other = tree.filter { !spineIds.contains($0.id) }
        let rows = Self.rows(of: spine, gens: gens, metIds: metIds)
        let branches = Self.rows(of: other, gens: gens, metIds: metIds)
        let total = tree.count
        let met = tree.filter { metIds.contains($0.id) }.count
        let pick = focus ?? rows.flatMap { $0 }.first { $0.meet == .met }?.id ?? rows.flatMap { $0 }.first?.id
        let tradition = corpus.traditionsById[corpus.written.first?.tradition ?? ""]?.name
            ?? corpus.written.first?.tradition
            ?? ""
        return Family(
            tradition: tradition,
            rows: rows,
            branches: branches,
            met: met,
            total: total,
            portrait: pick.flatMap { Self.portrait(of: $0, corpus: corpus, heard: heard) },
            loose: Self.loose(corpus: corpus, heard: heard, metIds: metIds, focus: pick, orphan: orphan)
        )
    }

    public static func metIds(corpus: Corpus, heard: [String: String]) -> Set<String> {
        Set(
            heard.keys
                .flatMap { corpus.lessonsById[$0]?.claims ?? [] }
                .flatMap { corpus.claimsById[$0]?.entities ?? [] }
        )
    }

    private static func isVariantOrphan(_ entity: Entity, corpus: Corpus, people: [Entity]) -> Bool {
        if !entity.parents.isEmpty { return false }
        if people.contains(where: { $0.parents.contains(entity.id) }) { return false }
        for variant in corpus.variants {
            for claimId in variant.claims {
                if corpus.claimsById[claimId]?.entities.contains(entity.id) == true { return true }
            }
        }
        return false
    }

    private static func generations(_ people: [Entity]) -> [String: Int] {
        let byId = Dictionary(uniqueKeysWithValues: people.map { ($0.id, $0) })
        var memo: [String: Int] = [:]
        var walking: Set<String> = []
        func gen(_ id: String) -> Int {
            if let seen = memo[id] { return seen }
            guard let entity = byId[id] else { return 0 }
            if walking.contains(id) { return 0 }
            let parents = entity.parents.filter { byId[$0] != nil }
            if parents.isEmpty {
                memo[id] = 0
                return 0
            }
            walking.insert(id)
            let value = 1 + (parents.map(gen).max() ?? 0)
            walking.remove(id)
            memo[id] = value
            return value
        }
        for entity in people { _ = gen(entity.id) }
        return memo
    }

    private static func component(from start: String, in people: [Entity]) -> Set<String> {
        let byId = Dictionary(uniqueKeysWithValues: people.map { ($0.id, $0) })
        guard byId[start] != nil else { return [] }
        var neighbors: [String: Set<String>] = [:]
        for entity in people {
            for parent in entity.parents where byId[parent] != nil {
                neighbors[entity.id, default: []].insert(parent)
                neighbors[parent, default: []].insert(entity.id)
            }
        }
        var seen: Set<String> = []
        var stack = [start]
        while let id = stack.popLast() {
            if !seen.insert(id).inserted { continue }
            stack.append(contentsOf: neighbors[id] ?? [])
        }
        return seen
    }

    private static func rows(of people: [Entity], gens: [String: Int], metIds: Set<String>) -> [[Kin]] {
        let kin = people.map { entity in
            Kin(
                id: entity.id,
                name: entity.name,
                kind: entity.kind,
                generation: gens[entity.id] ?? 0,
                meet: metIds.contains(entity.id) ? .met : .unmet
            )
        }
        let groups = Dictionary(grouping: kin, by: \.generation)
        return groups.keys.sorted().map { gen in
            groups[gen]!.sorted { $0.name < $1.name }
        }
    }

    private static func portrait(of id: String, corpus: Corpus, heard: [String: String]) -> Portrait? {
        guard let entity = corpus.entitiesById[id] else { return nil }
        let taught = Set(heard.keys.flatMap { corpus.lessonsById[$0]?.claims ?? [] })
        let mentioning = corpus.claims.filter { $0.entities.contains(id) }
        let claim = mentioning.first { taught.contains($0.id) } ?? mentioning.first
        return Portrait(
            id: entity.id,
            name: entity.name,
            line: claim?.text ?? "",
            cite: claim.map { corpus.cite($0.id) } ?? "",
            confidence: claim?.confidence ?? ""
        )
    }

    private static func subject(of variant: Variant, corpus: Corpus) -> String? {
        let sets = variant.claims.compactMap { claimId -> Set<String>? in
            corpus.claimsById[claimId].map { Set($0.entities) }
        }
        guard let first = sets.first else { return nil }
        let common = sets.dropFirst().reduce(first) { $0.intersection($1) }
        return common.min { a, b in
            let ac = corpus.claims.filter { $0.entities.contains(a) }.count
            let bc = corpus.claims.filter { $0.entities.contains(b) }.count
            if ac != bc { return ac < bc }
            return a < b
        }
    }

    private static func loose(
        corpus: Corpus,
        heard: [String: String],
        metIds: Set<String>,
        focus: String?,
        orphan: Set<String>
    ) -> [LooseEdge] {
        let taught = Set(heard.keys.flatMap { corpus.lessonsById[$0]?.claims ?? [] })
        return corpus.variants.compactMap { variant in
            let subject = Self.subject(of: variant, corpus: corpus)
            let heardSide = variant.claims.contains(where: taught.contains)
            let subjectMet = subject.map(metIds.contains) ?? false
            let orphanAfterHearing = subject.map(orphan.contains) ?? false && !metIds.isEmpty
            let focused = subject != nil && subject == focus
            guard heardSide || subjectMet || orphanAfterHearing || focused else { return nil }
            let sides = variant.claims.compactMap { claimId -> LooseEdge.Side? in
                guard let claim = corpus.claimsById[claimId] else { return nil }
                return LooseEdge.Side(work: corpus.sideName(claimId), text: claim.text)
            }
            return LooseEdge(id: variant.id, question: variant.question, sides: sides)
        }
    }
}
