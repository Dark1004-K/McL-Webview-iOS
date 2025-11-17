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
    
    init() {
        // ViewModel이 생성될 때 McWebView를 초기화할 수 있습니다.
//        self.webView = McWebView()
    }
    
    deinit {
        // ViewModel이 해제될 때 McWebView도 해제되도록 보조할 수 있습니다.
    }
    
    
    func onError(_ view: McWebView?,  _ error: Error?) -> Void {
        print("kkak : 에러발생!!!")
    }

}


struct MainView: View {
//    @State private var webView: McWebView
    @StateObject private var viewModel = WebViewModel()
    @State private var url: String = "http://192.168.0.42:3000"
    @State private var plugins: [McWebPlugin] = [McCommonPlugin()]
    
    var body: some View {
        VStack {
//                McWebviewRepresentable(webView: .constant(webView))
//             let webView {
            McWebviewRepresentable(webView:$viewModel.webView, onReceivedError: viewModel.onError)
                .onDisappear(){
//                    print("kkak : dis어피어!!!!")
//                    plugins.forEach { plugin in
//                        plugin.release()
//                    }
//                    plugins.removeAll()
                }
                .onAppear {
//                    viewModel.webView?.receivedError = viewModel.onError
                    self.plugins.forEach { plugin in
                        viewModel.webView?.addPlugin(plugin: plugin)
                    }
                    viewModel.webView?.loadUrl(self.url)
                }
           
//            .onDisappear() {
////                self.webView?.release()
//            }
        }
        .padding()
        
    }

}

#Preview {
    MainView()
}
