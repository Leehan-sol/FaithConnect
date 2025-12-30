//
//  PrayerListView.swift
//  FaithConnect
//
//  Created by Apple on 12/30/25.
//

import SwiftUI

struct MyPrayerListView: View {
    @ObservedObject var viewModel: MyPrayerViewModel
    @State private var selectedPrayer: Prayer? = nil
    @State private var selectedResponse: MyResponse? = nil
    @State private var showPrayerDetail: Bool = false
    
    let prayerContextType: PrayerContextType
    
    var body: some View {
        VStack {
            if prayerContextType == .prayer {
                List {
                    ForEach(viewModel.writtenPrayers) { prayer in
                        PrayerRowView(prayer: prayer,
                                      cellType: .others)
                        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .onTapGesture {
                            print("Tapped: \(prayer.id), \(prayer.title)")
                            selectedPrayer = prayer
                            showPrayerDetail = true
                        }
                    }
                }
                .refreshable {
                    await viewModel.refreshWrittenPrayers()
                }
                .listStyle(PlainListStyle())
                .scrollIndicators(.hidden)
            }
            
            if prayerContextType == .response {
                List {
                    ForEach(viewModel.participatedPrayers) { response in
                        MyResponseRowView(response:response)
                            .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .onTapGesture {
                                print("Tapped: \(response.id), \(response.message)")
                                selectedResponse = response
                                showPrayerDetail = true
                            }
                    }
                }
                .refreshable {
                    await viewModel.refreshParticipatedPrayers()
                }
                .listStyle(PlainListStyle())
                .scrollIndicators(.hidden)
            }
        }
        .navigationTitle(prayerContextType.navigationTitle)
        .customBackButtonStyle()
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $showPrayerDetail) {
            if let prayer = selectedPrayer {
                PrayerDetailView(viewModel: { viewModel.makePrayerDetailVM(prayerRequestId: prayer.id) })
            } else if let response = selectedResponse {
                PrayerDetailView(viewModel: { viewModel.makePrayerDetailVM(prayerRequestId: response.id) })
            }
        }
    }
    
}

#Preview {
    MyPrayerListView(viewModel: MyPrayerViewModel(APIClient()),
                     prayerContextType: .response)
}
