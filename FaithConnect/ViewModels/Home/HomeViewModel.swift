//
//  HomeViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

class HomeViewModel: ObservableObject {
    let apiService: APIServiceProtocol
    @Published var categories: [PrayerCategory] = []
    @Published var prayers: [Prayer] = []
    @Published var currentPage: Int = 1
    @Published var hasNext: Bool = true
    @Published var isLoading: Bool = false
    
    init(_ apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    // TODO: -
    // 1. 카테고리 목록 조회 v
    // 2. 카테고리별 기도 목록 조회
    
    func loadCategories() async {
        do {
            let loadCategory = try await apiService.loadCategories()
            await MainActor.run {
                categories = loadCategory
                print(categories)
            }
        } catch {
            print("Error loading categories: \(error)")
        }
    }
    
    func loadPrayers(selectedCategory: Int, reset: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            // 초기 로드면 1페이지부터, 아니면 현재 페이지
            let pageToLoad = reset ? 1 : currentPage
            let response = try await apiService.loadPrayers(selectedCategory: selectedCategory, page: pageToLoad)
            
            await MainActor.run {
                if reset {
                    prayers = response.prayerRequests
                } else {
                    prayers.append(contentsOf: response.prayerRequests)
                }
                
                // 서버에서 내려준 페이징 정보 갱신
                currentPage = response.currentPage + 1
                hasNext = response.hasNext
            }
        } catch {
            print("Error loading prayers: \(error)")
        }
        
        isLoading = false
    }
    
    // 스크롤 끝에 도달 시 다음 페이지 로드
    func loadMoreIfNeeded(currentItem: Prayer, selectedCategory: Int) async {
        guard hasNext, let last = prayers.last, currentItem.id == last.id else { return }
        await loadPrayers(selectedCategory: selectedCategory, reset: false)
    }
    
}
