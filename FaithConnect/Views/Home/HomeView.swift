//
//  HomeView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                List(viewModel.prayers) { prayer in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(prayer.title)
                                .font(.headline)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(prayer.createdAt.toTimeAgoDisplay())
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Text(prayer.content)
                            .font(.subheadline)
                            .foregroundColor(Color(.darkGray))
                            .lineLimit(3)
                        
                        HStack {
                            Image(systemName: "hands.clap")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15, alignment: .trailing)
                            
                            Text("\(prayer.participationCount)명이 기도했습니다.")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    }
                    .padding(15)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white)
                            .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                    .listRowInsets(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))
                    .listRowSeparator(.hidden)
                }
                .listRowBackground(Color.clear)
                .listStyle(PlainListStyle())
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            print("플로팅 버튼 클릭")
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                        }
                        .frame(width: 60, height: 60)
                        .background(.customBlue1.opacity(0.8))
                        .cornerRadius(30)
                        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
                        .padding(.bottom, 20)
                        .padding(.trailing, 20)
                    }
                }
            }
            .navigationTitle("기도 모음")
        }
    }
}

#Preview {
    HomeView()
}
