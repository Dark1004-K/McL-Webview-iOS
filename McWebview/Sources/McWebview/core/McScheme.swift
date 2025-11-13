//
//  McScheme.swift
//  McL-McWebview
//
//  Created by 류정하 on 11/12/25.
//

import Foundation



open class McScheme {
    var name: String
    var action: (_ webview: McWebView, _ url: URL) -> (Bool)
    
    public init(name: String, action: @escaping (_ webview: McWebView, _ url: URL) -> Bool) {
        self.name = name
        self.action = action
    }
}
