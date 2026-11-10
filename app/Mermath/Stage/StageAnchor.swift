import SwiftUI

/// Anchor an auto-sized view's top-left corner at design-space coordinates
/// (for shrink-wrapped pills and panels whose size the reference leaves to content).
private struct StageTopLeft: ViewModifier {
    @Environment(\.stage) private var m
    let x: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(.leading, x * m.scale)
            .padding(.top, y * m.scale)
            .frame(width: 800 * m.scale, height: 600 * m.scale, alignment: .topLeading)
    }
}

/// Center an auto-sized view horizontally at a design-space top offset.
private struct StageTopCenter: ViewModifier {
    @Environment(\.stage) private var m
    let y: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(.top, y * m.scale)
            .frame(width: 800 * m.scale, height: 600 * m.scale, alignment: .top)
    }
}

/// Center an auto-sized view horizontally at a design-space distance from the bottom.
private struct StageBottomCenter: ViewModifier {
    @Environment(\.stage) private var m
    let bottom: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(.bottom, bottom * m.scale)
            .frame(width: 800 * m.scale, height: 600 * m.scale, alignment: .bottom)
    }
}

/// Anchor an auto-sized view's top-right corner at a design-space distance from the right edge.
private struct StageTopRight: ViewModifier {
    @Environment(\.stage) private var m
    let right: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(.trailing, right * m.scale)
            .padding(.top, y * m.scale)
            .frame(width: 800 * m.scale, height: 600 * m.scale, alignment: .topTrailing)
    }
}

extension View {
    func stageTopLeft(x: CGFloat, y: CGFloat) -> some View {
        modifier(StageTopLeft(x: x, y: y))
    }

    func stageTopCenter(y: CGFloat) -> some View {
        modifier(StageTopCenter(y: y))
    }

    func stageBottomCenter(bottom: CGFloat) -> some View {
        modifier(StageBottomCenter(bottom: bottom))
    }

    func stageTopRight(right: CGFloat, y: CGFloat) -> some View {
        modifier(StageTopRight(right: right, y: y))
    }
}
