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
                    selectedResponse = nil
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
                })
            
            ParticipatedPrayerSectionView(
                responses: viewModel.participatedPrayers,
                onTap: { response in
                    selectedPrayer = nil
                    selectedResponse = response
                    showPrayerDetail = true
                },
                onDelete: { responseID, prayerRequestId in
                    Task {
                        await viewModel.deletePrayerResponse(responseID: responseID, prayerRequestId: prayerRequestId)
                    }
                },
                onMoreTap: {
                    showMyResponseList = true
                }
            )
        }
        .listStyle(.plain)
        .animation(.default, value: viewModel.writtenPrayers.count)
        .animation(.default, value: viewModel.participatedPrayers.count)
        .refreshable {
            await viewModel.refreshWrittenPrayers()
            await viewModel.refreshParticipatedPrayers()
        }
        .navigationTitle("내 기도")
        .navigationDestination(isPresented: $showPrayerDetail) {
            if let prayer = selectedPrayer {
                PrayerDetailView(
                    viewModel: { viewModel.makePrayerDetailVM(prayerRequestId: prayer.id) })
            } else if let response = selectedResponse {
                PrayerDetailView(
                    viewModel: { viewModel.makePrayerDetailVM(prayerRequestId: response.prayerRequestId) })
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
        .alert(item: $viewModel.alertType) { alert in
            Alert(title: Text(alert.title),
                  message: Text(alert.message),
                  dismissButton: .default(Text("확인")))
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
            SectionHeaderView(title: "내가 올린 기도 제목", buttonHidden: false) {
                onMoreTap()
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)

            if prayers.isEmpty {
                PrayerEmptyView(prayerContextType: .prayer)
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                ForEach(prayers.prefix(3), id: \.id) { prayer in
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
                        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20))
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        .listRowSeparator(.hidden)
    }
}

// MARK: - ParticipatedPrayerSectionView
struct ParticipatedPrayerSectionView: View {
    let responses: [MyResponse]
    let onTap: (MyResponse) -> Void
    let onDelete: (Int, Int) -> Void
    let onMoreTap: () -> Void

    var body: some View {
        Section {
            SectionHeaderView(title: "내가 기도한 기도 제목", buttonHidden: false) {
                onMoreTap()
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)

            if responses.isEmpty {
                PrayerEmptyView(prayerContextType: .response)
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                ForEach(responses.prefix(3), id: \.id) { response in
                    MyResponseRowView(response: response)
                        .onTapGesture {
                            onTap(response)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                print("지금 삭제하는 응답: \(response.id)")
                                onDelete(response.id, response.prayerRequestId)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20))
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        .listRowSeparator(.hidden)
    }
}



#Preview {
    let mockAPIClient = APIClient(tokenStorage: TokenStorage())
    let mockRepo = PrayerRepository(apiClient: mockAPIClient)
    let mockUseCase = PrayerUseCase(repository: mockRepo)
    
    return MyPrayerView(viewModel: MyPrayerViewModel(prayerUseCase: mockUseCase))
}
