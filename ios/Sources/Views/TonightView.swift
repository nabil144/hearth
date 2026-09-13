import SwiftUI
import HearthEngine

struct TonightView: View {
    @Environment(Store.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Tonight")
                    .font(Ink.display)
                    .foregroundStyle(Ink.text)
                Text(dateLine)
                    .font(.subheadline)
                    .foregroundStyle(Ink.muted)
                    .padding(.bottom, 4)
                if let lesson = store.tonight {
                    telling(lesson)
                } else {
                    Text("You have heard everything written so far. More is being written.")
                        .foregroundStyle(Ink.muted)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                    Button("Review") { store.review() }
                        .buttonStyle(EmberButton())
                }
                ForEach(store.films.filter { $0.id != store.tonight?.id }) { lesson in
                    watchCard(lesson)
                }
                if !store.warm.isEmpty {
                    Text("Still warm")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Ink.text)
                        .padding(.top, 10)
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(store.warm) { lesson in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(lesson.title).font(.headline).foregroundStyle(Ink.text)
                                    Text(heardLine(lesson)).font(.subheadline).foregroundStyle(Ink.muted)
                                }
                                Spacer()
                                if BundleCorpus.filmURL(lesson: lesson.id) != nil {
                                    Button("Watch") { store.watch(lesson.id) }
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Ink.gold)
                                }
                            }
                            .padding(.vertical, 14)
                            if lesson.id != store.warm.last?.id {
                                Ink.line.frame(height: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .background(Ink.card, in: RoundedRectangle(cornerRadius: 22))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(Ink.line))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 40)
            .padding(.bottom, 40)
        }
    }

    private func telling(_ lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TONIGHT'S TELLING")
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(Ink.ember)
            Text(lesson.title)
                .font(Ink.serif)
                .foregroundStyle(Ink.text)
            Text(lesson.hook)
                .font(Ink.hook)
                .foregroundStyle(Ink.muted)
            Text("\(store.corpus.works(of: lesson)) · \(lesson.minutes) min")
                .font(.subheadline)
                .foregroundStyle(Ink.muted)
            Button { store.listen(lesson.id) } label: {
                HStack(spacing: 14) {
                    Text("▶")
                        .font(.title2)
                        .frame(width: 52, height: 52)
                        .background(Ink.ember, in: Circle())
                        .foregroundStyle(Ink.onEmber)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Listen").bold().foregroundStyle(Ink.text)
                        Text("One family check halfway. Three recall cards after.")
                            .font(.subheadline)
                            .foregroundStyle(Ink.muted)
                    }
                    Spacer()
                }
                .padding(14)
                .background(Ink.card2, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
            if store.films.contains(where: { $0.id == lesson.id }) {
                Button { store.watch(lesson.id) } label: {
                    HStack(spacing: 14) {
                        Text("▣")
                            .font(.title2)
                            .frame(width: 52, height: 52)
                            .background(Ink.card, in: Circle())
                            .foregroundStyle(Ink.gold)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Watch").bold().foregroundStyle(Ink.text)
                            Text("Cartoon stills, pause, skip ten seconds.")
                                .font(.subheadline)
                                .foregroundStyle(Ink.muted)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Ink.card2, in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(Ink.card, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Ink.line))
    }

    private func watchCard(_ lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WATCH")
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(Ink.ember)
            Text(lesson.title)
                .font(Ink.serif)
                .foregroundStyle(Ink.text)
            Text(lesson.hook)
                .font(Ink.hook)
                .foregroundStyle(Ink.muted)
            Button { store.watch(lesson.id) } label: {
                HStack(spacing: 14) {
                    Text("▣")
                        .font(.title2)
                        .frame(width: 52, height: 52)
                        .background(Ink.card, in: Circle())
                        .foregroundStyle(Ink.gold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Watch").bold().foregroundStyle(Ink.text)
                        Text("Cartoon stills, pause, skip ten seconds.")
                            .font(.subheadline)
                            .foregroundStyle(Ink.muted)
                    }
                    Spacer()
                }
                .padding(14)
                .background(Ink.card2, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .padding(20)
        .background(Ink.card, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Ink.line))
    }

    private var dateLine: String {
        let day = Date.now.formatted(
            .dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: "en_GB"))
        )
        if let lesson = store.tonight {
            return "\(day) · Greek, chapter \(lesson.n) of \(store.chapterCount)"
        }
        return day
    }

    private func heardLine(_ lesson: Lesson) -> String {
        guard let iso = store.progress.heard[lesson.id] else { return "" }
        if iso == CalendarDay.ymd() { return "Today" }
        let parts = iso.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return iso }
        var comps = DateComponents()
        comps.year = parts[0]
        comps.month = parts[1]
        comps.day = parts[2]
        guard let date = Calendar.current.date(from: comps) else { return iso }
        return date.formatted(.dateTime.day().month(.abbreviated).locale(Locale(identifier: "en_GB")))
    }
}
