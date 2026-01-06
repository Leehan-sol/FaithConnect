//
//  PrayerResponseRow.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/09.
//

import SwiftUI

struct PrayerResponseRowView: View {
    @EnvironmentObject private var session: UserSession
    @State private var showConfirmationDialog = false
    @State private var showDeleteAlert = false
    let response: PrayerResponse
    let onDelete: (PrayerResponse) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "figure.and.child.holdinghands")
                .foregroundColor(.customNavy)
                .frame(width: 35, height: 35)
                .background(.customBlue1.opacity(0.4))
                .cornerRadius(15)
            
            VStack(alignment: .leading, spacing: 20) {
                Text(response.message)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(response.createdAt.toTimeAgoDisplay())
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if response.isMine == true {
                Button {
                    showConfirmationDialog = true
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.gray)
                }
                .padding(.top, 5)
            }
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
            //            Button("수정") {
            //                showPrayerEditor = true
            //            }
            
            Button("삭제", role: .destructive) {
                showDeleteAlert = true
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
            Text("이 응답을 삭제하시겠습니까? \n 삭제된 내용은 복구할 수 없습니다.")
        }
    }
}

#Preview {
    PrayerResponseRowView(response: PrayerResponse(id: 0,
                                                   prayerRequestId: 0,
                                                   message: "어머님의 수술이 잘 되시길 기도하겠습니다. 하나님께서 함께 하실 거예요.",
                                                   createdAt: "2025-11-07T12:55:00.000Z",
                                                   isMine: false),
                          onDelete: { _ in })
    .padding()
    .environmentObject(UserSession())
}
