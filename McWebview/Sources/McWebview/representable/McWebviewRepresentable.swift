//
//  mcwebview.swift
//  mcwebview
//
//  Created by DarkAngel on 8/28/25.
//
import SwiftUI
import WebKit

public struct McWebviewRepresentable: UIViewRepresentable {
    @Binding var webView: McWebView?
    public init(webView: Binding<McWebView?>) {
        self._webView = webView
    }

    public func makeUIView(context: Context) -> McWebView {
        
        let webView = McWebView()
        self.webView = webView
        return webView
    }
    
    public func updateUIView(_ webView: McWebView, context: UIViewRepresentableContext<McWebviewRepresentable>) {}
    
    public static func dismantleUIView(_ uiView: McWebView, coordinator: Coordinator) {
        uiView.release()
    }
}
