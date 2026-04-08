//
//  CommentRowView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/09.
//

import SwiftUI

struct CommentRowView: View {
    @State private var showConfirmationDialog = false
    @State private var confirmAlert: ConfirmAlertType?
    @State private var resultAlert: AlertType?
    @State private var showReportActionSheet = false
    @State private var showReportDetailAlert = false
    @State private var reportReasonDetail = ""

    let response: PrayerResponse
    let onEdit: ((PrayerResponse) -> Void)?
    let onDelete: ((PrayerResponse) -> Void)?
    var onReport: ((PrayerResponse, ReportReasonType, String?) async -> Bool)? = nil
    let onBlock: ((PrayerResponse) -> Void)?
    var onReply: ((PrayerResponse) -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "figure.and.child.holdinghands")
                .foregroundColor(.customNavy)
                .frame(width: 35, height: 35)
                .background(.customBlue1.opacity(0.4))
                .cornerRadius(15)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(response.userName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)

                    Spacer()

                    Button {
                        showConfirmationDialog = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .foregroundColor(.gray)
                    }
                }

                Text(response.createdAt.toTimeAgoDisplay())
                    .font(.caption2)
                    .foregroundColor(.gray)

                Text(response.message.trimmingCharacters(in: .whitespacesAndNewlines))
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    Spacer()
                    Button {
                        onReply?(response)
                    } label: {
                        Text(response.replyCount > 0
                             ? "답글 (\(response.replyCount))"
                             : "답글")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.customBlue1)
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 15, leading: 15, bottom: 20, trailing: 15))
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .confirmationDialog(
            "",
            isPresented: $showConfirmationDialog,
            titleVisibility: .hidden
        ) {
            if response.isMine == true {
                Button("수정") {
                    onEdit?(response)
                }
                Button("삭제", role: .destructive) {
                    confirmAlert = .delete(target: "응답")
                }
            } else {
                Button("신고", role: .destructive) {
                    showReportActionSheet = true
                }
                Button("차단", role: .destructive) {
                    confirmAlert = .block
                }
            }
            Button("취소", role: .cancel) { }
        }
        .alert(confirmAlert?.title ?? "",
               isPresented: Binding(get: { confirmAlert != nil },
                                    set: { if !$0 { confirmAlert = nil } }),
               presenting: confirmAlert) { type in
            Button("확인", role: .destructive) {
                switch type {
                case .delete(_): onDelete?(response)
                case .report(_): break
                case .block: onBlock?(response)
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
                Task { await onReport?(response, .inappropriateContent, nil) }
            }
            Button("스팸/광고/중복게시") {
                Task { await onReport?(response, .spam, nil) }
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
                Task { await onReport?(response, .other, reportReasonDetail) }
            }
            Button("취소", role: .cancel) { }
        }
        .alert(item: $resultAlert) { alert in
            Alert(title: Text(alert.title),
                  message: Text(alert.message),
                  dismissButton: .default(Text("확인")))
        }
    }
}


#Preview {
    CommentRowView(response: PrayerResponse(id: 0,
                                                   prayerRequestId: 0,
                                                   userId: 0,
                                                   userName: "",
                                                   message: "어머님의 수술이 잘 되시길 기도하겠습니다. 하나님께서 함께 하실 거예요.",
                                                   createdAt: "2025-11-07T12:55:00.000Z",
                                                   isMine: false,
                                                   parentResponseId: nil,
                                                   replyCount: 0),
                          onEdit: nil,
                          onDelete: nil,
                          onReport: nil,
                          onBlock: nil,
                          onReply: nil)
    .padding()
}
