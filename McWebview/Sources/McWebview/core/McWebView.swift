//
//  McWebview.swift
//  McWebviewFramework
//
//  Created by DarkAngel on 9/2/25.
//

import UIKit
import WebKit

open class McWebView : WKWebView
{
    var plugins: [String:McWebPlugin] = [:]
    var schemes: [String:McScheme] = [:]
    
    var receivedError: ((_ view: WKWebView?,  _ error: Error?) -> Bool)? = nil
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadDefaultConfig()
    }
    
    public convenience init() {
        self.init(frame:.zero, configuration:WKWebViewConfiguration())
    }
    
//    required init?() {
//        super.init()
//    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.loadDefaultConfig()
    }
    
    public func release() {
        self.stopLoading()
        for plugin in plugins.values
        {
            self.configuration.userContentController.removeScriptMessageHandler(forName: plugin.name)
        }
//        MwKeyChain.release()
    }

    private func loadConfig(){
        self.uiDelegate = self
        self.navigationDelegate = self
        
        //화면 비율 맞춤 설정
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // 여백 및 배경 부분 색 투명하게 변경
//        self.backgroundColor = UIColor.white
//        self.isOpaque = false
//        self.loadHTMLString("<body style=\"background-color: transparent\">", baseURL: nil)
        self.configuration.preferences.minimumFontSize = 0
        self.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        self.configuration.suppressesIncrementalRendering = false
        self.configuration.selectionGranularity = .dynamic
        self.configuration.allowsInlineMediaPlayback = false
        self.configuration.allowsAirPlayForMediaPlayback = false
        self.configuration.allowsPictureInPictureMediaPlayback = true
        self.configuration.websiteDataStore = .default()
        self.configuration.mediaTypesRequiringUserActionForPlayback = .all
        self.scrollView.contentInsetAdjustmentBehavior = .never
        
        if #available(iOS 14.0, *) {
            configuration.limitsNavigationsToAppBoundDomains = true
            let preferences = WKWebpagePreferences()
            preferences.allowsContentJavaScript = true

            self.configuration.defaultWebpagePreferences = preferences
        } else {
            self.configuration.preferences.javaScriptEnabled = true
        }
        
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        let os = ProcessInfo().operatingSystemVersion
        let osVersion = String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
        evaluateJavaScript("navigator.userAgent", completionHandler: { (result, error) in
            if let agent = result as? String {
                let newAgent = "\(agent);McWebView;Mcl(os:iOS, versionCode:\(buildNumber), versionName:\(appVersion), osVersion:\(osVersion));"
                self.customUserAgent = newAgent
            }
        })
    }
    
    
    public func loadDefaultConfig() {
        loadConfig()
        self.clearCache(cache:true, cookie:false)
        
        if #available(iOS 16.4, *) {
#if DEBUG
            self.isInspectable = true
#endif
        }
    }
    
//    public func onBackPressed() {
//        if(self.subWebview != nil) {
//            if(self.subWebview?.webInfo?.type == "Issuer") {
//                evaluateJavaScript("MwNativeApi.onBackPressed()", completionHandler: { (result, error) in })
//            }
//            let _ = self.closeSubWebview()
//        } else if(self.govPrintWebview != nil) {
//            let _ = self.closeGovDocsPrintWebview()
//            evaluateJavaScript("MwNativeApi.onBackPressed()", completionHandler: { (result, error) in })
//        } else {
//            evaluateJavaScript("MwNativeApi.onBackPressed()", completionHandler: { (result, error) in })
//            guard let plugin = findPlugIn(plugInName: "SpMyDataPlugin") as? MwMyDataPlugIn else { return }
//            if let callbackId = plugin.getBackCallbackId() {
//                sendResult(responseType: .success, callbackId: callbackId, param: nil)
//            } else {
//                historyBack()
//            }
//        }
//    }
//        
//    public func onClosePressed() {
//        if(self.subWebview != nil) {
//            if(self.subWebview?.webInfo?.type == "Issuer") {
//                guard let vc = self.topOfPageViewController() else {
//                    return
//                }
//                
//                let popup = MwPopUpBuilder()
//                    .setTitle(title: "신분증명 발급 중단")
//                    .setMessage(message: "신분증명 발급을 중단하시겠습니까?")
//                    .setLeftButton(text: "발급중단",action: alertAction())
//                    .setRightButton(text: "취소",action: nil)
//                    .build()
//                self.mwPopup = popup
//                vc.view.addSubview(popup)
//                popup.frame = vc.view.bounds
//
//            } else {
//                let _ = self.closeSubWebview()
//                guard let plugin = findPlugIn(plugInName: "SpCommonPlugin") as? MwCommonPlugIn else { return }
//                plugin.restoreTitle()
//            }
//        } else if (self.govPrintWebview != nil) {
////            print("closePressed!!!!!!!!!!!!!!!!!!!!!!!!!!!! ")
//            let _ = self.closeGovDocsPrintWebview()
//            evaluateJavaScript("MwNativeApi.onClosePressed()", completionHandler: { (result, error) in })
//        } else {
//            guard let plugin = findPlugIn(plugInName: "SpCommonPlugin") as? MwCommonPlugIn else { return }
//            if (plugin.isClose ?? true) {
//                plugin.closeWebview()
//            }
//            evaluateJavaScript("MwNativeApi.onClosePressed()", completionHandler: { (result, error) in })
//        }
//    }
    
    public func addPlugin(plugin: McWebPlugin)
    {
//        print("Add plugIn : " + plugIn.getPlugInName())
        plugin.webView = self
        self.plugins[plugin.name] = plugin
//        plugIn.initFunction()
        self.configuration.userContentController.add(self, name: plugin.name)
    }
