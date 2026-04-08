//
//  BlockListViewModel.swift
//  FaithConnect
//

import Foundation

@MainActor
class BlockListViewModel: ObservableObject {
    @Published var blockedUsers: [BlockedUser] = []
    @Published var alertType: AlertType? = nil
    @Published var isLoading: Bool = false

    private let prayerUseCase: PrayerUseCaseProtocol
    private var currentPage = 0
    private var hasNext = true

    init(prayerUseCase: PrayerUseCaseProtocol) {
        self.prayerUseCase = prayerUseCase
    }

    func loadInitial() async {
        currentPage = 0
        hasNext = true
        blockedUsers = []
        await loadMore()
    }

    func loadMore() async {
        guard hasNext, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let page = try await prayerUseCase.loadBlockList(page: currentPage + 1)
            blockedUsers.append(contentsOf: page.blockedUsers)
            currentPage = page.currentPage
            hasNext = page.hasNext
        } catch {
            alertType = .error(title: "불러오기 실패", message: error.localizedDescription)
        }
    }

    func unblock(user: BlockedUser) async {
        do {
            try await prayerUseCase.unblockUser(userId: user.userId)
            blockedUsers.removeAll { $0.id == user.id }
        } catch {
            alertType = .error(title: "차단 해제 실패", message: error.localizedDescription)
        }
    }
}
