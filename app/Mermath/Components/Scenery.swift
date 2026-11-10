import SwiftUI

/// The animated light pool near the surface: radial ellipse at 38% 0%,
/// white 0.6 fading out by 68%, with its opacity breathing 0.05 -> 0.45 over 4.5s.
struct LightShimmer: View {
    let t: Double
    var center = UnitPoint(x: 0.38, y: 0)
    var maxOpacity = 0.45

    var body: some View {
        EllipticalGradient(
            stops: [
                .init(color: Color.white.opacity(0.6), location: 0),
                .init(color: Color.white.opacity(0), location: 0.68),
            ],
            center: center,
            startRadiusFraction: 0,
            endRadiusFraction: 0.9
        )
        .opacity(Wave.alternate(t, from: 0.05, to: maxOpacity, duration: 4.5))
        .allowsHitTesting(false)
    }
}

/// A soft Pearl-gold glow that breathes: the map's place glows (.25 -> .8,
/// 1.6s) and the chest and lamp glows (.45 -> 1, 1.8s), per the reference CSS.
struct GlowPulse: View {
    let t: Double
    var color = Color(hex: 0xFFF4DC)
    var fromOpacity = 0.25
    var toOpacity = 0.8
    var duration = 1.6
    var delay: Double = 0

    var body: some View {
        EllipticalGradient(
            stops: [
                .init(color: color.opacity(0.85), location: 0),
                .init(color: color.opacity(0), location: 0.68),
            ],
            center: .center,
            startRadiusFraction: 0,
            endRadiusFraction: 0.5
        )
        .scaleEffect(Wave.alternate(t, from: 0.94, to: 1.05, duration: duration, delay: delay))
        .opacity(Wave.alternate(t, from: fromOpacity, to: toOpacity, duration: duration, delay: delay))
        .allowsHitTesting(false)
    }
}

/// A four-point Pearl star that fades in, turns 45deg and fades out
/// (the treasure chest's twinkles).
struct TwinkleStar: View {
    let t: Double
    let duration: Double
    var delay: Double = 0
    var color = Color(hex: 0xFFF4DC)

    var body: some View {
        let frac = Wave.cycleFraction(t, duration: duration, delay: delay) ?? 0
        // 0% and 100%: opacity 0, scale .4, 0deg; 50%: opacity 1, scale 1, 45deg
        let v = Wave.keyframes(frac, [(0, 0), (0.5, 1), (1, 0)])
        FourPointStar()
            .fill(color)
            .scaleEffect(0.4 + 0.6 * v)
            .rotationEffect(.degrees(45 * v))
            .opacity(v)
            .allowsHitTesting(false)
    }
}

/// Path `M10 0 L12 8 L20 10 L12 12 L10 20 L8 12 L0 10 L8 8 Z` in a unit frame.
struct FourPointStar: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 20, sy = rect.height / 20
        var p = Path()
        p.move(to: CGPoint(x: 10 * sx, y: 0))
        for (x, y) in [(12, 8), (20, 10), (12, 12), (10, 20), (8, 12), (0, 10), (8, 8)] {
            p.addLine(to: CGPoint(x: Double(x) * sx, y: Double(y) * sy))
        }
        p.closeSubpath()
        return p
    }
}

/// Soft dark edges over every scene.
struct Vignette: View {
    var body: some View {
        EllipticalGradient(
            stops: [
                .init(color: Color(hex: 0x020814, opacity: 0), location: 0.55),
                .init(color: Color(hex: 0x020814, opacity: 0.32), location: 1),
            ],
            center: UnitPoint(x: 0.5, y: 0.45),
            startRadiusFraction: 0,
            endRadiusFraction: 0.78
        )
        .allowsHitTesting(false)
    }
}

/// A kelp layer swaying about a bottom pivot: skewX like the CSS, or a plain
/// rotation where the reference uses one (the tide pool's right kelp).
struct KelpLayer: View {
    let t: Double
    let path: String
    let from: Double
    let to: Double
    let duration: Double
    let pivot: UnitPoint
    var delay: Double = 0
    var rotate = false

    var body: some View {
        let angle = Wave.alternate(t, from: from, to: to, duration: duration, delay: delay)
        if rotate {
            ArtImage(path)
                .rotationEffect(.degrees(angle), anchor: pivot)
        } else {
            ArtImage(path)
                .skewX(angle, pivot: pivot)
        }
    }
}

/// One fish swimming left across the stage with a slight bob.
/// Positions are relative to the fish's start frame; the parent places the frame.
struct FishSwim: View {
    let t: Double
    let travel: Double        // total leftward distance (positive)
    let bobDown: Double       // y at 75% (positive = down)
    let bobUp: Double         // y at 25% (positive number, applied upward)
    let duration: Double
    var delay: Double = 0
    /// Design-space multiplier for the offsets (the stage scale).
    let scale: CGFloat

    var body: some View {
        let frac = Wave.cycleFraction(t, duration: duration, delay: delay)
        ArtImage("props/fish.png")
            .opacity(frac == nil ? 0 : 1)
            .offset(
                x: -travel * (frac ?? 0) * scale,
                y: Wave.keyframes(frac ?? 0, [(0, 0), (0.25, -bobUp), (0.5, 0), (0.75, bobDown), (1, 0)]) * scale
            )
    }
}

/// A bubble rising from its start position and fading, on a loop.
struct RisingBubble: View {
    let t: Double
    let duration: Double
    var delay: Double = 0
    /// Design-space multiplier for the offsets (the stage scale).
    let scale: CGFloat

    var body: some View {
        let frac = Wave.cycleFraction(t, duration: duration, delay: delay)
        ArtImage("props/bubble.png")
            .opacity(frac.map { Wave.keyframes($0, [(0, 0), (0.08, 0.9), (0.92, 0.8), (1, 0)]) } ?? 0)
            .offset(
                x: Wave.keyframes(frac ?? 0, [(0, 0), (0.5, 9), (1, -4)]) * scale,
                y: Wave.keyframes(frac ?? 0, [(0, 0), (0.5, -300), (1, -640)]) * scale
            )
    }
}

/// The pink sea star rocks; the orange one hops every 5 seconds.
struct RockingStar: View {
    let t: Double

    var body: some View {
        ArtImage("props/sea-star-pink.png")
            .rotationEffect(.degrees(Wave.alternate(t, from: -10, to: 10, duration: 2.2)))
    }
}

struct HoppingStar: View {
    let t: Double
    let scale: CGFloat

    var body: some View {
        let frac = Wave.cycleFraction(t, duration: 5) ?? 0
        ArtImage("props/sea-star-orange.png")
            .rotationEffect(.degrees(Wave.keyframes(frac, [(0, 0), (0.70, 0), (0.78, -12), (0.86, 5), (0.92, 0), (1, 0)])))
            .offset(y: Wave.keyframes(frac, [(0, 0), (0.70, 0), (0.78, -10), (0.86, 0), (0.92, -4), (1, 0)]) * scale)
    }
}
