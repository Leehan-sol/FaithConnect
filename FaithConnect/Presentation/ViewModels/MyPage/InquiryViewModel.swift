//
//  InquiryViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2026/03/16.
//

import Foundation

@MainActor
class InquiryViewModel: ObservableObject {
    @Published var alertType: AlertType? = nil
    @Published var isLoading: Bool = false

    private let authUseCase: AuthUseCaseProtocol

    init(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
    }

    func sendInquiry(title: String, content: String, userEmail: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authUseCase.sendInquiry(title: title,
                                              content: content,
                                              userEmail: userEmail)
            alertType = .success(title: "문의 완료", message: "문의가 성공적으로 전송되었습니다.")
        } catch {
            alertType = .error(title: "문의 실패", message: error.localizedDescription)
        }
    }
}
