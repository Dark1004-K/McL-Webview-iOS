//
//  mcwebview.swift
//  mcwebview
//
//  Created by DarkAngel on 8/28/25.
//
import SwiftUI
import WebKit

public typealias onReceivedError = (_ view: McWebView?,  _ error: Error?) -> Void

public struct McWebviewRepresentable: UIViewRepresentable {
    @Binding var model: McWebViewModel
    
    public init(model: Binding<McWebViewModel>) {
        self._model = model
    }

    public func makeUIView(context: Context) -> McWebView {
        let webView = McWebView()
        self.model.webView = webView
        self.model.webView?.receivedError = self.model.receivedError
        return webView
    }
    
    public func updateUIView(_ webView: McWebView, context: UIViewRepresentableContext<McWebviewRepresentable>){}
    
    public static func dismantleUIView(_ uiView: McWebView, coordinator: Coordinator) {
        uiView.release()
    }
}