//    
//    public func addPlugIns(plugIns: [MwPlugIn])
//    {
//        for plugIn in plugIns {
//            addPlugIn(plugIn: plugIn)
//        }
//    }
    
    public func addScheme(scheme: McScheme) {
        print("addScheme!!!!!!!!!!!!!!!!!!!")
        self.schemes[scheme.name] = scheme
        print("scheme: ",scheme)
        print("self.schemes: ",self.schemes)
    }
    
    public func clearCache(cache:Bool,cookie:Bool) {
        var dataType = NSSet()
        let date = NSDate(timeIntervalSince1970: 0)
        
        if (cache && !cookie) {
            dataType = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
            self.configuration.websiteDataStore.removeData(ofTypes:dataType as! Set, modifiedSince: date as Date, completionHandler:{});
        } else if (!cache && cookie) {
            dataType = NSSet(array: [WKWebsiteDataTypeCookies])
            self.configuration.websiteDataStore.removeData(ofTypes:dataType as! Set, modifiedSince: date as Date, completionHandler:{});
        } else if (cache && cookie) {
            dataType = NSSet(array:[WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeCookies])
            self.configuration.websiteDataStore.removeData(ofTypes:dataType as! Set, modifiedSince: date as Date, completionHandler:{});
        }
        
    }
        
    
//    public func loadPost(url: String?, param:[UInt8]) {
//        guard let urlObj = URL(string : url ?? "") else { return }
//        var urlRequest = URLRequest(url: urlObj)
//        urlRequest.httpMethod = "POST"
//        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        let data = NSData(bytes: param, length: param.count)
//        urlRequest.httpBody = Data(referencing: data)
//        self.load(urlRequest)
//    }
    
    
    
    public func loadUrl(url:String) {
        if let url = URL(string: url) {
            self.load(URLRequest(url : url))
        }
    }
    
//    public func initKeyChain() {
//        McKeyChain.initialization(appId: COMMONPLUGIN_PREF_KEY)
//    }

}

extension McWebView :WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        print("plug-in Calls : \(message.name)")
        guard let plugin = plugins[message.name] else { return }
        plugin.messageHandlers(message: message)
    }
}

class LeakAvoider : NSObject, WKScriptMessageHandler {
    weak var delegate : WKScriptMessageHandler?
    init(delegate:WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}

extension McWebView : WKUIDelegate {
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        print("MwWebKit : runJavaScriptTextInputPanelWithPrompt")
        completionHandler(nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        print("McWebView alert: \(message)")
        completionHandler()
    }
}

extension McWebView : WKNavigationDelegate  {
    public func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("requesㅇㄴ후딘순다ㅣ쉰다쉰ㄷ")
        guard let urlString = navigationAction.request.url?.absoluteString, let requestUrl = URL(string: urlString) else {
             decisionHandler(.cancel)
            return
        }
        print("requestUrl: ",requestUrl)
        let scheme = requestUrl.scheme ?? ""
        print("sdmgklsejfgeslksghesgset")
        print("self.schemes: ",self.schemes)
        if let handler = self.schemes[scheme] {
            print("sdmgklsejfgeslkt")
            handler.action(self, requestUrl)
            decisionHandler(.cancel)
        }
        
        
        if (urlString.hasPrefix("https://itunes.apple.com")) {
            UIApplication.shared.open(requestUrl, completionHandler: { (success) in
                print("Itunes opened: \(success)") // Prints true
            })
            decisionHandler(.cancel)
            return
            
        } else if (urlString.hasPrefix("tauthlink")
            || urlString.hasPrefix("ktauthexternalcall")
            || urlString.hasPrefix("upluscorporation")
            || urlString.hasPrefix("niceipin2")) {
            UIApplication.shared.open(requestUrl, completionHandler: { (success) in
                print("Pass opened: \(success)") // Prints true
            })
            
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
        return
    }
    
    @available(iOS 9.0, *)
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
       //receivedError
        
        guard let lReceiverError = self.receivedError else {return}
        if ((lReceiverError(webView, error)) != nil) { return }
    }
}
