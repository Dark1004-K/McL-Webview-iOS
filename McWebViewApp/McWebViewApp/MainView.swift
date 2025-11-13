//
//  ContentView.swift
//  McWebViewApp
//
//  Created by DarkAngel on 9/17/25.
//

import SwiftUI
import McWebview

struct MainView: View {
    private var webView: McWebView? = McWebView()
    @State private var url: String = "http://192.168.0.42:3000"
    @State private var plugins: [McWebPlugin] = [McCommonPlugin()]
    var body: some View {
        VStack {
            if let webView {
                McWebviewRepresentable(webView: .constant(webView), url: $url, plugins: $plugins)
            } else {
                ProgressView()
            }
        }
        .padding()
    }
}

#Preview {
    MainView()
}
