import Foundation

/// Pure time -> value functions reproducing the reference CSS animations.
/// All take the scene clock `t` in seconds. CSS negative animation-delay is a
/// phase: pass `delay` with the CSS sign (e.g. CSS `-1.2s` -> `delay: -1.2`).
enum Wave {

    /// CSS `infinite alternate` with ease-in-out: ping-pongs from -> to -> from.
    /// `duration` is one leg, like CSS animation-duration.
    static func alternate(_ t: Double, from: Double, to: Double, duration: Double, delay: Double = 0) -> Double {
        let p = (t - delay) / duration
        let cycle = p - floor(p / 2) * 2          // [0, 2)
        let leg = cycle < 1 ? cycle : 2 - cycle   // 0 -> 1 -> 0
        let eased = 0.5 - 0.5 * cos(.pi * leg)    // ease-in-out per leg
        return from + (to - from) * eased
    }

    /// CSS keyframes `0%: from, 50%: to, 100%: from` ease-in-out infinite
    /// (the bob/float pattern). Same shape as alternate with half the duration.
    static func bob(_ t: Double, from: Double, to: Double, duration: Double, delay: Double = 0) -> Double {
        alternate(t, from: from, to: to, duration: duration / 2, delay: delay)
    }

    /// Fraction [0,1) through a linear infinite cycle; nil before a positive delay
    /// has elapsed (CSS holds the element un-animated until then).
    static func cycleFraction(_ t: Double, duration: Double, delay: Double = 0) -> Double? {
        let elapsed = t - delay
        if elapsed < 0 { return nil }
        let p = elapsed / duration
        return p - floor(p)
    }

    /// Piecewise-linear keyframe track: points are (fraction 0...1, value), sorted.
    static func keyframes(_ fraction: Double, _ points: [(Double, Double)]) -> Double {
        guard let first = points.first else { return 0 }
        if fraction <= first.0 { return first.1 }
        for i in 1..<points.count {
            let (f1, v1) = points[i]
            if fraction <= f1 {
                let (f0, v0) = points[i - 1]
                let span = f1 - f0
                let local = span > 0 ? (fraction - f0) / span : 1
                return v0 + (v1 - v0) * local
            }
        }
        return points[points.count - 1].1
    }

    /// Blink: 1 while the eyes-shut layer shows. The CSS swaps opacity between
    /// 94% and 98% of the cycle, with short ramps on either side.
    static func blink(_ t: Double, cycle: Double, delay: Double = 0) -> Double {
        let p = (t - delay) / cycle
        let frac = p - floor(p)
        return keyframes(frac, [(0.92, 0), (0.94, 1), (0.98, 1), (1.0, 0)])
    }
}
