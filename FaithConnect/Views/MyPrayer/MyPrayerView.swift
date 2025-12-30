//
//  MyPrayerView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

struct MyPrayerView: View {
    @EnvironmentObject private var session: UserSession
    @ObservedObject var viewModel: MyPrayerViewModel
    @State private var selectedPrayer: Prayer? = nil
    @State private var selectedResponse: MyResponse? = nil
    @State private var showPrayerDetail: Bool = false
    @State private var showMyPrayerList: Bool = false
    @State private var showMyResponseList: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                SectionHeaderView(title: "내가 올린 기도 제목", buttonHidden: false) {
                    showMyPrayerList = true
                }
                
                if viewModel.writtenPrayers.isEmpty {
                    VStack {
                         Spacer(minLength: 30)
                         PrayerEmptyView(prayerContextType: .prayer)
                        Spacer(minLength: 30)
                     }
                } else {
                    ForEach(viewModel.writtenPrayers.prefix(3)) { prayer in
                        PrayerRowView(prayer: prayer,
                                      cellType: .mine)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .onTapGesture {
                                print("Tapped: \(prayer.id), \(prayer.title)")
                                selectedPrayer = prayer
                                showPrayerDetail = true
                            }
                    }
                }
            }.padding(.bottom, 30)
            
            VStack {
                SectionHeaderView(title: "내가 기도한 기도 제목", buttonHidden: false) {
                    showMyResponseList = true
                }
                
                if viewModel.writtenPrayers.isEmpty {
                    VStack {
                        Spacer(minLength: 30)
                        PrayerEmptyView(prayerContextType: .response)
                        Spacer(minLength: 30)
                     }
                } else {
                    ForEach(viewModel.participatedPrayers.prefix(3)) { response in
                        MyResponseRowView(response:response)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .onTapGesture {
                                print("Tapped: \(response.id), \(response.message)")
                                selectedResponse = response
                                showPrayerDetail = true
                            }
                    }
                }
            }
        }
        .navigationTitle("내 기도")
        .navigationDestination(isPresented: $showPrayerDetail) {
            if let prayer = selectedPrayer {
                PrayerDetailView(viewModel: { viewModel.makePrayerDetailVM(prayerRequestId: prayer.id) })
            } else if let response = selectedResponse {
                PrayerDetailView(viewModel: { viewModel.makePrayerDetailVM(prayerRequestId: response.id) })
            }
        }
        .navigationDestination(isPresented: $showMyPrayerList) {
            MyPrayerListView(viewModel: viewModel,
                             prayerContextType: .prayer)
        }
        .navigationDestination(isPresented: $showMyResponseList) {
            MyPrayerListView(viewModel: viewModel,
                             prayerContextType: .response)
        }
        .task {
            await viewModel.initializeIfNeeded()
        }
    }
}

#Preview {
    MyPrayerView(viewModel: MyPrayerViewModel(APIClient()))
        .environmentObject(UserSession())
}
