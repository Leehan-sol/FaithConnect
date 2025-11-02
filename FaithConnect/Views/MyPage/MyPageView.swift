//
//  MyPageView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct MyPageView: View {
    @StateObject var viewModel = MyPageViewModel()
    
    var body: some View {
        Text("MyPageView")
    }
}

#Preview {
    MyPageView()
}
