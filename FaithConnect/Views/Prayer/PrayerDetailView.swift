//
//  PrayerDetailView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

struct PrayerDetailView: View {
    @StateObject var viewModel: PrayerDetailViewModel
    @State private var showBottomSheet = false
    
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
                    .font(.title2)
                
                Text(viewModel.prayer.content)
                
                Divider()
                
                Text("\(viewModel.prayer.participationCount)명이 기도했습니다.")
                    .font(.headline)
                    .foregroundColor(Color(.darkGray))
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
            
            VStack(spacing: 0) {
                ForEach(viewModel.prayer.responses) { response in
                    PrayerResponseRowView(response: response)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .onTapGesture {
                            
                        }
                }
            }
        }
        ActionButton(title: "기도 응답하기",
                     backgroundColor: .customBlue1) {
            showBottomSheet = true
        }.padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
            .sheet(isPresented: $showBottomSheet) {
                DetailBottomSheetView(viewModel: viewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
    }
}


struct DetailBottomSheetView: View {
    @ObservedObject var viewModel: PrayerDetailViewModel
    @State var content: String = ""
    @State var wordCount: String = "0"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("기도 응답 보내기")
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 15) {
                Text(viewModel.prayer.categoryName)
                    .frame(width: 40, height: 30)
                    .foregroundColor(.customNavy)
                    .background(.customBlue1.opacity(0.2))
                    .bold()
                    .font(.caption)
                    .cornerRadius(10)
                
                Text(viewModel.prayer.title)
                    .bold()
            }.padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $content)
                    .frame(height: 200)
                    .padding(EdgeInsets(top: 8, leading
                                        : 8, bottom: 8, trailing: 8))
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .scrollContentBackground(.hidden)
                
                if content.isEmpty {
                    Text(viewModel.contentPlaceholder)
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .font(.body)
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
                        .allowsHitTesting(false)
                }
            }
            .padding(.bottom, 20)
            
            InfoBoxView(messages: [
                "💡 따뜻한 격려의 메시지를 보내주세요."])
            .overlay(
                Text("\(wordCount) / 500")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.trailing, 8),
                alignment: .trailing
            )
            
            Spacer()
        }
        .padding()
        
    }
}


#Preview {
//    PrayerDetailView(viewModel: PrayerDetailViewModel(prayer: Prayer(prayerRequestId: 1,
//                                                                     prayerUserId: "a1",
//                                                                     prayerUserName: "김철수",
//                                                                     categoryId: 101,
//                                                                     categoryName: "건강",
//                                                                     title: "부모님 건강을 위해 기도합니다",
//                                                                     content: "다음 주 화요일에 어머니께서 큰 수술을 받으십니다. 어쩌구저쩌구 \r\r어쩌구저쩌구어쩌구저쩌 구어쩌구저쩌구어쩌구저쩌구어쩌구저쩌구어 쩌구저쩌구어쩌구저쩌구 \r어쩌구저쩌구 \r\r어쩌구저쩌구 기도해주세요.",
//                                                                     createdAt: "2025-11-07T12:55:00.000Z",
//                                                                     participationCount: 5,
//                                                                     responses: [Response(prayerResponseId: 0, prayerRequestId: "", message: "어머님의 수술이 잘 되시길 기도하겠습니다. 하나님께서 함께 하실 거예요.", createdAt: "2025-11-02T13:25:49.384Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "함께 기도합니다. 빠른 회복 기도할게요!", createdAt: "2025-11-01T09:15:30.000Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "기도합니다 수술 잘되실거예요!!", createdAt: "2025-10-30T18:45:10.500Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "어머님과 가족 모두에게 평안이 함께하시길 기도합니다.", createdAt: "2025-10-25T07:55:40.250Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "기도합니다 수술 잘되실거예요!!", createdAt: "2024-10-25T07:55:40.250Z")],
//                                                                     hasParticipated: false)))
    
    
    DetailBottomSheetView(viewModel: PrayerDetailViewModel(prayer: Prayer(prayerRequestId: 1,
                                                                          prayerUserId: "a1",
                                                                          prayerUserName: "김철수",
                                                                          categoryId: 101,
                                                                          categoryName: "건강",
                                                                          title: "부모님 건강을 위해 기도합니다",
                                                                          content: "다음 주 화요일에 어머니께서 큰 수술을 받으십니다. 어쩌구저쩌구 \r\r어쩌구저쩌구어쩌구저쩌 구어쩌구저쩌구어쩌구저쩌구어쩌구저쩌구어 쩌구저쩌구어쩌구저쩌구 \r어쩌구저쩌구 \r\r어쩌구저쩌구 기도해주세요.",
                                                                          createdAt: "2025-11-07T12:55:00.000Z",
                                                                          participationCount: 5,
                                                                          responses: [Response(prayerResponseId: 0, prayerRequestId: "", message: "어머님의 수술이 잘 되시길 기도하겠습니다. 하나님께서 함께 하실 거예요.", createdAt: "2025-11-02T13:25:49.384Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "함께 기도합니다. 빠른 회복 기도할게요!", createdAt: "2025-11-01T09:15:30.000Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "기도합니다 수술 잘되실거예요!!", createdAt: "2025-10-30T18:45:10.500Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "어머님과 가족 모두에게 평안이 함께하시길 기도합니다.", createdAt: "2025-10-25T07:55:40.250Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "기도합니다 수술 잘되실거예요!!", createdAt: "2024-10-25T07:55:40.250Z")],
                                                                          hasParticipated: false)))
}
