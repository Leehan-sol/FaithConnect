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
            PreviewSection(
                title: "내가 올린 기도 제목",
                items: viewModel.writtenPrayers,
                rowView: { prayer in
                    PrayerRowView(prayer: prayer, cellType: .mine)
                },
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
                })
            
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
            )
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
                    viewModel: { viewModel.makePrayerDetailVM(prayerRequestId: prayer.id) })
            } else if let response = selectedResponse {
                PrayerDetailView(
                    viewModel: { viewModel.makePrayerDetailVM(prayerRequestId: response.id) })
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
                ForEach(responses.prefix(3), id: \.id) { response in
                    MyResponseRowView(response: response)
                        .onTapGesture {
                            onTap(response)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                print("지금 삭제하는 응답: \(response.id)")
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



struct PreviewSection<Item: Identifiable, RowView: View>: View {
    let title: String
    let items: [Item]
    let rowView: (Item) -> RowView
    let onTap: (Item) -> Void
    let onDelete: (Item.ID) -> Void
    let onMoreTap: () -> Void
    let maxPreviewCount: Int = 3
    let rowHeight: CGFloat = 72

    var body: some View {
        Section(header:
            SectionHeaderView(title: title, buttonHidden: false) {
                onMoreTap()
            }
        ) {
            // 아이템이 없으면 placeholder row
            if items.isEmpty {
                ForEach(0..<maxPreviewCount, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: rowHeight)
                        .listRowSeparator(.hidden)
                }
            } else {
                // 실제 아이템 row
                ForEach(Array(items.prefix(maxPreviewCount)), id: \.id) { item in
                    rowView(item)
                        .onTapGesture { onTap(item) }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                onDelete(item.id)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                        .frame(height: rowHeight)
                }
                
                // 아이템이 maxPreviewCount보다 적으면 남은 칸을 placeholder로 채움
                if items.count < maxPreviewCount {
                    ForEach(0..<(maxPreviewCount - items.count), id: \.self) { _ in
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: rowHeight)
                            .listRowSeparator(.hidden)
                    }
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .listRowSeparator(.hidden)
    }
}



#Preview {
    let mockAPIClient = APIClient(tokenStorage: TokenStorage())
    let mockRepo = PrayerRepository(apiClient: mockAPIClient)
    let mockUseCase = PrayerUseCase(repository: mockRepo)
    
    return MyPrayerView(viewModel: MyPrayerViewModel(prayerUseCase: mockUseCase))
}
