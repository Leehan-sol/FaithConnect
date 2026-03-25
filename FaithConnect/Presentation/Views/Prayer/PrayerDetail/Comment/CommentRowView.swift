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
    
    let response: PrayerResponse
    let onEdit: ((PrayerResponse) -> Void)?
    let onDelete: ((PrayerResponse) -> Void)?
    let onReport: ((PrayerResponse) -> Void)?
    let onBlock: ((PrayerResponse) -> Void)?
    var onReply: ((PrayerResponse) -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "figure.and.child.holdinghands")
                .foregroundColor(.customNavy)
                .frame(width: 35, height: 35)
                .background(.customBlue1.opacity(0.4))
                .cornerRadius(15)
            
            VStack(alignment: .leading, spacing: 20) {
                Text(response.message.trimmingCharacters(in: .whitespacesAndNewlines))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 10) {
                    Text(response.createdAt.toTimeAgoDisplay())
                        .font(.caption2)
                        .foregroundColor(.gray)

                    Button {
                        onReply?(response)
                    } label: {
                        Text(response.replies.isEmpty
                             ? "답글"
                             : "답글 (\(response.replies.count))")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.customBlue1)
                    }
                }
            }
            
            Button {
                showConfirmationDialog = true
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(.gray)
            }
            .padding(.top, 5)
        }
        .padding(15)
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
                    confirmAlert = .report(target: "응답")
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
                case .report(_): onReport?(response)
                case .block: onBlock?(response)
                }
            }
            Button("취소", role: .cancel) { }
        } message: { type in
            Text(type.message)
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
                                                   message: "어머님의 수술이 잘 되시길 기도하겠습니다. 하나님께서 함께 하실 거예요.",
                                                   createdAt: "2025-11-07T12:55:00.000Z",
                                                   isMine: false),
                          onEdit: nil,
                          onDelete: nil,
                          onReport: nil,
                          onBlock: nil,
                          onReply: nil)
    .padding()
}
