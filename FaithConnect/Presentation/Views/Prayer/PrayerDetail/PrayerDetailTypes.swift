//
//  PrayerDetailTypes.swift
//  FaithConnect
//
//  Created by Apple on 3/23/26.
//

// MARK: - PrayerBottomSheetType
// 응답 작성/수정
enum PrayerBottomSheetType: Identifiable {
    case create
    case edit(PrayerResponse)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let r): return "edit-\(r.id)"
        }
    }

    var editingResponse: PrayerResponse? {
        switch self {
        case .create: return nil
        case .edit(let response): return response
        }
    }
}


// MARK: - ConfirmAlertType
// 삭제/신고/차단 확인 알림 타입 (target: 기도, 응답, 답글)
enum ConfirmAlertType: Identifiable {
    case delete(target: String)
    case report(target: String)
    case block

    var id: String {
        switch self {
        case .delete: return "delete"
        case .report: return "report"
        case .block: return "block"
        }
    }

    var title: String {
        switch self {
        case .delete: return "삭제"
        case .report: return "신고"
        case .block: return "차단"
        }
    }

    var message: String {
        switch self {
        case .delete(let target):
            return "이 \(target)을(를) 삭제하시겠습니까?\n삭제된 내용은 복구할 수 없습니다."
        case .report(let target):
            return "이 \(target)을(를) 신고하시겠습니까?"
        case .block:
            return "이 사용자를 차단하시겠습니까?\n차단된 사용자의 글은 더 이상 표시되지 않습니다."
        }
    }
}
