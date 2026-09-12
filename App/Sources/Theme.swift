import SwiftUI

enum Ink {
    static let bg = Color(red: 18 / 255, green: 14 / 255, blue: 11 / 255)
    static let card = Color(red: 31 / 255, green: 24 / 255, blue: 19 / 255)
    static let card2 = Color(red: 42 / 255, green: 33 / 255, blue: 25 / 255)
    static let text = Color(red: 243 / 255, green: 233 / 255, blue: 216 / 255)
    static let muted = Color(red: 168 / 255, green: 151 / 255, blue: 127 / 255)
    static let ember = Color(red: 232 / 255, green: 134 / 255, blue: 58 / 255)
    static let gold = Color(red: 217 / 255, green: 181 / 255, blue: 106 / 255)
    static let line = Color(red: 51 / 255, green: 41 / 255, blue: 31 / 255)
    static let ok = Color(red: 143 / 255, green: 191 / 255, blue: 127 / 255)
    static let bad = Color(red: 217 / 255, green: 106 / 255, blue: 90 / 255)
    static let onEmber = Color(red: 26 / 255, green: 15 / 255, blue: 6 / 255)
    static let display = Font.system(.largeTitle, design: .serif).weight(.bold)
    static let serif = Font.system(.title, design: .serif).weight(.bold)
    static let question = Font.system(.title2, design: .serif).weight(.bold)
    static let hook = Font.system(.title3, design: .serif).italic()
}

struct EmberButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Ink.ember, in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(Ink.onEmber)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
