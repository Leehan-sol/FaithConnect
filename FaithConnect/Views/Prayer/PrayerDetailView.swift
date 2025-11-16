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
                }
            }
        }
        ActionButton(title: "기도 응답하기",
                     foregroundColor: .white,
                     backgroundColor: .customBlue1) {
            showBottomSheet = true
        }.padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
            .sheet(isPresented: $showBottomSheet) {
                PrayerDetailBottomSheetView(viewModel: viewModel)
                    .presentationDetents([.fraction(0.75)])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(true)
            }
    }
}





#Preview {
    PrayerDetailView(viewModel: PrayerDetailViewModel(prayer: Prayer(prayerRequestId: 1,
                                                                     prayerUserId: "a1",
                                                                     prayerUserName: "김철수",
                                                                     categoryId: 101,
                                                                     categoryName: "건강",
                                                                     title: "부모님 건강을 위해 기도합니다",
                                                                     content: "다음 주 화요일에 어머니께서 큰 수술을 받으십니다. 어쩌구저쩌구 \r\r어쩌구저쩌구어쩌구저쩌 구어쩌구저쩌구어쩌구저쩌구어쩌구저쩌구어 쩌구저쩌구어쩌구저쩌구 \r어쩌구저쩌구 \r\r어쩌구저쩌구 기도해주세요.",
                                                                     createdAt: "2025-11-07T12:55:00.000Z",
                                                                     participationCount: 5,
                                                                     responses: [Response(prayerResponseId: 0, prayerRequestId: "", message: "어머님의 수술이 잘 되시길 기도하겠습니다. 하나님께서 함께 하실 거예요.", createdAt: "2025-11-02T13:25:49.384Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "함께 기도합니다. 빠른 회복 기도할게요!", createdAt: "2025-11-01T09:15:30.000Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "SwiftUI에서 Alert와 Sheet 같은 모달 뷰를 다룰 때, 사용자 경험을 개선하고 의도치 않은 데이터 손실을 방지하는 것이 중요합니다. 특히 TextEditor를 통해 사용자 입력을 받는 바텀 시트(DetailBottomSheetView)의 경우, 사용자가 작성 중인 내용을 저장하지 않고 시트를 닫으려 할 때 경고창(Alert)을 띄워야 합니다. Alert를 띄우는 핵심 원리는 @State 변수와 바인딩입니다. @State var showAlert: Bool = false를 선언하고, 버튼 액션 내에서 사용자의 입력 상태(wordCount > 0)를 확인하여 이 변수를 true로 토글합니다. Alert 모디파이어는 이 바인딩된 변수가 true가 될 때 화면에 나타납니다. 또한, 바텀 시트의 드래그하여 닫기(Swipe-to-Dismiss) 동작을 막으려면 .interactiveDismissDisabled(true)를 사용해야 합니다. 이 모디파이어는 사용자가 명시적인 버튼 액션을 통해서만 시트를 닫도록 강제합니다. 이는 중요한 입력 필드가 포함된 시트에서 실수로 데이터가 사라지는 것을 방지하는 필수적인 조치입니다. Alert 버튼을 구현할 때는 최신 SwiftUI의 actions 클로저를 사용하며, 시트를 닫는 dismiss() 함수는 버튼 클릭 시 실행되도록 반드시 클로저 {} 내부에 위치시켜야 합니다. 이 구조는 뷰가 생성될 때 함수가 즉시 실행되는 오류를 방지합니다. 예를 들어, 취소하고 나가 버튼은 Button(취소하고 나가기 role: .destructive) { dismiss() } 형태로 작성되어야 올바르게 작동합니다. 이러한 구조적 이해는 SwiftUI 개발에서 매우 중요합니다.", createdAt: "2025-10-30T18:45:10.500Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "어머님과 가족 모두에게 평안이 함께하시길 기도합니다.", createdAt: "2025-10-25T07:55:40.250Z"), Response(prayerResponseId: 0, prayerRequestId: "", message: "기도합니다 수술 잘되실거예요!!", createdAt: "2024-10-25T07:55:40.250Z")],
                                                                     hasParticipated: false)))
    
}
