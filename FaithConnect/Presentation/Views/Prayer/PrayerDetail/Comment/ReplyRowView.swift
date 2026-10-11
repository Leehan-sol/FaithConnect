//
//  ReplyRowView.swift
//  FaithConnect
//

import SwiftUI

struct ReplyRowView: View {
    @State private var confirmAlert: ConfirmAlertType?
    @State private var showReportDetailAlert = false
    @State private var reportReasonDetail = ""

    let reply: PrayerResponse
    let onEdit: ((PrayerResponse) -> Void)?
    let onDelete: ((PrayerResponse) -> Void)?
    var onReport: ((PrayerResponse, ReportReasonType, String?) async -> Bool)? = nil
    let onBlock: ((PrayerResponse) -> Void)?

    private var isUnavailable: Bool {
        reply.userName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var isWithdrawnUser: Bool {
        reply.userName == "탈퇴한 사용자"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "arrow.turn.down.right")
                .foregroundColor(isUnavailable ? .gray : .customNavy.opacity(0.5))
                .frame(width: 35, height: 35)
                .background(isUnavailable ? Color(.systemGray4) : .customBlue1.opacity(0.2))
                .cornerRadius(15)

            VStack(alignment: .leading, spacing: 6) {
                if isUnavailable {
                    Text(reply.message)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    HStack {
                        Text(reply.userName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        if reply.role == .pastor {
                            ZStack {
                                Image(systemName: "seal.fill")
                                    .foregroundColor(.customPurple)
                                Image(systemName: "cross.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 5))
                            }
                            .font(.caption2)
                            .offset(x: -4)
                        }

                        Spacer()

                        if reply.visibility == .pastorOnly {
                            Text("비공개")
                                .font(.caption2)
                                .foregroundColor(.customPurple)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.customPurple.opacity(0.15))
                                .cornerRadius(6)
                        }

                        if !isWithdrawnUser {
                            Menu {
                                if reply.isMine == true {
                                    Button { onEdit?(reply) } label: {
                                        Label("수정", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) { confirmAlert = .delete(target: "답글") } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                } else {
                                    Menu {
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
                                    } label: {
                                        Label("신고", systemImage: "exclamationmark.triangle")
                                    }
                                    Button(role: .destructive) { confirmAlert = .block } label: {
                                        Label("차단", systemImage: "hand.raised")
                                    }
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .rotationEffect(.degrees(90))
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    Text(reply.createdAt.toTimeAgoDisplay())
                        .font(.caption2)
                        .foregroundColor(.gray)

                    Text(reply.message.trimmingCharacters(in: .whitespacesAndNewlines))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(EdgeInsets(top: 15, leading: 15, bottom: 20, trailing: 15))
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
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
                                       visibility: nil,
                                       displayNameType: nil,
                                       role: nil,
                                       createdAt: "2025-11-07T12:55:00.000Z",
                                       isMine: false,
                                       parentResponseId: nil,
                                       replyCount: 0),
                 onEdit: nil,
                 onDelete: nil,
                 onReport: nil,
                 onBlock: nil)
    .padding(.horizontal, 40)
    .padding(.vertical, 10)
}
