//
//  McCommonPlugin.swift
//  McWebviewFramework
//
//  Created by DarkAngel on 9/16/25.
//

import McWebAnnotation
import Foundation

@McWebPlugin(name:"McCommonPlugin")
open class McCommonPlugin : McWebPlugin {
//    init은 자동으로 재정의 되니 절대 여기서 정의 하면 안됌!!!
//    public init() {}
    
    public var pluginDelegate: McCommonPluginDelegate?
//    public static let COMMONPLUGIN_PREF_KEY = "mc_common_preference"
    
    
    override public func release() {
        McKeyChain.release()
        super.release()
    }
    
    @McWebMethod(name: "closeApp")
    func closeApp(callbackId: String) { // I/F 네이밍 변경
//        DispatchQueue.main.async {
            self.pluginDelegate?.closeApp()
//        }
        super.sendResult(status: .success, callbackId: callbackId, param: nil)
    }
    
    @McWebMethod(name:"loadUrl")
    func loadUrl(callbackId: String, url: String) {
        super.webView?.loadUrl(url)
        super.sendResult(status: .success, callbackId: callbackId, param: nil)
    }
    
    @McWebMethod(name:"loadUrlForBrowser")
    func loadUrlForBrowser(callbackId: String, url: String) {
        guard let lUrl = URL(string: url) else {
            super.sendResult(status: .failure, callbackId: callbackId, param: McWebFailure(message: "URL 변환 실패"))
            return
        }
        self.pluginDelegate?.onLoadBrowser(url: lUrl)
        super.sendResult(status: .success, callbackId: callbackId, param: nil)
    }
    
    @McWebMethod(name:"getProperty")
    func getProperty(callbackId: String, key: String) {
        McKeyChain.initialization()
//        McKeyChain.initialization(appId: McCommonPlugin.COMMONPLUGIN_PREF_KEY)
        let value = McKeyChain.getInstance().getString(key: key)
        super.sendResult(status: .success, callbackId: callbackId, param: McPropertyResultModel(key: key, value: value))
    }
//    
    @McWebMethod(name:"setProperty")
    func setProperty(callbackId: String, key: String, value:String) {
        McKeyChain.initialization()
//        McKeyChain.initialization(appId: McCommonPlugin.COMMONPLUGIN_PREF_KEY)
        McKeyChain.getInstance().putString(value: value, key: key)
        super.sendResult(status: .success, callbackId: callbackId, param: nil)
    }
    
    
    
    
    //MARK: - Macro 인자 테스트 용
//    @McWebMethod(name:"receiveObj")
//    func receiveObj(callbackId: String, obj: [String: Any]?) {
//        print("receiveObj  >> \(obj)")
//        super.sendResult(status: .success, callbackId: callbackId, param: nil)
//    }
//    
//    @McWebMethod(name:"receive")
//    func receive(callbackId: String, ok: Bool) {
//        print("receive  >> \(ok)")
//        super.sendResult(status: .success, callbackId: callbackId, param: nil)
//    }
//    
//    @McWebMethod(name:"receiveInt")
//    func receiveInt(callbackId: String, int: Int) {
//        print("receiveInt  >> \(int)")
//        super.sendResult(status: .success, callbackId: callbackId, param: nil)
//    }
}

@MainActor
public protocol McCommonPluginDelegate {
    func closeApp() -> Void
    func onLoadBrowser(url: URL) -> Void
}
