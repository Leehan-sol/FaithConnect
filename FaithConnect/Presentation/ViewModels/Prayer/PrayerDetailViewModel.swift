//
//  PrayerDetailViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

@MainActor
class PrayerDetailViewModel: ObservableObject {
    @Published var prayer: Prayer?
    @Published var alertType: AlertType? = nil
    @Published var isDeleted = false
    @Published var replyingTo: PrayerResponse? // 대상 댓글
    @Published var editingReply: PrayerResponse? // 수정 대상 대댓글
    @Published var replyText: String = "" 

    var hasReplyContent: Bool {
        !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private let prayerUseCase: PrayerUseCaseProtocol
    private let prayerRequestId: Int
    private var hasInitialized = false
    private var replyPages: [Int: Int] = [:]       // [responseId: currentPage]
    private var replyHasNext: [Int: Bool] = [:]    // [responseId: hasNext]
    private var replyLoading: Set<Int> = []        // 로딩 중인 responseId
    private var replyExpanded: Set<Int> = []       // 더보기 누른 responseId

    init(prayerUseCase: PrayerUseCaseProtocol, prayerRequestId: Int) {
        self.prayerUseCase = prayerUseCase
        self.prayerRequestId = prayerRequestId
    }
    
    func initializeIfNeeded() async {
        guard !hasInitialized else { return }
        hasInitialized = true
        await loadPrayerDetail()
    }
    
    func refresh() async {
        replyPages.removeAll()
        replyHasNext.removeAll()
        replyLoading.removeAll()
        replyExpanded.removeAll()
        await loadPrayerDetail()
    }
    
    
    private func loadPrayerDetail() async {
        do {
            let prayer = try await prayerUseCase.loadPrayerDetail(prayerRequestID: prayerRequestId)
            self.prayer = prayer
            self.isDeleted = prayer.createdAt.isEmpty
            Task { await loadInitialReplies() }
        } catch {
            alertType = .error(title: "불러오기 실패",
                               message: error.localizedDescription)
        }
    }

    private func loadInitialReplies() async {
        guard let responses = prayer?.responses else { return }
        for response in responses where response.replyCount > 0 {
            await loadReplies(for: response.id)
        }
    }
    
    func makePrayerEditorVM() -> PrayerEditorViewModel {
        PrayerEditorViewModel(prayerUseCase: prayerUseCase, prayer: prayer)
    }
    
    func deletePrayer() async -> Bool {
        do {
            print("삭제 API 호출")
            guard let id = prayer?.id else { return false }
            try await prayerUseCase.deletePrayer(prayerRequestId: id)
            return true
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "삭제 실패",
                               message: error)
            return false
        }
    }
    
