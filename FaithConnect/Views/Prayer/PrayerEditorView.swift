//
//  PrayerEditorView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

struct PrayerEditorView: View {
    @StateObject var viewModel: PrayerEditorViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategoryId: Int = 0
    @State var title: String = ""
    @State var content: String = ""
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Spacer()
                .frame(height: 20)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("카테고리")
                    .font(.subheadline)
                    .bold()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.category, id: \.self) { category in
                            CategoryButtonView(
                                category: category,
                                isSelected: category.id == selectedCategoryId,
                                action: {
                                    selectedCategoryId = category.id
                                }
                            )
                        }
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0))
                
                LabeledTextField(title: "제목", placeholder: "기도 제목을 입력하세요", text: $title)
                    .padding(.bottom, 20)
                
                Text("내용")
                    .font(.subheadline)
                    .bold()
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $content)
                        .frame(height: 250)
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
                
                VStack(alignment: .leading, spacing:5) {
                    Text("• 기도제목은 익명으로 공유됩니다.")
                    Text("• 이름과 연락처 등 개인정보는 작성하지 말아주세요.")
                    Text("• 모든 성도들이 함께 기도할 수 있도록 진솔하게 작성해 주세요.")
                }
                .font(.footnote)
                .padding(EdgeInsets(top: 18, leading: 8, bottom: 18, trailing: 0))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.customNavy)
                .background(Color(.customBlue1).opacity(0.2))
                .cornerRadius(10)
                .padding(.bottom, 20)
                
                Spacer()
                
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
            .navigationTitle("새 기도")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("취소")
                            .bold()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("완료")
                            .bold()
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
        }
        }
    }
}

#Preview {
    PrayerEditorView(viewModel: PrayerEditorViewModel())
}
