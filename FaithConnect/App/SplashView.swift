//
//  SplashView.swift
//  FaithConnect
//
//  Created by hansol on 2026/01/11.
//

import SwiftUI

struct SplashView: View {
    let characters = Array("FaithConnect")
    @State private var animatedIndex = -1 // 현재 애니메이션이 적용될 글자 인덱스
    
    var body: some View {
        ZStack {
            Color.customBlue1
                .ignoresSafeArea()
            
            HStack(spacing: 0) {
                ForEach(0..<characters.count, id: \.self) { index in
                    Text(String(characters[index]))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    // 인덱스에 따라 투명도와 위치 조절
                        .opacity(animatedIndex >= index ? 1 : 0.1)
                        .offset(y: animatedIndex >= index ? 0 : 5)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        for i in 0..<characters.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                withAnimation(.easeOut(duration: 0.3)) {
                    animatedIndex = i
                }
            }
        }
        
        let totalTime = Double(characters.count) * 0.1 + 1.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + totalTime) {
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedIndex = -1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                startAnimation()
            }
        }
    }
}
