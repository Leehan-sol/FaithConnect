//
//  PrayerDetailView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

enum BottomSheetType: Identifiable {
    case create
    case edit(PrayerResponse)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let r): return "edit-\(r.id)"
        }
    }

    var editingResponse: PrayerResponse? {
        switch self {
        case .create: return nil
        case .edit(let r): return r
        }
    }
}

struct PrayerDetailView: View {
    @StateObject private var viewModel: PrayerDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var bottomSheetType: BottomSheetType?
    @State private var showConfirmationDialog = false
    @State private var showPrayerEditor = false
    @State private var showDeleteAlert = false
    
    init(viewModel: @escaping () -> PrayerDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if viewModel.isDeleted, let prayer = viewModel.prayer {
                VStack(spacing: 10) {
                    Image(systemName: "trash.slash")
                        .font(.system(size: 28))
                        .foregroundColor(.gray)
                    Text("삭제된 기도입니다")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("이 기도는 작성자에 의해 삭제되었습니다.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)

                Divider()
                    .padding(.horizontal, 20)

                VStack(spacing: 0) {
                    ForEach(prayer.responses ?? []) { response in
                        PrayerResponseRowView(response: response,
                                              onEdit: { response in
                            bottomSheetType = .edit(response)
                        },
                                              onDelete: { response in
                            Task {
                                await viewModel.deletePrayerResponse(response: response)
                            }
                        })
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                }
            } else if let prayer = viewModel.prayer {
                DetailView(viewModel: viewModel,
                           prayer: prayer,
                           bottomSheetType: $bottomSheetType)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.initializeIfNeeded()
        }
        .customBackButtonStyle {
            if viewModel.prayer?.isMine == true && !viewModel.isDeleted {
                Button {
                    bottomSheetType = nil
                    showConfirmationDialog = true
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.black)
                }
            }
        }
        .sheet(item: $bottomSheetType) { type in
            PrayerDetailBottomSheetView(viewModel: viewModel,
                                        editingResponse: type.editingResponse,
                                        onDismissSheet: { bottomSheetType = nil })
                .presentationDetents([.fraction(0.75)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
        }
        .confirmationDialog(
            "",
            isPresented: $showConfirmationDialog,
            titleVisibility: .hidden
        ) {
            Button("수정") {
                showPrayerEditor = true
            }

            Button("삭제", role: .destructive) {
                showDeleteAlert = true
            }

            Button("취소", role: .cancel) { }
        }
        .navigationDestination(isPresented: $showPrayerEditor) {
            PrayerEditorView(viewModel: { viewModel.makePrayerEditorVM() })
        }
        .onChange(of: showPrayerEditor) { oldValue, newValue in
            if oldValue && !newValue {
                Task {
                    await viewModel.refresh()
                }
            }
        }
        .alert("기도 삭제",
               isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                Task {
                    await viewModel.deletePrayer()
                    dismiss()
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        
        if !viewModel.isDeleted {
            ActionButton(title: "기도 응답하기",
                         foregroundColor: .white,
                         backgroundColor: .customBlue1) {
                bottomSheetType = .create
                showConfirmationDialog = false
            }.padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
        }
    }
    
}

struct DetailView: View {
    @ObservedObject var viewModel: PrayerDetailViewModel
    let prayer: Prayer
    @Binding var bottomSheetType: BottomSheetType?

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
                                      onEdit: { response in
                    bottomSheetType = .edit(response)
                },
                                      onDelete: { response in
                    Task {
                        await viewModel.deletePrayerResponse(response: response)
                    }
                })
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
    }
}


#Preview {
    let mockAPIClient = APIClient(tokenStorage: TokenStorage())
    let mockRepo = PrayerRepository(apiClient: mockAPIClient)
    let mockUseCase = PrayerUseCase(repository: mockRepo)
    
    return PrayerDetailView(viewModel: { PrayerDetailViewModel(prayerUseCase: mockUseCase,
                                                               prayerRequestId: 1) })
}
