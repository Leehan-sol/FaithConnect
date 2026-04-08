//
//  DeleteAccountView.swift
//  FaithConnect
//
//  Created by hansol on 2026/03/16.
//

import SwiftUI

struct DeleteAccountView: View {
    @ObservedObject var viewModel: MyPageViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading: Bool = false
    @State private var showDeleteConfirm: Bool = false

    private let reasons = [
        "자주 사용하지 않아요",
        "서비스가 불만족스러워요",
        "기타"
    ]

    @State private var selectedReason: String?
    @State private var agreedToTerms: Bool = false

    private var isDeleteButtonActive: Bool {
        selectedReason != nil && agreedToTerms
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    InfoBoxView(
                        messages: [
                            "• 작성한 모든 기도제목이 삭제됩니다",
                            "• 받은 응답 내역이 모두 사라집니다",
                            "• 계정 정보는 복구할 수 없습니다",
                        ],
                        icon: "exclamationmark.circle",
                        title: "탈퇴 전 꼭 확인해주세요",
                        textColor: .red,
                        backgroundColor: Color.red.opacity(0.08)
                    ).padding(.bottom, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("탈퇴 사유를 알려주세요")
                            .font(.headline)

                        Text("더 나은 서비스를 위해 소중한 의견을 들려주세요.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    VStack(spacing: 12) {
                        ForEach(reasons, id: \.self) { reason in
                            ReasonRow(reason: reason,
                                      isSelected: selectedReason == reason) {
                                selectedReason = reason
                            }
                        }
                    }

                    Button {
                        agreedToTerms.toggle()
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(agreedToTerms ? .black : Color(.systemGray5))
                                .font(.title3)

                            Text("위 안내사항을 모두 확인했으며, 회원 탈퇴에 동의합니다.")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
            }

            VStack(spacing: 12) {
                ActionButton(
                    title: "회원 탈퇴",
                    foregroundColor: isDeleteButtonActive ? .white : .gray,
                    backgroundColor: isDeleteButtonActive ? .customBlue1 : Color(.systemGray5)
                ) {
                    if isDeleteButtonActive {
                        showDeleteConfirm = true
                    }
                }

                Button {
                    dismiss()
                } label: {
                    Text("계정 유지하기")
                        .font(.subheadline)
                        .foregroundColor(.customBlue1)
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal)
        }
        .disabled(isLoading)
        .overlay {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            }
        }
        .navigationTitle("회원탈퇴")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButtonStyle()
        .toolbarVisibility(.hidden, for: .tabBar)
        .alert("회원탈퇴", isPresented: $showDeleteConfirm) {
            Button("취소", role: .cancel) { }
            Button("탈퇴", role: .destructive) {
                Task {
                    isLoading = true
                    await viewModel.deleteAccount()
                    isLoading = false
                }
            }
        } message: {
            Text("정말 탈퇴하시겠습니까?\n탈퇴 시 모든 데이터가 삭제됩니다.")
        }
        .alert(item: $viewModel.deleteAccountAlert) { alert in
            Alert(title: Text(alert.title),
                  message: Text(alert.message),
                  dismissButton: .default(Text("확인")) {
                      if alert == .successDeleteAccount {
                          viewModel.sessionLogout()
                      }
                  })
        }
    }
}

// MARK: - 탈퇴 사유 Row
private struct ReasonRow: View {
    let reason: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(reason)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(isSelected ? .black : Color(.systemGray4))
                    .font(.title3)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray6), lineWidth: 1)
            )
        }
    }
}

#Preview {
    let mockAPIClient = APIClient(tokenStorage: TokenStorage())
    let mockAuthRepo = AuthRepository(apiClient: mockAPIClient)
    let mockAuthUseCase = AuthUseCase(repository: mockAuthRepo)
    let mockPrayerRepo = PrayerRepository(apiClient: mockAPIClient)
    let mockPrayerUseCase = PrayerUseCase(repository: mockPrayerRepo)

    NavigationStack {
        DeleteAccountView(
            viewModel: MyPageViewModel(authUseCase: mockAuthUseCase,
                                       prayerUseCase: mockPrayerUseCase,
                                       userSession: UserSession())
        )
    }
}
