//
//  CategoryScrollView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/09.
//

import SwiftUI

struct CategoryButtonView: View {
    let category: PrayerCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(category.categoryName)
            .frame(width: 60, height: 40)
            .foregroundColor(isSelected ? .white : Color(.darkGray))
            .bold()
            .background(isSelected ? .customBlue1 : Color(.systemGray6))
            .cornerRadius(25)
            .onTapGesture(perform: action)
    }
}
