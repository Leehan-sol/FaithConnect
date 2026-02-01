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
                        Text(viewModel.prayer?.categoryName ?? "")
                            .frame(width: 40, height: 30)
                            .foregroundColor(.customNavy)
                            .background(.customBlue1.opacity(0.2))
                            .bold()
                            .font(.caption)
                            .cornerRadius(10)
                        
                        Text(viewModel.prayer?.title ?? "")
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
                            Text("이 기도제목에 응답하는 메세지를 작성해주세요. \r \r익명으로 전송되며, 작성자에게 알림이 전달됩니다.")
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
                        Task {
                            let result = await viewModel.writePrayerResponse(message: content)
                            if result {
                                dismiss()
                            }
                        }
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

#Preview {
    let mockAPIClient = APIClient(tokenStorage: TokenStorage())
    let mockRepo = PrayerRepository(apiClient: mockAPIClient)
    let mockUseCase = PrayerUseCase(repository: mockRepo)
    
    return PrayerDetailBottomSheetView(viewModel: PrayerDetailViewModel(prayerUseCase: mockUseCase,
                                                                 prayerRequestId: 0))
}
