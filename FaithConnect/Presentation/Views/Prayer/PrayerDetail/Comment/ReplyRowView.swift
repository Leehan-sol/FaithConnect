//
//  ReplyRowView.swift
//  FaithConnect
//

import SwiftUI

struct ReplyRowView: View {
    @State private var showConfirmationDialog = false
    @State private var confirmAlert: ConfirmAlertType?
    
    let reply: PrayerResponse
    let onEdit: ((PrayerResponse) -> Void)?
    let onDelete: ((PrayerResponse) -> Void)?
    let onReport: ((PrayerResponse) -> Void)?
    let onBlock: ((PrayerResponse) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "arrow.turn.down.right")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 10) {
                Text(reply.message.trimmingCharacters(in: .whitespacesAndNewlines))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(reply.createdAt.toTimeAgoDisplay())
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Button {
                showConfirmationDialog = true
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
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
                    confirmAlert = .report(target: "답글")
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
                case .report(_): onReport?(reply)
                case .block: onBlock?(reply)
                }
            }
            Button("취소", role: .cancel) { }
        } message: { type in
            Text(type.message)
        }
    }
}


#Preview {
    ReplyRowView(reply: PrayerResponse(id: 1,
                                       prayerRequestId: 0,
                                       message: "감사합니다. 함께 기도해주셔서 힘이 됩니다.",
                                       createdAt: "2025-11-07T12:55:00.000Z",
                                       isMine: false),
                 onEdit: nil,
                 onDelete: nil,
                 onReport: nil,
                 onBlock: nil)
    .padding(.horizontal, 40)
    .padding(.vertical, 10)
}
