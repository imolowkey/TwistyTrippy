import SwiftUI
import TwistyTrippy

struct PlaygroundView: View {
    @State private var dnaAnimation: DNAAnimation = .rotate
    @State private var textAnimation: TrippyTextAnimation = .butterfly
    @State private var dnaSpeed = 1.0
    @State private var letteringSpeed = 1.0
    @State private var twists = 2.5
    @State private var fraction = 0.5
    @State private var copy = "Loading the universe…"
    @State private var themeName = "Neon"
    @State private var relativeSizing = true
    @State private var rungs = true
    @State private var visibleText = true

    private var theme: TrippyTheme {
        switch themeName {
        case "Aurora": return .aurora
        case "Fire": return .fire
        case "Psychedelic": return .psychedelic
        default: return .neon
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 22) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TwistyTrippy").font(.system(.largeTitle, design: .rounded, weight: .black))
                            Text("The DNA loader laboratory")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("🍄").font(.largeTitle)
                    }

                    TwistyTrippy(
                        animation: dnaAnimation,
                        sizing: relativeSizing
                            ? .relative(width: fraction, height: 0.75)
                            : .fixed(width: 150, height: 260),
                        theme: theme,
                        speed: dnaSpeed,
                        twists: twists,
                        showsRungs: rungs,
                        text: visibleText ? copy : nil,
                        textAnimation: textAnimation,
                        textSpeed: letteringSpeed,
                        textGradient: themeName == "Psychedelic"
                            ? [.pink, .yellow, .mint] : [.white, .cyan]
                    )
                    .frame(height: min(geometry.size.height * 0.54, 430))
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(Color.white.opacity(0.035))
                    )

                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            Text("LIVE CONTROLS").font(.caption.bold())
                            Spacer()
                            Button("Go mushroom 🍄") {
                                dnaAnimation = .mushroom
                                textAnimation = .mushroom
                                themeName = "Psychedelic"
                                dnaSpeed = 1.6
                            }
                            .font(.caption.bold())
                        }

                        Picker("DNA motion", selection: $dnaAnimation) {
                            ForEach(DNAAnimation.allCases) { animation in
                                Text(animation.rawValue)
                                    .tag(animation)
                            }
                        }
                        Picker("Text motion", selection: $textAnimation) {
                            ForEach(TrippyTextAnimation.allCases) { Text($0.rawValue).tag($0) }
                        }
                        Picker("Gradient theme", selection: $themeName) {
                            ForEach(["Neon", "Aurora", "Fire", "Psychedelic"], id: \.self) {
                                Text($0)
                            }
                        }
                        TextField("Loading message", text: $copy)
                            .textFieldStyle(.roundedBorder)

                        settingSlider("DNA speed", value: $dnaSpeed, range: 0.1...3)
                        settingSlider("Text speed", value: $letteringSpeed, range: 0.1...3)
                        settingSlider("Twists", value: $twists, range: 0.5...5)
                        settingSlider("Width fraction", value: $fraction, range: 0.2...0.9)
                        Toggle("Responsive width", isOn: $relativeSizing)
                        Toggle("Connections", isOn: $rungs)
                        Toggle("Loading message", isOn: $visibleText)
                    }
                    .padding(20)
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22))
                }
                .padding(20)
            }
        }
        .background(
            RadialGradient(colors: [Color(red: 0.10, green: 0.05, blue: 0.19), .black],
                           center: .center, startRadius: 25, endRadius: 440)
                .ignoresSafeArea()
        )
        .foregroundStyle(.white)
        .tint(.cyan)
        .preferredColorScheme(.dark)
    }

    private func settingSlider(_ title: String, value: Binding<Double>,
                               range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(title).font(.subheadline)
                Spacer()
                Text(value.wrappedValue.formatted(.number.precision(.fractionLength(1))))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(value: value, in: range)
        }
    }
}

#Preview("Interactive lab") {
    PlaygroundView()
}
