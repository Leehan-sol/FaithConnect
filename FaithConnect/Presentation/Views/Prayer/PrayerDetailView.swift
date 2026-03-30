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
    @State private var sheetDetent: PresentationDetent = .fraction(0.75)
    @State private var showHeartAnimation = false
    @State private var showReportActionSheet = false
    @State private var showReportDetailAlert = false
    @State private var reportReasonDetail = ""
    @State private var showBlockAlert = false
    @State private var showReportCompleteAlert = false
    @State private var showBlockCompleteAlert = false
    
    init(viewModel: @escaping () -> PrayerDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
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
                                },
                                                      onReport: { response, reasonType, reasonDetail in
                                    await viewModel.reportPrayerResponse(prayerResponseId: response.id, reasonType: reasonType, reasonDetail: reasonDetail)
                                })
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                            }
                        }
                    } else if let prayer = viewModel.prayer {
                        DetailView(viewModel: viewModel,
                                   prayer: prayer,
                                   bottomSheetType: $bottomSheetType)
                        
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
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
                .onChange(of: viewModel.prayer?.responses?.count) { oldValue, newValue in
                    if let oldValue, let newValue, newValue > oldValue {
                        withAnimation {
                            proxy.scrollTo("bottom")
                        }
                    }
                }
                .customBackButtonStyle(onBeforeDismiss: {
                    if bottomSheetType != nil {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            bottomSheetType = nil
                        }
                        return true
                    }
                    return false
                }) {
                    if !viewModel.isDeleted {
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
                    .presentationDetents([.fraction(0.3), .fraction(0.75)], selection: $sheetDetent)
                    .presentationDragIndicator(.visible)
                    .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.3)))
                    .interactiveDismissDisabled(true)
                }
                .confirmationDialog(
                    "",
                    isPresented: $showConfirmationDialog,
                    titleVisibility: .hidden
                ) {
                    if viewModel.prayer?.isMine == true {
                        Button("수정") {
                            showPrayerEditor = true
                        }

                        Button("삭제", role: .destructive) {
                            showDeleteAlert = true
                        }
                    } else {
                        Button("신고", role: .destructive) {
                            showReportActionSheet = true
                        }

                        Button("차단", role: .destructive) {
                            showBlockAlert = true
                        }
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
                            if await viewModel.deletePrayer() {
                                dismiss()
                            }
                        }
                    }
                    Button("취소", role: .cancel) { }
                } message: {
                    Text("이 기도를 정말 삭제하시겠습니까? \n 삭제된 내용은 복구할 수 없습니다.")
                }
                .confirmationDialog("신고 사유를 선택해주세요",
                                    isPresented: $showReportActionSheet,
                                    titleVisibility: .visible) {
                    Button("부적절한 내용") {
                        Task {
                            if await viewModel.reportPrayer(reasonType: .inappropriateContent, reasonDetail: nil) {
                                showReportCompleteAlert = true
                            }
                        }
                    }
                    Button("스팸/광고/중복게시") {
                        Task {
                            if await viewModel.reportPrayer(reasonType: .spam, reasonDetail: nil) {
                                showReportCompleteAlert = true
                            }
                        }
                    }
                    Button("기타") {
                        reportReasonDetail = ""
                        showReportDetailAlert = true
                    }
                    Button("취소", role: .cancel) { }
                }
                .alert("신고 사유 입력", isPresented: $showReportDetailAlert) {
                    TextField("신고 사유를 입력해주세요", text: $reportReasonDetail)
                    Button("신고", role: .destructive) {
                        Task {
                            if await viewModel.reportPrayer(reasonType: .other, reasonDetail: reportReasonDetail) {
                                showReportCompleteAlert = true
                            }
                        }
                    }
                    Button("취소", role: .cancel) { }
                }
                .alert("차단",
                       isPresented: $showBlockAlert) {
                    Button("차단", role: .destructive) {
                        // TODO: 차단 API 연동
                        showBlockCompleteAlert = true
                    }
                    Button("취소", role: .cancel) { }
                } message: {
                    Text("이 사용자를 차단하시겠습니까? \n차단된 사용자의 글은 더 이상 표시되지 않습니다.")
                }
                .alert("신고 완료",
                       isPresented: $showReportCompleteAlert) {
                    Button("확인", role: .cancel) { }
                } message: {
                    Text("신고가 접수되었습니다. \n검토 후 조치하겠습니다.")
                }
                .alert("차단 완료",
                       isPresented: $showBlockCompleteAlert) {
                    Button("확인", role: .cancel) { }
                } message: {
                    Text("해당 사용자가 차단되었습니다.")
                }
                .alert(item: $viewModel.alertType) { alert in
                    Alert(title: Text(alert.title),
                          message: Text(alert.message),
                          dismissButton: .default(Text("확인")))
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarVisibility(.hidden, for: .tabBar)
            } // ScrollViewReader
            
            if !viewModel.isDeleted {
                ActionButton(title: "기도 응답하기",
                             foregroundColor: .white,
                             backgroundColor: .customBlue1) {
                    bottomSheetType = .create
                    showConfirmationDialog = false
                }.padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
            }
        }
        .overlay {
            if showHeartAnimation {
                PrayerHeartAnimationView(participationCount: viewModel.prayer?.participationCount ?? 0) {
                    showHeartAnimation = false
                }
            }
        }
        .onChange(of: viewModel.prayer?.participationCount) { oldValue, newValue in
            if oldValue == nil, let count = newValue, count > 0,
               viewModel.prayer?.isMine == true {
                showHeartAnimation = true
            }
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
                },
                                      onReport: { response, reasonType, reasonDetail in
                    await viewModel.reportPrayerResponse(prayerResponseId: response.id, reasonType: reasonType, reasonDetail: reasonDetail)
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
