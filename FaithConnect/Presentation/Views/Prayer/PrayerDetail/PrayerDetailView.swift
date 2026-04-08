//
//  PrayerDetailView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

// MARK: - PrayerDetailView
struct PrayerDetailView: View {
    @StateObject private var viewModel: PrayerDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var prayerBottomSheetType: PrayerBottomSheetType?
    @State private var showConfirmationDialog = false
    @State private var showPrayerEditor = false
    @State private var confirmAlert: ConfirmAlertType?
    @State private var showReportActionSheet = false
    @State private var showReportDetailAlert = false
    @State private var reportReasonDetail = ""

    @FocusState private var isReplyFocused: Bool
    @State private var sheetDetent: PresentationDetent = .fraction(0.75)
    @State private var showHeartAnimation = false
    
    init(viewModel: @escaping () -> PrayerDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.prayer == nil {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
                Spacer()
            } else {
                scrollContent
            }

            if !viewModel.isDeleted, viewModel.prayer != nil, viewModel.replyingTo == nil {
                ActionButton(title: "기도 응답하기",
                             foregroundColor: .white,
                             backgroundColor: .customBlue1) {
                    prayerBottomSheetType = .create
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
        .task {
            await viewModel.initializeIfNeeded()
        }
    }

    // MARK: - ScrollContent
    private var scrollContent: some View {
        ScrollViewReader { proxy in
        ScrollView(.vertical, showsIndicators: false) {
            if let prayer = viewModel.prayer {
                if viewModel.isDeleted {
                    DeletedHeaderView(participationCount: prayer.participationCount)
                } else {
                    DetailHeaderView(prayer: prayer)
                }

                CommentListView(viewModel: viewModel,
                                 prayerBottomSheetType: $prayerBottomSheetType,
                                 isReplyFocused: $isReplyFocused,
                                 proxy: proxy)

                Color.clear
                    .frame(height: 1)
                    .id("bottom")
            }
        }
        .onTapGesture {
            isReplyFocused = false
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onChange(of: viewModel.prayer?.responses?.count) { oldValue, newValue in
            if let oldValue, let newValue, newValue > oldValue {
                withAnimation {
                    proxy.scrollTo("bottom")
                }
            }
        }
        .customBackButtonStyle(onBeforeDismiss: {
            if prayerBottomSheetType != nil {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    prayerBottomSheetType = nil
                }
                return true
            }
            return false
        }) {
            if !viewModel.isDeleted {
                Button {
                    prayerBottomSheetType = nil
                    showConfirmationDialog = true
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.black)
                }
            }
        }
        .sheet(item: $prayerBottomSheetType) { type in
            PrayerDetailBottomSheetView(viewModel: viewModel,
                                        editingResponse: type.editingResponse,
                                        onDismissSheet: { prayerBottomSheetType = nil })
            .presentationDetents([.fraction(0.3), .fraction(0.75)], selection: $sheetDetent)
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.3)))
            .interactiveDismissDisabled(true)
        }
        .confirmationDialog("", isPresented: $showConfirmationDialog, titleVisibility: .hidden) {
            if viewModel.prayer?.isMine == true {
                Button("수정") { showPrayerEditor = true }
                Button("삭제", role: .destructive) { confirmAlert = .delete(target: "기도") }
            } else {
                Button("신고", role: .destructive) { showReportActionSheet = true }
                Button("차단", role: .destructive) { confirmAlert = .block }
            }
            Button("취소", role: .cancel) { }
        }
        .navigationDestination(isPresented: $showPrayerEditor) {
            PrayerEditorView(viewModel: { viewModel.makePrayerEditorVM() })
        }
        .onChange(of: showPrayerEditor) { oldValue, newValue in
            if oldValue && !newValue {
                Task { await viewModel.refresh() }
            }
        }
        .alert(confirmAlert?.title ?? "",
               isPresented: Binding(get: { confirmAlert != nil },
                                    set: { if !$0 { confirmAlert = nil } }),
               presenting: confirmAlert) { type in
            Button("확인", role: .destructive) {
                switch type {
                case .delete(_):
                    Task {
                        if await viewModel.deletePrayer() { dismiss() }
                    }
                case .report(_):
                    break
                case .block:
                    Task {
                        if let userId = viewModel.prayer?.userId {
                            if await viewModel.blockPrayerUser(userId: userId) {
                                dismiss()
                            }
                        }
                    }
                }
            }
            Button("취소", role: .cancel) { }
        } message: { type in
            Text(type.message)
        }
        .confirmationDialog("신고 사유를 선택해주세요",
                            isPresented: $showReportActionSheet,
                            titleVisibility: .visible) {
            Button("부적절한 내용") {
                Task { await viewModel.reportPrayer(reasonType: .inappropriateContent, reasonDetail: nil) }
            }
            Button("스팸/광고/중복게시") {
                Task { await viewModel.reportPrayer(reasonType: .spam, reasonDetail: nil) }
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
                Task { await viewModel.reportPrayer(reasonType: .other, reasonDetail: reportReasonDetail) }
            }
            Button("취소", role: .cancel) { }
        }
        .alert(item: $viewModel.alertType) { alert in
            Alert(title: Text(alert.title),
                  message: Text(alert.message),
                  dismissButton: .default(Text("확인")))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
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