    func writePrayerResponse(message: String) async -> Bool {
        if message.isEmpty {
            alertType = .fieldEmpty(fieldName: "응답")
            return false
        }
        
        guard let id = prayer?.id else {
            return false
        }
        
        do {
            print("기도 응답 API 호출")
            let response = try await prayerUseCase.writePrayerResponse(prayerRequestID: id,
                                                                      message: message,
                                                                      prayerTitle: prayer?.title ?? "",
                                                                      categoryId: prayer?.categoryId ?? 0,
                                                                      categoryName: prayer?.categoryName ?? "")
            guard var prayer = prayer else { return false }
            prayer.responses?.append(response)
            prayer.participationCount += 1
            self.prayer = prayer
            return true
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "응답 작성 실패",
                               message: error)
            return false
        }
    }
    
    func updatePrayerResponse(responseID: Int, message: String) async -> Bool {
        do {
            print("응답 수정 API 호출")
            let updatedResponse = try await prayerUseCase.updatePrayerResponse(responseID: responseID,
                                                                               message: message)

            guard var prayer = prayer else { return false }
            if let index = prayer.responses?.firstIndex(where: { $0.id == responseID }) {
                let existingReplies = prayer.responses?[index].replies ?? []
                let existingReplyCount = prayer.responses?[index].replyCount ?? 0
                prayer.responses?[index] = updatedResponse
                prayer.responses?[index].replies = existingReplies
                prayer.responses?[index].replyCount = existingReplyCount
            }
            self.prayer = prayer
            return true
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "수정 실패",
                               message: error)
            return false
        }
    }

    func reportPrayer(reasonType: ReportReasonType, reasonDetail: String?) async -> Bool {
        guard let id = prayer?.id else { return false }
        do {
            try await prayerUseCase.reportPrayer(prayerRequestId: id, reasonType: reasonType, reasonDetail: reasonDetail)
            return true
        } catch {
            alertType = .error(title: "신고 실패", message: error.localizedDescription)
            return false
        }
    }

    func reportPrayerResponse(prayerResponseId: Int, reasonType: ReportReasonType, reasonDetail: String?) async -> Bool {
        do {
            try await prayerUseCase.reportPrayerResponse(prayerResponseId: prayerResponseId, reasonType: reasonType, reasonDetail: reasonDetail)
            return true
        } catch {
            alertType = .error(title: "신고 실패", message: error.localizedDescription)
            return false
        }
    }

    func deletePrayerResponse(response: PrayerResponse) async {
        do {
            print("응답 삭제 API 호출")
            try await prayerUseCase.deletePrayerResponse(responseID: response.id, 
                                                         prayerRequestId: response.prayerRequestId)
            
            guard var prayer = prayer else { return }
            prayer.responses?.removeAll { $0.id == response.id }
            prayer.participationCount -= 1
            self.prayer = prayer
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "삭제 실패",
                               message: error)
        }
    }
    
    func deleteReply(_ reply: PrayerResponse, from parentResponse: PrayerResponse) async {
        do {
            try await prayerUseCase.deletePrayerResponse(responseID: reply.id,
                                                         prayerRequestId: reply.prayerRequestId)
            guard var prayer = prayer,
                  let index = prayer.responses?.firstIndex(where: { $0.id == parentResponse.id }) else { return }
            prayer.responses?[index].replies.removeAll { $0.id == reply.id }
            prayer.responses?[index].replyCount -= 1
            prayer.participationCount -= 1
            self.prayer = prayer
        } catch {
            alertType = .error(title: "삭제 실패", message: error.localizedDescription)
        }
    }

    func reportPrayer(reasonType: ReportReasonType, reasonDetail: String?) async -> Bool {
        guard let id = prayer?.id else { return false }
        do {
            try await prayerUseCase.reportPrayer(prayerRequestId: id, reasonType: reasonType, reasonDetail: reasonDetail)
            alertType = .success(title: "신고 완료",
                                 message: "신고가 접수되었습니다. \n검토 후 조치하겠습니다.")
            return true
        } catch {
            alertType = .error(title: "신고 실패",
                               message: ErrorContext.report.message(for: error))
            return false
        }
    }

    func reportPrayerResponse(prayerResponseId: Int, reasonType: ReportReasonType, reasonDetail: String?) async -> Bool {
        do {
            try await prayerUseCase.reportPrayerResponse(prayerResponseId: prayerResponseId,
                                                         reasonType: reasonType,
                                                         reasonDetail: reasonDetail)
            alertType = .success(title: "신고 완료",
                                 message: "신고가 접수되었습니다. \n검토 후 조치하겠습니다.")
            return true
        } catch {
            alertType = .error(title: "신고 실패",
                               message: ErrorContext.report.message(for: error))
            return false
        }
    }

    func blockPrayerUser(userId: Int) async -> Bool {
        do {
            try await prayerUseCase.blockUser(userId: userId)
            return true
        } catch {
            alertType = .error(title: "차단 실패",
                               message: ErrorContext.block.message(for: error))
            return false
        }
    }

    func blockCommentUser(response: PrayerResponse) async {
        do {
            try await prayerUseCase.blockUser(userId: response.userId)
            await refresh()
            alertType = .success(title: "차단 완료",
                                 message: "해당 사용자가 차단되었습니다.")
        } catch {
            alertType = .error(title: "차단 실패",
                               message: ErrorContext.block.message(for: error))
        }
    }

    func blockReplyUser(reply: PrayerResponse, from parentResponse: PrayerResponse) async {
        do {
            try await prayerUseCase.blockUser(userId: reply.userId)
            await refresh()
            alertType = .success(title: "차단 완료",
                                 message: "해당 사용자가 차단되었습니다.")
        } catch {
            alertType = .error(title: "차단 실패",
                               message: ErrorContext.block.message(for: error))
        }
    }

    // MARK: - 대댓글 조회
    func isRepliesLoaded(for responseId: Int) -> Bool {
        replyPages[responseId] != nil
    }

    func hasMoreReplies(for responseId: Int) -> Bool {
        replyHasNext[responseId] ?? false
    }

    func isReplyExpanded(for responseId: Int) -> Bool {
        replyExpanded.contains(responseId)
    }

    func expandReplies(for responseId: Int) async {
        replyExpanded.insert(responseId)
        await loadReplies(for: responseId)
    }

    func loadReplies(for responseId: Int) async {
        guard !replyLoading.contains(responseId) else { return }
        replyLoading.insert(responseId)

        let page = (replyPages[responseId] ?? 0) + 1
        do {
            let result = try await prayerUseCase.loadReplies(responseId: responseId, page: page)
            guard var prayer = prayer,
                  let index = prayer.responses?.firstIndex(where: { $0.id == responseId }) else { return }

            prayer.responses?[index].replies.append(contentsOf: result.replies)
            replyPages[responseId] = result.currentPage
            replyHasNext[responseId] = result.hasNext
            self.prayer = prayer
        } catch {
            print("답글 불러오기 실패 (responseId: \(responseId)): \(error.localizedDescription)")
        }

        replyLoading.remove(responseId)
    }

    // MARK: - 대댓글 작성
    func startReply(to response: PrayerResponse) {
        replyingTo = response
    }

    func startEditReply(_ reply: PrayerResponse, in response: PrayerResponse) {
        editingReply = reply
        replyingTo = response
        replyText = reply.message
    }

    func cancelReply() {
        replyText = ""
        replyingTo = nil
        editingReply = nil
    }

    func sendReply() async -> Int? {
        guard let parentResponse = replyingTo else { return nil }
        let message = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return nil }

        do {
            let reply = try await prayerUseCase.writeReply(responseId: parentResponse.id, message: message)
            guard var prayer = prayer,
                  let index = prayer.responses?.firstIndex(where: { $0.id == parentResponse.id }) else { return nil }
            prayer.responses?[index].replies.append(reply)
            prayer.responses?[index].replyCount += 1
            prayer.participationCount += 1
            self.prayer = prayer
            let replyId = reply.id
            cancelReply()
            return replyId
        } catch {
            alertType = .error(title: "답글 작성 실패", message: error.localizedDescription)
            return nil
        }
    }
    
    func sendEditedReply() async -> Int? {
        guard let reply = editingReply, let parentResponse = replyingTo else { return nil }
        let message = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return nil }

        do {
            let updatedResponse = try await prayerUseCase.updatePrayerResponse(responseID: reply.id, message: message)
            guard var prayer = prayer,
                  let parentIndex = prayer.responses?.firstIndex(where: { $0.id == parentResponse.id }),
                  let replyIndex = prayer.responses?[parentIndex].replies.firstIndex(where: { $0.id == reply.id })
            else { return nil }

            prayer.responses?[parentIndex].replies[replyIndex] = updatedResponse
            self.prayer = prayer
            let editedId = reply.id
            cancelReply()
            return editedId
        } catch {
            alertType = .error(title: "수정 실패", message: error.localizedDescription)
            return nil
        }
    }
}
