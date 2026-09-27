//
//  SignUpChurchSearchView.swift
//  FaithConnect
//

import SwiftUI

struct SignUpChurchSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var results: [Church] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("교회를 검색해 선택해주세요")
                        .font(.headline)
                    Text("소속 교회를 선택하면 해당 교회의 기도 공동체에 참여할 수 있습니다.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("교회명 검색", text: $query)
                        .autocapitalization(.none)
                        .onChange(of: query) { _ in
                            // TODO: 교회 검색 API 연동
                            searchChurches()
                        }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 16)

                List(results) { church in
                    NavigationLink {
                        if church.isManna {
                            CommunitySelectionView(church: church)
                        } else {
                            SignUpFormView(church: church, community: nil)
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(church.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                if church.isManna {
                                    Text("MANNA")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.orange.opacity(0.15))
                                        .foregroundColor(.orange)
                                        .clipShape(Capsule())
                                }
                            }
                            Text(church.roadAddress)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
                .overlay {
                    if query.isEmpty {
                        Text("교회명을 입력하면 결과가 표시됩니다.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    } else if results.isEmpty {
                        Text("검색 결과가 없습니다.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("회원가입")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }

    private func searchChurches() {
        // TODO: 실제 API 연동 시 교체
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else {
            results = []
            return
        }
        // 임시 Mock 데이터
        let mockChurches: [Church] = [
            Church(id: "8239253", name: "만나교회", roadAddress: "경기 성남시 분당구 양현로 353", isManna: true),
            Church(id: "1000001", name: "만나교회", roadAddress: "서울 강남구 테헤란로 1", isManna: false),
            Church(id: "1000002", name: "사랑의교회", roadAddress: "서울 서초구 반포대로 121", isManna: false),
            Church(id: "1000003", name: "온누리교회", roadAddress: "서울 용산구 이촌로 347", isManna: false),
            Church(id: "1000004", name: "높은뜻교회", roadAddress: "서울 강북구 삼양로 1", isManna: false),
        ]
        results = mockChurches.filter { $0.name.contains(q) || $0.roadAddress.contains(q) }
    }
}
