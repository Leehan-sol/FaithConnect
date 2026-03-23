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
    @State private var showDeleteAlert = false
    @State private var showReportAlert = false
    @State private var showBlockAlert = false
    @State private var replyingTo: PrayerResponse?
    @State private var editingReply: PrayerResponse?
    @State private var replyText: String = ""
    
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

            if !viewModel.isDeleted, viewModel.prayer != nil, replyingTo == nil {
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

                ResponseListView(viewModel: viewModel,
                                 prayerBottomSheetType: $prayerBottomSheetType,
                                 replyingTo: $replyingTo,
                                 editingReply: $editingReply,
                                 replyText: $replyText,
                                 responses: prayer.responses ?? [],
                                 isReplyFocused: $isReplyFocused,
                                 proxy: proxy)

                Color.clear
                    .frame(height: 1)
                    .id("bottom")
            }
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
            prayerMenuButtons
        }
        .navigationDestination(isPresented: $showPrayerEditor) {
            PrayerEditorView(viewModel: { viewModel.makePrayerEditorVM() })
        }
        .onChange(of: showPrayerEditor) { oldValue, newValue in
            if oldValue && !newValue {
                Task { await viewModel.refresh() }
            }
        }
        .alert("기도 삭제", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                Task {
                    if await viewModel.deletePrayer() { dismiss() }
                }
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("이 기도를 정말 삭제하시겠습니까? \n 삭제된 내용은 복구할 수 없습니다.")
        }
        .alert("신고", isPresented: $showReportAlert) {
            Button("신고", role: .destructive) { viewModel.reportWriter() }
            Button("취소", role: .cancel) { }
        } message: {
            Text("이 기도를 신고하시겠습니까?")
        }
        .alert("차단", isPresented: $showBlockAlert) {
            Button("차단", role: .destructive) { viewModel.blockWriter() }
            Button("취소", role: .cancel) { }
        } message: {
            Text("이 사용자를 차단하시겠습니까? \n차단된 사용자의 글은 더 이상 표시되지 않습니다.")
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

    @ViewBuilder
    private var prayerMenuButtons: some View {
        if viewModel.prayer?.isMine == true {
            Button("수정") { showPrayerEditor = true }
            Button("삭제", role: .destructive) { showDeleteAlert = true }
        } else {
            Button("신고", role: .destructive) { showReportAlert = true }
            Button("차단", role: .destructive) { showBlockAlert = true }
        }
        Button("취소", role: .cancel) { }
    }
}


// MARK: - DetailHeaderView
struct DetailHeaderView: View {
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
            
            Text("\(prayer.participationCount)명이 기도했어요")
                .font(.headline)
                .foregroundColor(Color(.darkGray))
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
    }
}


// MARK: - DeletedHeaderView
struct DeletedHeaderView: View {
    let participationCount: Int

    var body: some View {
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

        Text("\(participationCount)명이 기도했어요")
            .font(.headline)
            .foregroundColor(Color(.darkGray))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
    }
}


// MARK: - ResponseListView
struct ResponseListView: View {
    @ObservedObject var viewModel: PrayerDetailViewModel
    @Binding var prayerBottomSheetType: PrayerBottomSheetType?
    @Binding var replyingTo: PrayerResponse?
    @Binding var editingReply: PrayerResponse?
    @Binding var replyText: String
    let responses: [PrayerResponse]
    var isReplyFocused: FocusState<Bool>.Binding
    var proxy: ScrollViewProxy?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(responses) { response in
                VStack(spacing: 0) {
                    PrayerResponseRowView(response: response,
                                          onEdit: { response in
                        prayerBottomSheetType = .edit(response)
                    },
                                          onDelete: { response in
                        Task {
                            await viewModel.deletePrayerResponse(response: response)
                        }
                    },
                                          onReport: { _ in
                        viewModel.reportWriter()
                    },
                                          onBlock: { _ in
                        viewModel.blockWriter()
                    },
                                          onReply: { response in
                        replyingTo = response
                        isReplyFocused.wrappedValue = true
                    })
                    .padding(EdgeInsets(top: 10,
                                        leading: 20,
                                        bottom: 10,
                                        trailing: 20))

                    if !response.replies.isEmpty {
                        VStack(spacing: 6) {
                            ForEach(response.replies) { reply in
                                if editingReply?.id == reply.id {
                                    // 수정 모드: 해당 대댓글을 입력바로 대체
                                    ReplyInputBar(
                                        replyText: $replyText,
                                        isReplyFocused: isReplyFocused,
                                        isEditing: true,
                                        onSend: {
                                            let message = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
                                            guard !message.isEmpty else { return }
                                            viewModel.updateMockReply(reply, in: response, message: message)
                                            let editedId = reply.id
                                            replyText = ""
                                            replyingTo = nil
                                            editingReply = nil
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                withAnimation {
                                                    proxy?.scrollTo(editedId, anchor: .bottom)
                                                }
                                            }
                                        },
                                        onCancel: {
                                            replyText = ""
                                            replyingTo = nil
                                            editingReply = nil
                                        }
                                    )
                                } else {
                                    ReplyRowView(reply: reply,
                                                 onEdit: { reply in
                                        editingReply = reply
                                        replyingTo = response
                                        replyText = reply.message
                                        isReplyFocused.wrappedValue = true
                                    },
                                                 onDelete: { reply in

                                    },
                                                 onReport: { _ in
                                        viewModel.reportWriter()
                                    },
                                                 onBlock: { _ in
                                        viewModel.blockWriter()
                                    })
                                    .id(reply.id)
                                }
                            }
                        }
                        .padding(EdgeInsets(top: 0,
                                            leading: 40,
                                            bottom: 10,
                                            trailing: 20))
                    }

                    // 새 답글 작성 (수정 모드가 아닐 때만)
                    if replyingTo?.id == response.id, editingReply == nil {
                        ReplyInputBar(
                            replyText: $replyText,
                            isReplyFocused: isReplyFocused,
                            onSend: {
                                let message = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !message.isEmpty else { return }
                                viewModel.addMockReply(to: response, message: message)
                                let lastReplyId = viewModel.prayer?.responses?
                                    .first(where: { $0.id == response.id })?.replies.last?.id
                                replyText = ""
                                replyingTo = nil
                                if let lastReplyId {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation {
                                            proxy?.scrollTo(lastReplyId, anchor: .bottom)
                                        }
                                    }
                                }
                            },
                            onCancel: {
                                replyText = ""
                                replyingTo = nil
                            }
                        )
                        .padding(EdgeInsets(top: 0,
                                            leading: 40,
                                            bottom: 10,
                                            trailing: 20))
                    }
                }
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
