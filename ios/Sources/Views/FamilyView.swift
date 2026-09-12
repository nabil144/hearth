import SwiftUI
import HearthEngine

struct FamilyView: View {
    @Environment(Store.self) private var store

    private var family: Family { store.family }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Family")
                    .font(Ink.display)
                    .foregroundStyle(Ink.text)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Ink.muted)
                    .padding(.bottom, 4)
                card {
                    tree(family.rows)
                }
                if !family.branches.isEmpty {
                    card {
                        Text("Also in the graph")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Ink.muted)
                        tree(family.branches)
                    }
                }
                if let portrait = family.portrait {
                    portraitCard(portrait)
                }
                ForEach(family.loose) { edge in
                    looseCard(edge)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 40)
            .padding(.bottom, 40)
        }
    }

    private var subtitle: String {
        "\(family.tradition) · \(family.met) of \(family.total) figures met · tap a name"
    }

    private func tree(_ rows: [[Kin]]) -> some View {
        let hot = family.portrait?.id
        return VStack(spacing: 8) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 {
                    Text("│")
                        .font(.caption)
                        .foregroundStyle(Ink.muted)
                        .frame(maxWidth: .infinity)
                }
                Wrap(spacing: 8) {
                    ForEach(row) { kin in
                        pill(kin, hot: hot)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 6)
    }

    private func pill(_ kin: Kin, hot: String?) -> some View {
        let on = kin.id == hot
        return Button {
            store.inspect(kin.id)
        } label: {
            Text(kin.name)
                .font(.subheadline.weight(on ? .bold : .regular))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(on ? Ink.ember : Ink.card2, in: Capsule())
                .overlay(Capsule().stroke(on ? Ink.ember : Ink.line))
                .foregroundStyle(on ? Ink.onEmber : Ink.text)
                .opacity(on || kin.meet == .met ? 1 : 0.35)
        }
        .buttonStyle(.plain)
    }

    private func portraitCard(_ portrait: Portrait) -> some View {
        card {
            Text(portrait.name)
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(Ink.ember)
            Text(portrait.line)
                .font(Ink.serif)
                .foregroundStyle(Ink.text)
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(portrait.confidence)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Ink.card2, in: Capsule())
                    .overlay(Capsule().stroke(Ink.line))
                    .foregroundStyle(confidenceColor(portrait.confidence))
                if !portrait.cite.isEmpty {
                    Text(portrait.cite)
                        .font(.caption)
                        .foregroundStyle(Ink.gold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Ink.line))
                }
            }
        }
    }

    private func looseCard(_ edge: LooseEdge) -> some View {
        card {
            Text("Loose edge")
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(Ink.ember)
            Text(edge.question)
                .font(Ink.serif)
                .foregroundStyle(Ink.text)
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(edge.sides.enumerated()), id: \.offset) { _, side in
                    sideCard(side)
                }
            }
        }
    }

    private func sideCard(_ side: LooseEdge.Side) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(side.work)
                .font(.caption.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(Ink.gold)
            Text(side.text)
                .font(.subheadline)
                .foregroundStyle(Ink.text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Ink.card2, in: RoundedRectangle(cornerRadius: 16))
    }

    private func confidenceColor(_ confidence: String) -> Color {
        switch confidence {
        case "attested": Ink.ok
        case "later-invention": Ink.bad
        default: Ink.muted
        }
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Ink.card, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Ink.line))
    }
}

private struct Wrap: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        plan(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let frames = plan(proposal: ProposedViewSize(width: bounds.width, height: bounds.height), subviews: subviews).frames
        for (subview, frame) in zip(subviews, frames) {
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func plan(proposal: ProposedViewSize, subviews: Subviews) -> (frames: [CGRect], size: CGSize) {
        let limit = proposal.width ?? .infinity
        var frames = Array(repeating: CGRect.zero, count: subviews.count)
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var row: [(Int, CGSize)] = []
        var tall: CGFloat = 0
        var wide: CGFloat = 0

        func flush(_ rowWidth: CGFloat) {
            let shift = limit.isFinite ? max((limit - rowWidth) / 2, 0) : 0
            var cursor = shift
            for (index, size) in row {
                frames[index] = CGRect(x: cursor, y: y, width: size.width, height: size.height)
                cursor += size.width + spacing
            }
            wide = max(wide, rowWidth)
            tall = y + rowHeight
            row.removeAll(keepingCapacity: true)
        }

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0 && x + spacing + size.width > limit {
                flush(x)
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            if x > 0 { x += spacing }
            row.append((index, size))
            x += size.width
            rowHeight = max(rowHeight, size.height)
        }
        if !row.isEmpty { flush(x) }
        return (frames, CGSize(width: limit.isFinite ? limit : wide, height: tall))
    }
}
