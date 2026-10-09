import SwiftUI
import UIKit

public enum DNAAnimation: String, CaseIterable, Identifiable, Sendable {
    case rotate = "Rotate"
    case reverse = "Reverse"
    case breathe = "Breathe"
    case ripple = "Ripple"
    case mushroom = "Mushroom 🍄"
    case still = "Still"

    public var id: String { rawValue }
}

public enum TrippyTextAnimation: String, CaseIterable, Identifiable, Sendable {
    case none = "None"
    case jumping = "Jumping"
    case butterfly = "Butterfly"
    case wave = "Wave"
    case pulse = "Pulse"
    case typewriter = "Typewriter"
    case shimmer = "Shimmer"
    case mushroom = "Mushroom 🍄"

    public var id: String { rawValue }
}

/// Relative sizing uses the *container's* dimensions, not the device's screen.
public enum TrippySizing {
    case fixed(width: CGFloat, height: CGFloat)
    case relative(width: CGFloat, height: CGFloat)
    case adaptive(maxWidth: CGFloat = 210, maxHeight: CGFloat = 360)
}

/// Colors interpolate smoothly down each DNA strand. Use `.solid` or `.gradient`.
public enum TrippyInk {
    case solid(Color)
    case gradient([Color])

    public func color(at position: Double) -> Color {
        let palette: [Color]
        switch self {
        case .solid(let color): return color
        case .gradient(let colors): palette = colors
        }
        guard let first = palette.first else { return .white }
        guard palette.count > 1 else { return first }

        let p = min(max(position, 0), 1) * Double(palette.count - 1)
        let i = min(Int(p), palette.count - 2)
        let fraction = p - Double(i)
        let a = UIColor(palette[i])
        let b = UIColor(palette[i + 1])
        var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        guard a.getRed(&ar, green: &ag, blue: &ab, alpha: &aa),
              b.getRed(&br, green: &bg, blue: &bb, alpha: &ba) else {
            return palette[i]
        }
        let t = CGFloat(fraction)
        return Color(.sRGB,
                     red: Double(ar + (br - ar) * t),
                     green: Double(ag + (bg - ag) * t),
                     blue: Double(ab + (bb - ab) * t),
                     opacity: Double(aa + (ba - aa) * t))
    }
}

public struct TrippyTheme {
    public var front: TrippyInk
    public var back: TrippyInk
    public var rungs: Color
    public var glow: CGFloat
    public var particleSize: CGFloat

    public init(
        front: TrippyInk = .gradient([.cyan, .mint, .blue]),
        back: TrippyInk = .gradient([.pink, .purple, .orange]),
        rungs: Color = .white,
        glow: CGFloat = 8,
        particleSize: CGFloat = 3.6
    ) {
        self.front = front
        self.back = back
        self.rungs = rungs
        self.glow = glow
        self.particleSize = particleSize
    }

    public static let neon = TrippyTheme()
    public static let aurora = TrippyTheme(
        front: .gradient([.mint, .cyan, .indigo]),
        back: .gradient([.purple, .pink, .mint]),
        glow: 11
    )
    public static let fire = TrippyTheme(
        front: .gradient([.yellow, .orange, .red]),
        back: .gradient([.red, .pink, .purple]),
        glow: 12
    )
    public static let psychedelic = TrippyTheme(
        front: .gradient([.green, .yellow, .pink, .cyan]),
        back: .gradient([.pink, .indigo, .orange, .mint]),
        glow: 15, particleSize: 4.3
    )
}
