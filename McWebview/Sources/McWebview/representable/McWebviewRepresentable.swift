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
    var receiveError: ((_ view: McWebView?,  _ error: Error?) -> Void)? = nil
    public init(webView: Binding<McWebView?>, onReceivedError: ((_ view: McWebView?,  _ error: Error?) -> Void)? = nil) {
        self._webView = webView
        self.receiveError = onReceivedError
    }

    public func makeUIView(context: Context) -> McWebView {
        
        let webView = McWebView()
        webView.receivedError = self.receiveError
        self.webView = webView
        return webView
    }
    
    public func updateUIView(_ webView: McWebView, context: UIViewRepresentableContext<McWebviewRepresentable>) {}
    
    public static func dismantleUIView(_ uiView: McWebView, coordinator: Coordinator) {
        uiView.release()
    }
}
