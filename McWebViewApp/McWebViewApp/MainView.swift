//
//  ContentView.swift
//  McWebViewApp
//
//  Created by DarkAngel on 9/17/25.
//

import SwiftUI
import McWebview
import Combine


final class WebViewModel: ObservableObject {
    var objectWillChange = ObservableObjectPublisher()
    
    // 💡 McWebView 인스턴스를 클래스 프로퍼티로 선언
    @Published var webView: McWebView?
    
    init() {}
    
    deinit {}
    
    
    func onError(_ view: McWebView?,  _ error: Error?) -> Void {
        print("kkak : 에러발생!!!")
    }

}


struct MainView: View {
    @StateObject private var viewModel = WebViewModel()
    @State private var url: String = "http://192.168.0.42:3000"
    @State private var plugins: [McWebPlugin] = []
    
    init() {
        
    }
    
    var body: some View {
        VStack {
            McWebviewRepresentable(webView:$viewModel.webView, onReceivedError: viewModel.onError)
                .onAppear {
                    self.plugins.append(McCommonPlugin())
                    self.plugins.forEach { plugin in
                        viewModel.webView?.addPlugin(plugin: plugin)
                    }
                    viewModel.webView?.loadUrl(self.url)
                }
                .onDisappear() {
                    self.plugins.removeAll()
                }
        }
        .padding()
        
    }

}

#Preview {
    MainView()
}
