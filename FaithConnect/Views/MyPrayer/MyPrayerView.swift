//
//  MyPrayerView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

struct MyPrayerView: View {
    @ObservedObject var viewModel: MyPrayerViewModel
    @State private var selectedPrayer: Prayer? = nil
    @State private var selectedResponse: MyResponse? = nil
    @State private var showPrayerDetail: Bool = false
    @State private var showMyPrayerList: Bool = false
    @State private var showMyResponseList: Bool = false
    
    var body: some View {
        List {
            WrittenPrayerSectionView(
                prayers: viewModel.writtenPrayers,
                onTap: { prayer in
                    selectedPrayer = prayer
                    showPrayerDetail = true
                },
                onDelete: { prayerID in
                    Task {
                        await viewModel.deletePrayer(prayerID: prayerID)
                    }
                },
                onMoreTap: {
                    showMyPrayerList = true
                }
            ).frame(minHeight: 30)
            
            ParticipatedPrayerSectionView(
                responses: viewModel.participatedPrayers,
                onTap: { response in
                    selectedResponse = response
                    showPrayerDetail = true
                },
                onDelete: { responseID in
                    Task {
                        await viewModel.deletePrayerResponse(responseID: responseID)
                    }
                },
                onMoreTap: {
                    showMyResponseList = true
                }
            ).frame(minHeight: 30)
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refreshWrittenPrayers()
            await viewModel.refreshParticipatedPrayers()
        }
        .navigationTitle("내 기도")
        .navigationDestination(isPresented: $showPrayerDetail) {
            if let prayer = selectedPrayer {
                PrayerDetailView(
                    viewModel: { viewModel.makePrayerDetailVM(prayerRequestId: prayer.id) },
                    onDeletePrayer: { _ in }
                )
            } else if let response = selectedResponse {
                PrayerDetailView(
                    viewModel: { viewModel.makePrayerDetailVM(prayerRequestId: response.id) },
                    onDeletePrayer: { _ in }
                )
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
        .onAppear {
            Task {
                await viewModel.initializeIfNeeded()
            }
        }
    }
}

// MARK: - WrittenPrayerSectionView
struct WrittenPrayerSectionView: View {
    let prayers: [Prayer]
    let onTap: (Prayer) -> Void
    let onDelete: (Int) -> Void
    let onMoreTap: () -> Void
    
    var body: some View {
        Section {
            if prayers.isEmpty {
                PrayerEmptyView(prayerContextType: .prayer)
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                ForEach(prayers.prefix(3)) { prayer in
                    PrayerRowView(prayer: prayer, cellType: .mine)
                        .onTapGesture {
                            onTap(prayer)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                onDelete(prayer.id)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                }
            }
        } header: {
            SectionHeaderView(title: "내가 올린 기도 제목", buttonHidden: false) {
                onMoreTap()
            }.padding(.top, -20)
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .listRowSeparator(.hidden)
    }
}

// MARK: - ParticipatedPrayerSectionView
struct ParticipatedPrayerSectionView: View {
    let responses: [MyResponse]
    let onTap: (MyResponse) -> Void
    let onDelete: (Int) -> Void
    let onMoreTap: () -> Void
    
    var body: some View {
        Section {
            if responses.isEmpty {
                PrayerEmptyView(prayerContextType: .response)
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                ForEach(responses.prefix(3)) { response in
                    MyResponseRowView(response: response)
                        .onTapGesture {
                            onTap(response)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                onDelete(response.id)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                }
            }
        } header: {
            SectionHeaderView(title: "내가 기도한 기도 제목", buttonHidden: false) {
                onMoreTap()
            }
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .listRowSeparator(.hidden)
    }
}

#Preview {
    MyPrayerView(viewModel: MyPrayerViewModel(APIClient(tokenStorage: TokenStorage())))
}
