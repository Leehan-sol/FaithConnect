//
//  PrayerHeartAnimationView.swift
//  FaithConnect
//
//  Created by Claude on 2026/03/21.
//

import SwiftUI

struct FloatingHeart: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let duration: Double
    let delay: Double
    let color: Color
}

struct PrayerHeartAnimationView: View {
    let participationCount: Int
    let onFinished: () -> Void

    @State private var showText = false
    @State private var fadeOut = false

    private static let heartColors: [Color] = [
        .customBlue1, .customBlue1.opacity(0.7), .customNavy.opacity(0.5), .blue.opacity(0.6)
    ]

    private let hearts: [FloatingHeart] = (0..<12).map { i in
        FloatingHeart(
            x: CGFloat.random(in: 0.1...0.9),
            y: CGFloat.random(in: 0.15...0.85),
            size: CGFloat.random(in: 12...22),
            duration: Double.random(in: 1.2...1.8),
            delay: Double(i) * 0.08 + Double.random(in: 0...0.04),
            color: heartColors.randomElement() ?? .pink
        )
    }

    var body: some View {
        ZStack {
            ForEach(hearts) { heart in
                HeartParticleView(heart: heart)
                    .opacity(fadeOut ? 0 : 1)
            }

            if showText {
                VStack(spacing: 12) {
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color(.darkGray))

                    Text("\(participationCount)명이 기도했어요")
                        .bold()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                .opacity(fadeOut ? 0 : 1)
            }
        }
        .allowsHitTesting(false)
        .task {
            try? await Task.sleep(for: .seconds(0.5))
            withAnimation(.easeIn(duration: 0.3)) {
                showText = true
            }

            try? await Task.sleep(for: .seconds(0.7))
            withAnimation(.easeOut(duration: 0.3)) {
                fadeOut = true
            }

            try? await Task.sleep(for: .seconds(0.3))
            onFinished()
        }
    }
}

private struct HeartParticleView: View {
    let heart: FloatingHeart

    @State private var visible = false
    @State private var gone = false

    var body: some View {
        GeometryReader { geo in
            Image(systemName: "heart.fill")
                .font(.system(size: heart.size))
                .foregroundColor(heart.color)
                .scaleEffect(visible ? 1.0 : 0.0)
                .opacity(gone ? 0 : 1)
                .position(
                    x: geo.size.width * heart.x,
                    y: geo.size.height * heart.y
                )
                .onAppear {
                    withAnimation(
                        .spring(duration: 0.4, bounce: 0.3)
                        .delay(heart.delay)
                    ) {
                        visible = true
                    }

                    withAnimation(
                        .easeOut(duration: 0.4)
                        .delay(heart.delay + heart.duration)
                    ) {
                        gone = true
                    }
                }
        }
    }
}

#Preview {
    ZStack {
        Color.white
        PrayerHeartAnimationView(participationCount: 35, onFinished: {})
    }
}
