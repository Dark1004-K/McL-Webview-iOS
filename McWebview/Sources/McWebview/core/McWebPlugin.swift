//
//  McWebPlugin.swift
//  McWebviewFramework
//
//  Created by DarkAngel on 9/2/25.
//

import Foundation
import WebKit

@MainActor
open class McWebPlugin {
    public weak var webView: McWebView?
    public var name: String
    public var functions: [String: McWebFunction] = [:]
    
    public init(name: String) {
        self.name = name
    }
    
    public func release() {
        functions.removeAll()
        self.webView = nil
    }
    
    public func sendResult(status :McWebResponseStatus, callbackId :String, param: McWebParam?) {
        var callfunc = "success"
        let empty = McStringUtil.base64Encoded("{}")
        if status == .failure { callfunc = "failure" }
        if let jsonParam = param?.toDictionary() {
            if  let data = try? JSONSerialization.data(withJSONObject: jsonParam, options:[]), let str = String(data: data, encoding: .utf8), let encoding = McStringUtil.base64Encoded(str) {
                webView?.evaluateJavaScript("\(String(describing: name))Result.\(callfunc)(\(callbackId), '\(encoding)')", completionHandler: nil)
            } else {
//                print("Return Value Error")
                webView?.evaluateJavaScript("\(String(describing: name))Result.failure(\(callbackId), '\(empty!)')", completionHandler: nil)
            }
        } else {
            webView?.evaluateJavaScript("\(String(describing: name))Result.\(callfunc)(\(callbackId), '\(empty!)')", completionHandler: nil)
        }
    }
    
    func sendResult(request :McWebRequest) {
        sendResult(status: request.status, callbackId: request.callbackId, param: request.param)
    }
    
    public func messageHandlers(message: WKScriptMessage?) {
        guard let msg = message else { return }
        
        guard let str = msg.body as? String, let body = str.data(using: .utf8) else { return }
        guard let dictionary = try? JSONSerialization.jsonObject(with: body, options: []) as? [String:Any?], let funcName = dictionary["funcName"] as? String else { return }

        guard let callbackId = dictionary["callbackId"] as? String else {
            sendResult(status: .failure, callbackId: "-1", param: McWebFailure(message: "콜백 아이디 오류"))
            return
        }
        guard let paramStr = McStringUtil.base64Decoded(dictionary["param"] as? String)?.data(using: .utf8) else {
            sendResult(status: .failure, callbackId: callbackId, param: McWebFailure(message: "파라메터 디코딩 오류"))
            return
        }
        
        let param = try? JSONSerialization.jsonObject(with: paramStr, options: []) as? [String:Any?]
        self.callScript(funcName: funcName, param: param, callbackId: callbackId)
    }
    
    func callScript(funcName: String, param: [String:Any?]?, callbackId: String) {
        guard let function = self.functions[funcName] else {
            sendResult(status: .failure, callbackId: callbackId, param: McWebFailure(message: "\(funcName) 함수를 찾을 수 없음"))
            return
        }
        
        function.exec(callbackId: callbackId, param:param)
    }
}
