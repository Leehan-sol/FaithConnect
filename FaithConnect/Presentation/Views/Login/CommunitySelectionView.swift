//
//  CommunitySelectionView.swift
//  FaithConnect
//

import SwiftUI

struct CommunitySelectionView: View {
    let church: Church
    @State private var selected: Community?
    @State private var goForm = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("소속 공동체를 선택해주세요")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("\(church.name) · \(church.roadAddress)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 12)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(Community.allCases) { community in
                    Button {
                        selected = community
                        goForm = true
                    } label: {
                        VStack(spacing: 8) {
                            Text(community.emoji)
                                .font(.system(size: 36))
                            Text(community.displayName)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                    .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .navigationTitle("공동체 선택")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButtonStyle()
        .navigationDestination(isPresented: $goForm) {
            if let selected = selected {
                SignUpFormView(church: church, community: selected)
            }
        }
    }
}
