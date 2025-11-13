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
    @Binding var url: String
    @Binding var plugins: [McWebPlugin]
    public init(webView:Binding<McWebView>, url:Binding<String>, plugins:Binding<[McWebPlugin]>) {
//        print("edsfmslkfjseljfsl")
        self._url = url
        self._webView = webView
        self._plugins = plugins
        McKeyChain.initialization()
//        McKeyChain.initialization(appId: McCommonPlugin.COMMONPLUGIN_PREF_KEY)
    }
    
    public func makeUIView(context: Context) -> McWebView {
        guard let url = URL(string: url) else { return self.webView }
//        let webView = McWebView()
//        DispatchQueue.main.async {
//            self.webView = webView
//        }
        for plugin in self.plugins {
            self.webView.addPlugin(plugin:plugin)
        }
        self.webView.load(URLRequest(url: url))
        return self.webView
    }
    
    public func updateUIView(_ webView: McWebView, context: UIViewRepresentableContext<McWebviewRepresentable>) {
        guard let url = URL(string: self.url) else { return }
        self.webView.load(URLRequest(url: url))
    }
}
