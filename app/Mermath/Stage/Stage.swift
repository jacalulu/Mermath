import SwiftUI

/// Scale factors for the 800x600 design space on the actual screen.
struct StageMetrics: Equatable {
    /// Fit scale: design points -> screen points, everything guaranteed on screen.
    var scale: CGFloat = 1
    /// Extra scale for scenery so paint reaches the physical edges (cover / fit).
    var bleed: CGFloat = 1
}

private struct StageMetricsKey: EnvironmentKey {
    static let defaultValue = StageMetrics()
}

extension EnvironmentValues {
    var stage: StageMetrics {
        get { self[StageMetricsKey.self] }
        set { self[StageMetricsKey.self] = newValue }
    }
}

/// Wraps a screen: computes the stage scale from the available size, centers the
/// 800x600 stage, and exposes StageMetrics in the environment. Not clipped, so
/// scenery marked .bleed() can reach the physical edges.
struct StageView<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { geo in
            let fit = min(geo.size.width / 800, geo.size.height / 600)
            let cover = max(geo.size.width / 800, geo.size.height / 600)
            ZStack {
                content()
            }
            .frame(width: 800 * fit, height: 600 * fit)
            .environment(\.stage, StageMetrics(scale: fit, bleed: cover / fit))
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .background(Tokens.Palette.midnight)
        .ignoresSafeArea()
    }
}

private struct StagePlacement: ViewModifier {
    @Environment(\.stage) private var m
    let x: CGFloat
    let y: CGFloat
    let w: CGFloat
    let h: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(width: w * m.scale, height: h * m.scale)
            .position(x: (x + w / 2) * m.scale, y: (y + h / 2) * m.scale)
    }
}

private struct StageBleed: ViewModifier {
    @Environment(\.stage) private var m

    func body(content: Content) -> some View {
        content.scaleEffect(m.bleed)
    }
}

extension View {
    /// Place with design-space coordinates, top-left origin, like the reference CSS.
    func stage(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) -> some View {
        modifier(StagePlacement(x: x, y: y, w: w, h: h))
    }

    /// Scenery-only: scale the group up so paint covers the physical screen
    /// (controls stay inside the safe 800x600).
    func bleed() -> some View {
        modifier(StageBleed())
    }
}
