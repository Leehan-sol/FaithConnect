//
//  ReplyRowView.swift
//  FaithConnect
//

import SwiftUI

struct ReplyRowView: View {
    @State private var showConfirmationDialog = false
    @State private var confirmAlert: ConfirmAlertType?
    @State private var showReportActionSheet = false
    @State private var showReportDetailAlert = false
    @State private var reportReasonDetail = ""

    let reply: PrayerResponse
    let onEdit: ((PrayerResponse) -> Void)?
    let onDelete: ((PrayerResponse) -> Void)?
    var onReport: ((PrayerResponse, ReportReasonType, String?) async -> Bool)? = nil
    let onBlock: ((PrayerResponse) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "arrow.turn.down.right")
                .foregroundColor(.customNavy.opacity(0.5))
                .frame(width: 35, height: 35)
                .background(.customBlue1.opacity(0.2))
                .cornerRadius(15)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(reply.userName)
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

                Text(reply.createdAt.toTimeAgoDisplay())
                    .font(.caption2)
                    .foregroundColor(.gray)

                Text(reply.message.trimmingCharacters(in: .whitespacesAndNewlines))
                    .frame(maxWidth: .infinity, alignment: .leading)
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
            if reply.isMine == true {
                Button("수정") {
                    onEdit?(reply)
                }
                Button("삭제", role: .destructive) {
                    confirmAlert = .delete(target: "답글")
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
                case .delete(_): onDelete?(reply)
                case .report(_): break
                case .block: onBlock?(reply)
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
                Task { await onReport?(reply, .inappropriateContent, nil) }
            }
            Button("스팸/광고/중복게시") {
                Task { await onReport?(reply, .spam, nil) }
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
                Task { await onReport?(reply, .other, reportReasonDetail) }
            }
            Button("취소", role: .cancel) { }
        }
    }
}


#Preview {
    ReplyRowView(reply: PrayerResponse(id: 1,
                                       prayerRequestId: 0,
                                       userId: 0,
                                       userName: "",
                                       message: "감사합니다. 함께 기도해주셔서 힘이 됩니다.",
                                       createdAt: "2025-11-07T12:55:00.000Z",
                                       isMine: false,
                                       parentResponseId: nil,
                                       replyCount: 0,
                                       contentStatus: .normal),
                 onEdit: nil,
                 onDelete: nil,
                 onReport: nil,
                 onBlock: nil)
    .padding(.horizontal, 40)
    .padding(.vertical, 10)
}
