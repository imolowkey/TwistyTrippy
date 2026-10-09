import SwiftUI

/// Reusable, Canvas-powered DNA loading animation.
///
/// Example:
/// `TwistyTrippy(animation: .mushroom, text: "Transcending…", textAnimation: .butterfly)`
public struct TwistyTrippy: View {
    public var animation: DNAAnimation
    public var sizing: TrippySizing
    public var theme: TrippyTheme
    public var speed: Double
    public var twists: Double
    public var strands: Int
    public var showsRungs: Bool
    public var text: String?
    public var textAnimation: TrippyTextAnimation
    public var textSpeed: Double
    public var textGradient: [Color]
    public var textFont: Font
    public var spacing: CGFloat

    public init(
        animation: DNAAnimation = .rotate,
        sizing: TrippySizing = .adaptive(),
        theme: TrippyTheme = .neon,
        speed: Double = 1,
        twists: Double = 2.5,
        strands: Int = 64,
        showsRungs: Bool = true,
        text: String? = "Loading…",
        textAnimation: TrippyTextAnimation = .wave,
        textSpeed: Double = 1,
        textGradient: [Color] = [.white, .cyan],
        textFont: Font = .system(size: 16, weight: .medium, design: .rounded),
        spacing: CGFloat = 20
    ) {
        self.animation = animation
        self.sizing = sizing
        self.theme = theme
        self.speed = speed
        self.twists = twists
        self.strands = strands
        self.showsRungs = showsRungs
        self.text = text
        self.textAnimation = textAnimation
        self.textSpeed = textSpeed
        self.textGradient = textGradient
        self.textFont = textFont
        self.spacing = spacing
    }

    public var body: some View {
        GeometryReader { geometry in
            let dimensions = dimensions(in: geometry.size)
            VStack(spacing: spacing) {
                TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
                    Canvas(opaque: false, rendersAsynchronously: true) { context, size in
                        render(context: context, size: size,
                               time: timeline.date.timeIntervalSinceReferenceDate)
                    }
                }
                .frame(width: dimensions.width, height: dimensions.height)
                .accessibilityHidden(true)

                if let text, !text.isEmpty {
                    AnimatedTrippyText(
                        text: text,
                        animation: textAnimation,
                        speed: textSpeed,
                        gradient: textGradient,
                        font: textFont
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text ?? "Loading")
    }

    private func dimensions(in available: CGSize) -> CGSize {
        switch sizing {
        case .fixed(let width, let height):
            return CGSize(width: max(1, width), height: max(1, height))
        case .relative(let width, let height):
            return CGSize(width: max(1, available.width * min(max(width, 0), 1)),
                          height: max(1, available.height * min(max(height, 0), 1)))
        case .adaptive(let maxWidth, let maxHeight):
            return CGSize(width: min(available.width * 0.56, maxWidth),
                          height: min(available.height * 0.58, maxHeight))
        }
    }

    private func render(context: GraphicsContext, size: CGSize, time: TimeInterval) {
        let t = time * max(0, speed)
        let count = max(16, min(180, strands))
        let top = size.height * 0.065
        let extent = size.height * 0.87
        let baseRadius = size.width * 0.36
        let twistCount = max(0.25, twists)

        // Draw far-side dots before near-side dots for convincing depth.
        struct Dot {
            let point: CGPoint
            let color: Color
            let depth: Double
            let fade: Double
        }
        var backDots: [Dot] = []
        var frontDots: [Dot] = []

        for index in 0...count {
            let p = Double(index) / Double(count)
            let y = top + extent * CGFloat(p)
            let phase = p * twistCount * 2 * .pi
            let motion: Double
            switch animation {
            case .rotate: motion = t * 2.2
            case .reverse: motion = -t * 2.2
            case .breathe: motion = sin(t * 1.9) * 0.30
            case .ripple: motion = sin(t * 2.4 - p * 13) * 0.60
            case .mushroom: motion = t * 2.6 + sin(p * 24 - t * 3.4) * 0.85
            case .still: motion = 0
            }

            let angle = phase + motion
            let breathing = animation == .breathe ? (0.76 + 0.24 * sin(t * 2.4)) : 1.0
            let hallucination = animation == .mushroom
                ? (1 + 0.28 * sin(p * 21 + t * 4) + 0.13 * cos(t * 3 - p * 11))
                : 1.0
            let radius = baseRadius * CGFloat(breathing * hallucination)
            let displacement: CGFloat = animation == .mushroom
                ? CGFloat(sin(p * 11 + t * 1.7)) * size.width * 0.12
                : 0
            let centerX = size.width / 2 + displacement
            let x1 = centerX + radius * CGFloat(sin(angle))
            let x2 = centerX - radius * CGFloat(sin(angle))
            let depth = cos(angle)
            let fade = pow(max(0, sin(p * .pi)), 0.58)

            if showsRungs && index.isMultiple(of: 2) {
                var rung = Path()
                rung.move(to: CGPoint(x: x1, y: y))
                rung.addLine(to: CGPoint(x: x2, y: y))
                context.stroke(rung, with: .color(theme.rungs.opacity(0.14 * fade)), lineWidth: 0.8)
            }

            for strand in 0..<2 {
                let z = strand == 0 ? depth : -depth
                let ink = strand == 0 ? theme.front : theme.back
                let progress = animation == .mushroom
                    ? (p + t * 0.09).truncatingRemainder(dividingBy: 1)
                    : p
                let dot = Dot(
                    point: CGPoint(x: strand == 0 ? x1 : x2, y: y),
                    color: ink.color(at: progress),
                    depth: z,
                    fade: fade
                )
                if z < 0 { backDots.append(dot) } else { frontDots.append(dot) }
            }
        }

        for dot in backDots + frontDots {
            let perspective = (dot.depth + 1) / 2
            let r = theme.particleSize * CGFloat(0.43 + 0.82 * perspective)
            let alpha = dot.fade * (0.18 + 0.82 * perspective)
            let rect = CGRect(x: dot.point.x - r, y: dot.point.y - r,
                              width: r * 2, height: r * 2)
            let path = Path(ellipseIn: rect)

            var glow = context
            glow.addFilter(.shadow(color: dot.color.opacity(alpha * 0.85),
                                   radius: theme.glow * CGFloat(0.4 + perspective)))
            glow.fill(path, with: .color(dot.color.opacity(alpha)))
            context.fill(path, with: .color(dot.color.opacity(alpha)))
        }
    }
}

#Preview("Fixed · Neon") {
    TwistyTrippy(animation: .rotate, sizing: .fixed(width: 160, height: 310))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.015, green: 0.01, blue: 0.06).ignoresSafeArea())
        .preferredColorScheme(.dark)
}

#Preview("Half screen · Mushroom") {
    TwistyTrippy(
        animation: .mushroom,
        sizing: .relative(width: 0.5, height: 0.5),
        theme: .psychedelic,
        speed: 1.3,
        text: "Entering hyperspace…",
        textAnimation: .mushroom,
        textSpeed: 1.4,
        textGradient: [.pink, .yellow, .mint]
    )
    .background(.black)
    .preferredColorScheme(.dark)
}
