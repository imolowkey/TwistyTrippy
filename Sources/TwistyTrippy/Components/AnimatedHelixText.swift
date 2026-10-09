//
//  AnimatedHelixText.swift
//  TwistyTrippy
//
//  Created by Mohi on October 8, 2026.
//

import SwiftUI

public struct AnimatedTrippyText: View {
    public var text: String
    public var animation: TrippyTextAnimation
    public var speed: Double
    public var gradient: [Color]
    public var font: Font

    public init(text: String, animation: TrippyTextAnimation = .wave,
                speed: Double = 1, gradient: [Color] = [.white, .cyan],
                font: Font = .system(size: 16, weight: .medium, design: .rounded)) {
        self.text = text
        self.animation = animation
        self.speed = speed
        self.gradient = gradient
        self.font = font
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate * max(0, speed)
            HStack(spacing: 0) {
                ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                    let phase = time * 4 - Double(index) * 0.55
                    let jump = max(0, sin(phase))
                    Text(String(character))
                        .font(font)
                        .foregroundStyle(
                            LinearGradient(colors: gradient.isEmpty ? [.white] : gradient,
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .offset(x: xOffset(phase: phase, index: index, time: time),
                                y: yOffset(phase: phase, jump: jump))
                        .rotationEffect(.degrees(rotation(phase: phase, index: index)))
                        .scaleEffect(scale(phase: phase, jump: jump))
                        .opacity(opacity(index: index, phase: phase, time: time))
                }
            }
            .frame(minHeight: 44)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }

    private func xOffset(phase: Double, index: Int, time: Double) -> CGFloat {
        switch animation {
        case .butterfly: return CGFloat(sin(phase * 1.5) * 5)
        case .mushroom: return CGFloat(sin(time * 2.4 + Double(index) * 1.9) * 9)
        default: return 0
        }
    }

    private func yOffset(phase: Double, jump: Double) -> CGFloat {
        switch animation {
        case .jumping: return CGFloat(-jump * 15)
        case .butterfly: return CGFloat(sin(phase * 1.3) * 9)
        case .wave: return CGFloat(sin(phase) * 7)
        case .mushroom: return CGFloat(sin(phase * 1.7) * 13)
        default: return 0
        }
    }

    private func rotation(phase: Double, index: Int) -> Double {
        switch animation {
        case .butterfly: return sin(phase * 1.7) * (index.isMultiple(of: 2) ? 22 : -22)
        case .mushroom: return sin(phase * 1.4) * 27
        default: return 0
        }
    }

    private func scale(phase: Double, jump: Double) -> CGFloat {
        switch animation {
        case .jumping: return CGFloat(1 + jump * 0.2)
        case .pulse: return CGFloat(0.88 + 0.22 * (1 + sin(phase)) / 2)
        case .butterfly: return CGFloat(0.94 + 0.14 * abs(sin(phase)))
        case .mushroom: return CGFloat(0.8 + 0.42 * (1 + sin(phase)) / 2)
        default: return 1
        }
    }

    private func opacity(index: Int, phase: Double, time: Double) -> Double {
        switch animation {
        case .typewriter:
            let characterCount = max(1, text.count)
            let visible = Int((time * 9).truncatingRemainder(dividingBy: Double(characterCount + 8)))
            return index < visible ? 1 : 0.08
        case .shimmer: return 0.35 + 0.65 * (1 + sin(phase * 1.3)) / 2
        case .mushroom: return 0.45 + 0.55 * abs(sin(phase * 0.65))
        default: return 1
        }
    }
}

#Preview("Text styles") {
    VStack(spacing: 14) {
        ForEach(TrippyTextAnimation.allCases) { style in
            VStack(spacing: 0) {
                Text(style.rawValue).font(.caption).foregroundStyle(.gray)
                AnimatedTrippyText(text: "Loading DNA…", animation: style,
                                  gradient: [.cyan, .pink, .yellow])
            }
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
    .preferredColorScheme(.dark)
}
