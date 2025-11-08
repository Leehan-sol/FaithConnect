//
//  SectionHeaderView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            
            Button(action: action) {
                Image(systemName: "chevron.forward")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .foregroundColor(Color(.darkGray))
    }
}

#Preview {
    SectionHeaderView(title: "타이틀") {
        
    }
}
