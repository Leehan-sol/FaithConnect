//
//  PrayerDetailView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

struct PrayerDetailView: View {
    @EnvironmentObject private var session: UserSession
    @StateObject private var viewModel: PrayerDetailViewModel
    @State private var showBottomSheet = false
    @State private var showConfirmationDialog = false
    @State private var showPrayerEditor = false
    @State private var showDeleteAlert = false
    
    init(viewModel: @escaping () -> PrayerDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if let prayer = viewModel.prayer {
                DetailView(viewModel: viewModel,
                           prayer: prayer)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            }
        }
        .task {
            await viewModel.initializeIfNeeded()
        }
        .customBackButtonStyle {
            if viewModel.prayer?.userId == session.user?.id {
                Button {
                    showBottomSheet = false
                    showConfirmationDialog = true
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.black)
                }
            }
        }
        .sheet(isPresented: $showBottomSheet) {
            PrayerDetailBottomSheetView(viewModel: viewModel)
                .presentationDetents([.fraction(0.75)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
        }
        .confirmationDialog(
            "",
            isPresented: $showConfirmationDialog,
            titleVisibility: .hidden
        ) {
//            Button("수정") {
//                showPrayerEditor = true
//            }
            
            Button("삭제", role: .destructive) {
                showDeleteAlert = true
            }
            
            Button("취소", role: .cancel) { }
        }
        .alert("기도 삭제",
               isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                Task {
                    await viewModel.deletePrayer()
                }
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("이 기도를 정말 삭제하시겠습니까? \n 삭제된 내용은 복구할 수 없습니다.")
        }
        .alert(item: $viewModel.alertType) { alert in
            Alert(title: Text(alert.title),
                  message: Text(alert.message),
                  dismissButton: .default(Text("확인")))
        }
        .toolbar(.hidden, for: .tabBar)
        
        ActionButton(title: "기도 응답하기",
                     foregroundColor: .white,
                     backgroundColor: .customBlue1) {
            showBottomSheet = true
            showConfirmationDialog = false
        }.padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
    }
    
}

struct DetailView: View {
    @ObservedObject var viewModel: PrayerDetailViewModel
    let prayer: Prayer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack {
                Text(prayer.categoryName)
                    .frame(width: 40, height: 30)
                    .foregroundColor(.customNavy)
                    .background(.customBlue1.opacity(0.2))
                    .bold()
                    .font(.caption)
                    .cornerRadius(10)
                
                Text(prayer.createdAt.toTimeAgoDisplay())
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            
            Text(prayer.title)
                .font(.title2)
            
            Text(prayer.content)
            
            Divider()
            
            Text("\(prayer.participationCount)명이 기도했습니다.")
                .font(.headline)
                .foregroundColor(Color(.darkGray))
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
        
        VStack(spacing: 0) {
            ForEach(prayer.responses ?? []) { response in
                PrayerResponseRowView(response: response, 
                                      onDelete: { response in
                    Task {
                        await self.viewModel.deletePrayerResponse(response: response)
                    }
                })
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
        }
    }
}


#Preview {
    PrayerDetailView(viewModel: { PrayerDetailViewModel(APIService(),
                                                        prayerRequestId: 1) })
    .environmentObject(UserSession())
}
