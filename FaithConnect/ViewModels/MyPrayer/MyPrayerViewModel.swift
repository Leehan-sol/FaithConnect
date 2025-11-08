//
//  MyPrayerViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

class MyPrayerViewModel: ObservableObject {
    
    // TODO: -
    // 1. 내 기도 조회
    // 2. 내가 기도한 기도 조회
    
    @Published var prayers: [Prayer] = [
        Prayer(prayerRequestId: 1, prayerUserId: "a1", prayerUserName: "김철수", categoryId: 101, categoryName: "건강", title: "부모님 건강을 위해 매일매일 기도합니다 여러분도 기도해주세요", content: "다음 주 화요일에 어머니께서 큰 수술을 받으십니다. 어쩌구저쩌구", createdAt: "2025-11-07T12:55:00.000Z", participationCount: 5, responses: [Response(prayerResponseId: 0, prayerRequestId: "", message: "기도합니다 수술 잘되실거예요!!", createdAt: "")], hasParticipated: false),
        Prayer(prayerRequestId: 2, prayerUserId: "a2", prayerUserName: "이영희", categoryId: 102, categoryName: "시험", title: "시험 합격 기도해주세요 부탁드려요", content: "다가오는 국가고시에서 최선을 다해 좋은 결과를 얻을 수 있도록 기도합니다. 공부한 내용이 시험에서 잘 나오고, 긴장하지 않고 평정심을 유지할 수 있기를 바랍니다. 부족한 부분이 있더라도 포기하지 않고 끝까지 최선을 다할 수 있는 힘을 달라고 기도합니다. 또한 주위 사람들에게 감사한 마음을 잊지 않고 겸손하게 임할 수 있기를 바랍니다.", createdAt: "2025-11-02T13:25:49.384Z", participationCount: 3, responses: [Response(prayerResponseId: 0, prayerRequestId: "", message: "국가고시 꼭 합격하시길 바랍니다 어쩌궂 ㅓ쩌궂 가ㅜㅅㄷㅎㄱ누ㅏ누한", createdAt: "")], hasParticipated: false),
          Prayer(prayerRequestId: 3, prayerUserId: "a1", prayerUserName: "박민수", categoryId: 103, categoryName: "취업", title: "취업 잘할 수 있겠죠?", content: "희망하는 회사에 합격할 수 있도록 기도합니다. 면접에서 긴장하지 않고 자신의 역량을 잘 보여줄 수 있게 도와주시고, 준비한 모든 것이 최선의 결과로 이어지길 바랍니다. 또한 새로운 직장에서 올바른 사람들과 함께 일하며 성장할 수 있는 기회를 주시길 기도합니다.", createdAt: "2025-11-01T09:15:30.000Z", participationCount: 8, responses: [Response(prayerResponseId: 0, prayerRequestId: "", message: "회사 합격하실거고 어쩌줒거저저저저저저주줒", createdAt: "")], hasParticipated: false),
          Prayer(prayerRequestId: 4, prayerUserId: "a1", prayerUserName: "최지은", categoryId: 104, categoryName: "가족", title: "가족의 화목을 기도합니다...", content: "우리 가족이 서로를 이해하고 배려하며 화목하게 지낼 수 있도록 기도합니다. 갈등이 생겼을 때 서로의 마음을 헤아리고 용서할 수 있는 마음을 달라고 기도합니다. 가족 간의 사랑과 신뢰가 더욱 깊어지며, 함께하는 시간이 소중하게 느껴지도록 도와주시길 바랍니다.", createdAt: "2025-10-30T18:45:10.500Z", participationCount: 6, responses: [Response(prayerResponseId: 0, prayerRequestId: "", message: "잘되실거에요 진심으로 기도합니다", createdAt: "")], hasParticipated: false),
          Prayer(prayerRequestId: 5, prayerUserId: "a1", prayerUserName: "정우진", categoryId: 105, categoryName: "평안", title: "마음의 평안을 얻을 수 있도록", content: "최근 마음이 복잡하고 스트레스가 많아 잠을 잘 이루지 못하고 있습니다. 하루하루 감사한 마음을 잃지 않고, 마음의 평안을 찾을 수 있도록 기도합니다. 작은 일에도 감사함을 느끼며, 마음속 걱정과 불안을 내려놓고 안정된 삶을 살아갈 수 있게 도와주세요. 주님의 은혜 안에서 평화로운 마음을 유지하도록 인도해 주시기를 간절히 기도합니다.", createdAt: "2024-10-25T07:55:40.250Z", participationCount: 4, responses: [Response(prayerResponseId: 0, prayerRequestId: "", message: "화이팅 모든 일 다 잘되길 좋은 하루하루 보내시길", createdAt: "")], hasParticipated: false)
      ]
}
