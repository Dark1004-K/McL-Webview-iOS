//
//  ContentView.swift
//  McWebViewApp
//
//  Created by DarkAngel on 9/17/25.
//

import SwiftUI
import McWebview

struct MainView: View {
    @State var webView: McWebView = McWebView()
    @State var url: String = "http://192.168.0.42:3000"
    @State var plugins: [McWebPlugin] = [McCommonPlugin()]
    var body: some View {
        VStack {
            McWebviewRepresentable(webView:$webView, url: $url, plugins: $plugins)
        }
        .padding()
    }
}

#Preview {
    MainView()
}
