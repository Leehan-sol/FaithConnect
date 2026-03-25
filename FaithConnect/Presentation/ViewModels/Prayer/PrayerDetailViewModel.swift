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
        await loadPrayerDetail()
    }
    
    
    private func loadPrayerDetail() async {
        do {
            let prayer = try await prayerUseCase.loadPrayerDetail(prayerRequestID: prayerRequestId)
            self.prayer = prayer
            self.isDeleted = prayer.createdAt.isEmpty
        } catch {
            alertType = .error(title: "불러오기 실패",
                               message: error.localizedDescription)
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
                prayer.responses?[index] = updatedResponse
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
    
    func reportWriter() {
        // TODO: - UseCase 로직 구현
        alertType = .success(title: "신고 완료", message: "신고가 접수되었습니다. \n검토 후 조치하겠습니다.")
    }
    
    func blockWriter() {
        // TODO: - UseCase 로직 구현
        alertType = .success(title: "차단 완료", message: "해당 사용자가 차단되었습니다.")
    }

    // MARK: - 대댓글
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

    func sendReply() -> Int? {
        guard let parentResponse = replyingTo else { return nil }
        let message = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return nil }

        addMockReply(to: parentResponse, message: message)
        let lastReplyId = prayer?.responses?
            .first(where: { $0.id == parentResponse.id })?.replies.last?.id
        cancelReply()
        return lastReplyId
    }
    
    func sendEditedReply() -> Int? {
        guard let reply = editingReply, let parentResponse = replyingTo else { return nil }
        let message = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return nil }

        updateMockReply(reply, in: parentResponse, message: message)
        let editedId = reply.id
        cancelReply()
        return editedId
    }

    // TODO: 테스트용 답글 추가
    private func addMockReply(to parentResponse: PrayerResponse, message: String) {
        guard var prayer = prayer,
              let index = prayer.responses?.firstIndex(where: { $0.id == parentResponse.id }) else { return }

        let mockReply = PrayerResponse(
            id: Int.random(in: 10000...99999),
            prayerRequestId: parentResponse.prayerRequestId,
            message: message,
            createdAt: {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                return formatter.string(from: Date())
            }(),
            isMine: true
        )
        prayer.responses?[index].replies.append(mockReply)
        self.prayer = prayer
    }

    // TODO: 테스트용 답글 수정
    private func updateMockReply(_ reply: PrayerResponse, in parentResponse: PrayerResponse, message: String) {
        guard var prayer = prayer,
              let parentIndex = prayer.responses?.firstIndex(where: { $0.id == parentResponse.id }),
              let replyIndex = prayer.responses?[parentIndex].replies.firstIndex(where: { $0.id == reply.id })
        else { return }

        let updated = PrayerResponse(
            id: reply.id,
            prayerRequestId: reply.prayerRequestId,
            message: message,
            createdAt: reply.createdAt,
            isMine: reply.isMine
        )
        prayer.responses?[parentIndex].replies[replyIndex] = updated
        self.prayer = prayer
    }
}
