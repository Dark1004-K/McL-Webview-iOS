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
    
    public func makeCoordinator() -> McWebviewCoordinator {
        McWebviewCoordinator($model) // $model은 Binding<McWebViewModel> 타입입니다.
    }

    public func makeUIView(context: Context) -> McWebView {
        let webView = McWebView()
        self.model.webView = webView
        self.model.webView?.receivedError = self.model.receivedError
        return webView
    }
    
    public func updateUIView(_ webView: McWebView, context: UIViewRepresentableContext<McWebviewRepresentable>){}
    
    public static func dismantleUIView(_ uiView: McWebView, coordinator: McWebviewCoordinator) {
        uiView.release()
        coordinator.releaseWebView()
    }
}


// Coordinator 정의
public final class McWebviewCoordinator {
    // @Binding 대신, Coordinator는 보통 Representable 뷰 자체에 대한 참조를 갖거나
    // 필요하다면 @Binding을 직접 캡처할 수 있습니다.
    // 여기서는 부모 Representable의 @Binding model을 캡처하는 것으로 가정합니다.
    var model: Binding<McWebViewModel>

    init(_ model: Binding<McWebViewModel>) {
        self.model = model
    }

    // 이 메서드를 통해 dismantleUIView에서 호출하여 model을 안전하게 초기화합니다.
    func releaseWebView() {
        // 이 시점에서 바인딩을 통해 model의 webView를 nil로 설정합니다.
        // Coordinator는 Binding<McWebViewModel>을 가지고 있기 때문에 수정이 가능합니다.
        self.model.wrappedValue.webView = nil
    }
}
