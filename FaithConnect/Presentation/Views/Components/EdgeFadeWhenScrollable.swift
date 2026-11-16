//
//  EdgeFadeWhenScrollable.swift
//  FaithConnect
//

import SwiftUI

// 칩이 화면에 딱 맞게 끝나면 더 있다는 걸 모르므로, 넘칠 때만 가려진 쪽 끝을 흐리게 한다.
struct EdgeFadeWhenScrollable: ViewModifier {
    @State private var fadeLeading = false
    @State private var fadeTrailing = false
    private let fadeWidth: CGFloat = 32

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: [Bool].self) { geometry in
                let visible = geometry.visibleRect
                return [visible.minX > 1, visible.maxX < geometry.contentSize.width - 1]
            } action: { _, edges in
                fadeLeading = edges[0]
                fadeTrailing = edges[1]
            }
            .mask {
                HStack(spacing: 0) {
                    LinearGradient(colors: [fadeLeading ? .clear : .black, .black],
                                   startPoint: .leading, endPoint: .trailing)
                        .frame(width: fadeWidth)
                    Rectangle()
                    LinearGradient(colors: [.black, fadeTrailing ? .clear : .black],
                                   startPoint: .leading, endPoint: .trailing)
                        .frame(width: fadeWidth)
                }
            }
    }
}

extension View {
    func edgeFadeWhenScrollable() -> some View { modifier(EdgeFadeWhenScrollable()) }
}
