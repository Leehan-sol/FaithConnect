//
//  MyPageView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct MyPageView: View {
    @StateObject var viewModel = MyPageViewModel()
    @State private var showPrayerDetail: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    VStack {
                        HStack {
                            Text("내가 올린 기도제목")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                                .font(.headline)
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "chevron.forward")
                            }
                            
                        }
                        .padding(EdgeInsets(top: 10, leading: 25, bottom: 0, trailing: 25))
                        .foregroundColor(Color(.darkGray))
                        
                        List(viewModel.prayers) { prayer in
                            PrayerRowView(prayer: prayer, cellType: .mine)
                                .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .onTapGesture {
                                    print("Tapped: \(prayer.id), \(prayer.title)")
                                }
                        }
                        .listStyle(PlainListStyle())
                    }.padding(.bottom, 30)
                    
                    VStack {
                        HStack {
                            Text("내가 기도한 기도제목")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                                .font(.headline)
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "chevron.forward")
                            }
                        }
                        .padding(EdgeInsets(top: 10, leading: 25, bottom: 0, trailing: 25))
                        .foregroundColor(Color(.darkGray))
                        
                        List(viewModel.prayers) { prayer in
                            PrayerRowView(prayer: prayer, cellType: .participated)
                                .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .onTapGesture {
                                    print("Tapped: \(prayer.id), \(prayer.title)")
                                }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationTitle("내 기도")
            .navigationDestination(isPresented: $showPrayerDetail) {
                PrayerDetailView()
            }
        }
    }
}

#Preview {
    MyPageView()
}
