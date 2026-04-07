//
//  PrayerResponseRow.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/09.
//

import SwiftUI

struct PrayerResponseRowView: View {
    @State private var showConfirmationDialog = false
    @State private var showDeleteAlert = false
    @State private var showReportActionSheet = false
    @State private var showReportDetailAlert = false
    @State private var reportReasonDetail = ""
    @State private var showBlockAlert = false
    @State private var showReportCompleteAlert = false
    @State private var showBlockCompleteAlert = false
    let response: PrayerResponse
    let onEdit: ((PrayerResponse) -> Void)?
    let onDelete: (PrayerResponse) -> Void
    var onReport: ((PrayerResponse, ReportReasonType, String?) async -> Bool)? = nil
    
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
                
                Text(response.createdAt.toTimeAgoDisplay())
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
        .alert("응답 삭제",
               isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                onDelete(response)
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("이 응답을 삭제하시겠습니까? \n삭제된 내용은 복구할 수 없습니다.")
        }
        .confirmationDialog("신고 사유를 선택해주세요",
                            isPresented: $showReportActionSheet,
                            titleVisibility: .visible) {
            Button("부적절한 내용") {
                Task {
                    if await onReport?(response, .inappropriateContent, nil) == true {
                        showReportCompleteAlert = true
                    }
                }
            }
            Button("스팸/광고/중복게시") {
                Task {
                    if await onReport?(response, .spam, nil) == true {
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
                    if await onReport?(response, .other, reportReasonDetail) == true {
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
    }
}

#Preview {
    PrayerResponseRowView(response: PrayerResponse(id: 0,
                                                   prayerRequestId: 0,
                                                   message: "어머님의 수술이 잘 되시길 기도하겠습니다. 하나님께서 함께 하실 거예요.",
                                                   createdAt: "2025-11-07T12:55:00.000Z",
                                                   isMine: false),
                          onEdit: nil,
                          onDelete: { _ in })
    .padding()
}
