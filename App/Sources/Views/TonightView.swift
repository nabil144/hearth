import SwiftUI
import HearthEngine

struct TonightView: View {
    @Environment(Store.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Tonight")
                    .font(Ink.serif)
                    .foregroundStyle(Ink.text)
                Text(dateLine)
                    .font(.subheadline)
                    .foregroundStyle(Ink.muted)
                if let lesson = store.tonight {
                    card(lesson)
                } else {
                    Text("You have heard everything written so far. More is being written.")
                        .foregroundStyle(Ink.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                    Button("Review") { store.review() }
                        .buttonStyle(EmberButton())
                }
                if !store.warm.isEmpty {
                    Text("Still warm")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Ink.text)
                        .padding(.top, 8)
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(store.warm) { lesson in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(lesson.title).font(.headline).foregroundStyle(Ink.text)
                                    Text(heardLine(lesson)).font(.subheadline).foregroundStyle(Ink.muted)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 14)
                            if lesson.id != store.warm.last?.id {
                                Divider().overlay(Ink.line)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .background(Ink.card, in: RoundedRectangle(cornerRadius: 22))
                }
            }
            .padding(16)
            .padding(.top, 24)
        }
    }

    private func card(_ lesson: Lesson) -> some View {
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
                    Text("▶").font(.title2).frame(width: 52, height: 52)
                        .background(Ink.ember, in: Circle())
                        .foregroundStyle(Color(red: 26 / 255, green: 15 / 255, blue: 6 / 255))
                    VStack(alignment: .leading) {
                        Text("Listen").bold().foregroundStyle(Ink.text)
                        Text("One family check halfway. Three recall cards after.")
                            .font(.subheadline).foregroundStyle(Ink.muted)
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
    }

    private var dateLine: String {
        let day = Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide))
        if let lesson = store.tonight {
            return "\(day) · Greek, chapter \(lesson.n) of \(store.corpus.lessons.count)"
        }
        return day
    }

    private func heardLine(_ lesson: Lesson) -> String {
        let iso = store.progress.heard[lesson.id] ?? ""
        return iso == CalendarDay.ymd() ? "Today" : iso
    }
}

struct EmberButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Ink.ember, in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(Color(red: 26 / 255, green: 15 / 255, blue: 6 / 255))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
