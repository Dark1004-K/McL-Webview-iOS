//
//  McWebViewModel.swift
//  McL-McWebview
//
//  Created by DarkAngel on 12/1/25.
//

import Foundation

public class McWebViewModel: ObservableObject {
    @Published var webView: McWebView?
    var receivedError: onReceivedError? = nil
    
    public init() {}
    
    public func setOnReceivedError(onReceivedError: @escaping onReceivedError) {
        self.receivedError = onReceivedError
    }
    
    public func loadUrl(url:String?) {
        guard let url else { return }
        self.webView?.loadUrl(url)
    }
    
    public func setPlugins(plugins: [McWebPlugin]) {
        plugins.forEach { plugin in
            self.webView?.addPlugin(plugin: plugin)
        }
    }
    
    @MainActor
    public func setSchemes(schemes: [McScheme]) {
        schemes.forEach { scheme in
            self.webView?.addScheme(scheme: scheme)
        }
    }
    
    public func release() {
        self.webView?.release()
    }
}
