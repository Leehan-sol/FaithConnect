//
//  PrayerDetailBottomSheetView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/16.
//

import SwiftUI

struct PrayerDetailBottomSheetView: View {
    @ObservedObject var viewModel: PrayerDetailViewModel
    @State var content: String = ""
    @State var wordCount: Int = 0
    @State var showAlert: Bool = false
    @Environment(\.dismiss) var dismiss
    
    private var isSendButtonActive: Bool {
        return wordCount > 0
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Spacer()
                        .frame(height: 5)
                    
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
                            .padding(EdgeInsets(top: 8,
                                                leading: 8,
                                                bottom: 8,
                                                trailing: 8))
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .scrollContentBackground(.hidden)
                            .onChange(of: content) { oldValue, newValue in
                                wordCount = newValue.count
                                
                                if newValue.count > 500 {
                                    content = String(newValue.prefix(500))
                                }
                            }
                        
                        if content.isEmpty {
                            Text(viewModel.contentPlaceholder)
                                .foregroundColor(Color(uiColor: .placeholderText))
                                .font(.body)
                                .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
                                .allowsHitTesting(false)
                        }
                    }
                    
                    Text("💡 따뜻한 격려의 메시지를 보내주세요.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .overlay(
                            Text("\(wordCount) / 500")
                                .font(.caption)
                                .foregroundColor(wordCount == 500 ? .red : .gray)
                                .padding(.trailing, 8),
                            alignment: .trailing
                        )
                }
                .padding()
                
            }
            
            HStack {
                ActionButton(title: "취소",
                             foregroundColor: .gray,
                             backgroundColor: Color(.systemGray6)) {
                    if isSendButtonActive {
                        showAlert = true
                    } else {
                        dismiss()
                    }
                }
                
                ActionButton(title: "전송",
                             foregroundColor: isSendButtonActive ? .white : .gray,
                             backgroundColor: isSendButtonActive ? .customBlue1 : Color(.systemGray6)) {
                    if isSendButtonActive {
                        // TODO: - 응답 전송 로직 호출
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
        }.alert("작성 취소", isPresented: $showAlert) {
            Button("취소", role: .cancel) { }
            Button("확인", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("작성 중인 응답 내용이 있습니다. \r 정말 취소하시겠습니까?")
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

//#Preview {
//    PrayerDetailBottomSheetView(viewModel: PrayerDetailViewModel(prayer: Prayer(prayerRequestId: 1,
//                                                                                prayerUserId: "a1",
//                                                                                prayerUserName: "김철수",
//                                                                                categoryId: 101,
//                                                                                categoryName: "건강",
//                                                                                title: "부모님 건강을 위해 기도합니다",
//                                                                                content: "다음 주 화요일에 어머니께서 큰 수술을 받으십니다. 어쩌구저쩌구 \r\r어쩌구저쩌구어쩌구저쩌 구어쩌구저쩌구어쩌구저쩌구어쩌구저쩌구어 쩌구저쩌구어쩌구저쩌구 \r어쩌구저쩌구 \r\r어쩌구저쩌구 기도해주세요.",
//                                                                                createdAt: "2025-11-07T12:55:00.000Z",
//                                                                                participationCount: 5,
//                                                                                responses: [Response(prayerResponseId: 0, prayerRequestId: "", message: "어머님의 수술이 잘 되시길 기도하겠습니다. 하나님께서 함께 하실 거예요.", createdAt: "2025-11-02T13:25:49.384Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "함께 기도합니다. 빠른 회복 기도할게요!", createdAt: "2025-11-01T09:15:30.000Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "기도합니다 수술 잘되실거예요!!", createdAt: "2025-10-30T18:45:10.500Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "어머님과 가족 모두에게 평안이 함께하시길 기도합니다.", createdAt: "2025-10-25T07:55:40.250Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "기도합니다 수술 잘되실거예요!!", createdAt: "2024-10-25T07:55:40.250Z")],
//                                                                                hasParticipated: false)))
//}
