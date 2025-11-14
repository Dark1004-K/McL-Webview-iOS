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
        print("Create WebView!!!!!! id:", ObjectIdentifier(self as AnyObject))
        
    }
    
    public convenience init() {
        self.init(frame:.zero, configuration:WKWebViewConfiguration())
        print("Create WebView!!!!!! convenience id:", ObjectIdentifier(self as AnyObject))
    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        print("Create WebView!!!!!! frame id:", ObjectIdentifier(self as AnyObject))
        self.loadDefaultConfig()
    }
    
    public func release() {
        self.stopLoading()
        for plugin in plugins.values
        {
            self.configuration.userContentController.removeScriptMessageHandler(forName: plugin.name)
        }
        print("release id:", ObjectIdentifier(self as AnyObject))
//        MwKeyChain.release()
    }

    private func loadConfig(){
        self.uiDelegate = self
        self.navigationDelegate = self
        print("loadConfig id:", ObjectIdentifier(self as AnyObject))
        
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
    
    public func loadUrl(_ url:String) {
        guard let url = URL(string: url) else { return }
        self.load(URLRequest(url: url))
    }
    
    public func addPlugin(plugin: McWebPlugin)
    {
        plugin.webView = self
        self.plugins[plugin.name] = plugin
        self.configuration.userContentController.add(self, name: plugin.name)
    }
    
    public func addScheme(scheme: McScheme) {
        self.schemes[scheme.name] = scheme
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
    
    public func loadUrl(url:String) {
        if let url = URL(string: url) {
            self.load(URLRequest(url : url))
        }
    }
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
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo) async -> String? {
        print("MwWebKit : runJavaScriptTextInputPanelWithPrompt")
        return defaultText
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async -> Bool {
        print("McWebView confirm: \(message)")
        return true
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async {
        print("McWebView alert: \(message)")
    }
}


extension McWebView : WKNavigationDelegate  {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let requestUrl = navigationAction.request.url else {
            print("[McWebView] No URL in navigationAction. Cancelling.")
            return .cancel
        }
        if let schemeName = requestUrl.scheme, let handler = self.schemes[schemeName] {
            print("[McWebView] Handling custom scheme: \(schemeName) -> \(requestUrl)")
            if handler.action(self, requestUrl) {
                return .cancel
            }
        }
        
        return .allow
    }
    
    @available(iOS 9.0, *)
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
       //receivedError
        
        print("errrr95952r952r2r92r95r29r25rror")
        
        guard let lReceiverError = self.receivedError else {return}
        if ((lReceiverError(webView, error)) != nil) { return }
    }
}

