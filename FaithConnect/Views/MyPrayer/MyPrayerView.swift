//
//  MyPrayerView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

struct MyPrayerView: View {
    @StateObject var viewModel = MyPrayerViewModel()
    @State private var selectedPrayer: Prayer? = nil
    @State private var showPrayerDetail: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        SectionHeaderView(title: "내가 올린 기도 제목") {
                            
                        }
                        
                        ForEach(viewModel.prayers.prefix(3)) { prayer in
                            PrayerRowView(prayer: prayer, cellType: .mine)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .onTapGesture {
                                    print("Tapped: \(prayer.id), \(prayer.title)")
                                    showPrayerDetail = true
                                }
                        }
                    }.padding(.bottom, 30)
                    
                    VStack {
                        SectionHeaderView(title: "내가 기도한 기도 제목") {
                            
                        }
                        
                        ForEach(viewModel.prayers.prefix(3)) { prayer in
                            PrayerRowView(prayer: prayer, cellType: .participated)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .onTapGesture {
                                    print("Tapped: \(prayer.id), \(prayer.title)")
                                    selectedPrayer = prayer
                                    showPrayerDetail = true
                                }
                        }
                    }
                }
            }
            .navigationTitle("내 기도")
            .navigationDestination(isPresented: $showPrayerDetail) {
                if let prayer = selectedPrayer {
                    PrayerDetailView(viewModel: PrayerDetailViewModel(prayer: prayer))
                }
            }
        }
    }
}

#Preview {
    MyPrayerView()
}
