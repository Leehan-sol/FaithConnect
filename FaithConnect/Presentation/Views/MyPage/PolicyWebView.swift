//
//  PolicyWebView.swift
//  FaithConnect
//
//  Created by Apple on 12/30/25.
//

import SwiftUI
import WebKit

enum PolicyType {
    case terms
    case privacy
    
    var title: String {
        switch self {
        case .terms:
            return "이용약관"
        case .privacy:
            return "개인정보 처리방침"
        }
    }
    
    var htmlFileName: String {
        switch self {
        case .terms:
            return "terms"
        case .privacy:
            return "privacy"
        }
    }
}

struct LocalHTMLView: UIViewRepresentable {
    
    let fileName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "html") {
            uiView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }
    
}


struct PolicyWebView: View {
    let viewType: PolicyType
    
    var body: some View {
        LocalHTMLView(fileName: viewType.htmlFileName)
            .id(viewType)
            .navigationTitle(viewType.title)
            .navigationBarTitleDisplayMode(.inline)
            .customBackButtonStyle()
    }
    
}
