//
//  MainViewModel.swift
//  McWebViewApp
//
//  Created by DarkAngel on 12/2/25.
//

import Foundation
import Combine
import McWebview



class MainViewModel: ObservableObject {
    var webViewModel: McWebViewModel = McWebViewModel()
    private var url: String = "http://192.168.0.215:3000"
    
    init() {}
    
    deinit {}
    
    public func loadUrl() {
        
        self.webViewModel.setOnReceivedError(onReceivedError: onError)
        
        self.webViewModel.setPlugins(plugins:[McCommonPlugin()])
        self.webViewModel.loadUrl(url:self.url)
    }
    
    public func releaseWebView() {
        self.webViewModel.release()
    }
    
    
    let onError : onReceivedError = { view, error in
        print("kkak : 에러발생!!!")
    }
}
