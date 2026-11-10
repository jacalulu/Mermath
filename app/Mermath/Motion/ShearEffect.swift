import SwiftUI

/// CSS `skewX(angle)` with a `transform-origin` pivot, for kelp and seagrass.
struct ShearEffect: GeometryEffect {
    var angleDegrees: Double
    var pivot: UnitPoint

    var animatableData: Double {
        get { angleDegrees }
        set { angleDegrees = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let px = pivot.x * size.width
        let py = pivot.y * size.height
        let shear = CGAffineTransform(a: 1, b: 0, c: tan(angleDegrees * .pi / 180), d: 1, tx: 0, ty: 0)
        let transform = CGAffineTransform(translationX: -px, y: -py)
            .concatenating(shear)
            .concatenating(CGAffineTransform(translationX: px, y: py))
        return ProjectionTransform(transform)
    }
}

extension View {
    func skewX(_ degrees: Double, pivot: UnitPoint) -> some View {
        modifier(ShearEffect(angleDegrees: degrees, pivot: pivot))
    }
}
