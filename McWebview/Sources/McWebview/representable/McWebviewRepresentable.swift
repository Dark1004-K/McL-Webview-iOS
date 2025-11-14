//
//  mcwebview.swift
//  mcwebview
//
//  Created by DarkAngel on 8/28/25.
//
import SwiftUI
import WebKit

public struct McWebviewRepresentable: UIViewRepresentable {
    @Binding var webView: McWebView
//    @Binding var url: String
//    @Binding var plugins: [McWebPlugin]
    public init(webView:Binding<McWebView>) {
//        self._url = url
        self._webView = webView
//        self._plugins = plugins
    }
    
    public func makeUIView(context: Context) -> McWebView {
//        guard let url = URL(string: url) else { return self.webView }
//        for plugin in self.plugins {
//            self.webView.addPlugin(plugin:plugin)
//        }
//        self.webView.load(URLRequest(url: url))
        return self.webView
    }
    
    public func updateUIView(_ webView: McWebView, context: UIViewRepresentableContext<McWebviewRepresentable>) {
//        guard let url = URL(string: self.url) else { return }
//        self.webView.load(URLRequest(url: url))
    }
}
