//
//  PrayerDetailView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

struct PrayerDetailView: View {
    @StateObject var viewModel: PrayerDetailViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 25) {
                HStack {
                    Text(viewModel.prayer.categoryName)
                        .frame(width: 40, height: 30)
                        .foregroundColor(.customNavy)
                        .background(.customBlue1.opacity(0.2))
                        .bold()
                        .font(.caption)
                        .cornerRadius(10)
                    
                    Text(viewModel.prayer.createdAt.toTimeAgoDisplay())
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
               
                Text(viewModel.prayer.title)
                    .font(.title)
                    
                Text(viewModel.prayer.content)

                Divider()
                
                Text("\(viewModel.prayer.participationCount)명이 기도했습니다.")
                    .font(.headline)
                    .foregroundColor(Color(.darkGray))
                
                // TODO: - 답글 
                
                ActionButton(title: "기도 응답하기",
                             backgroundColor: .customBlue1) {

                }.padding(.bottom, 10)
                
            }
            .frame(maxWidth: .infinity)
        .padding()
        }
    }
}

#Preview {
    PrayerDetailView(viewModel: PrayerDetailViewModel(prayer:         Prayer(prayerRequestId: 1, prayerUserId: "a1", prayerUserName: "김철수", categoryId: 101, categoryName: "건강", title: "부모님 건강을 위해 기도합니다", content: "다음 주 화요일에 어머니께서 큰 수술을 받으십니다. 어쩌구저쩌구 \r\r어쩌구저쩌구어쩌구저쩌 구어쩌구저쩌구어쩌구저쩌구어쩌구저쩌구어 쩌구저쩌구어쩌구저쩌구 \r어쩌구저쩌구 \r\r어쩌구저쩌구 기도해주세요.", createdAt: "2025-11-07T12:55:00.000Z", participationCount: 5, responses: [Response(prayerResponseId: 0, prayerRequestId: "", message: "기도합니다 수술 잘되실거예요!!", createdAt: "")], hasParticipated: false)))
}
