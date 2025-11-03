//
//  McStringUtil.swift
//  McWebviewFramework
//
//  Created by DarkAngel on 9/2/25.
//

import Foundation
import UIKit

open class McStringUtil {
    public static func base64Encoded(_ source: String) -> String? {
        if let data = source.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }

    public static func base64Decoded(_ source: String?) -> String? {
        guard let src = source else { return nil }
        if let data = Data.init(base64Encoded: src, options: .init(rawValue: 0))
        {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    public static func localized(_ source: String, bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(source, tableName: tableName, value: "\(source)", comment: "")
    }
    
    public static func applyKern(source: String?, _ amount :CGFloat = -0.12) -> NSMutableAttributedString? {
        guard let str = source else { return nil }
        let attr = NSMutableAttributedString.init(string: str)
        attr.addAttribute(.kern, value: amount, range: NSRange.init(location: 0, length: attr.length))
        return attr
    }
    
    public static func urlParamToJson(url:URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else { return nil }

        var items: [String: String] = [:]
        for queryItem in queryItems {
            items[queryItem.name] = queryItem.value
        }
        
        guard let obj = try? JSONSerialization.data(withJSONObject: items as Any,options: []) else { return nil }
        guard let result = String(data: obj, encoding: .utf8) else { return nil }
        return result
    }
    
    
    public static func hexToData(_ src: String?) -> Data? {
        guard let source = src else { return nil }
        // 문자열 길이가 짝수인지 확인 (각 바이트는 2개의 16진수 문자로 표현됨)
        guard source.count % 2 == 0 else {
            return nil
        }
        
        var data = Data(capacity: source.count / 2)
        var index = source.startIndex
        
        // 2문자씩(1바이트) 반복 처리
        while index < source.endIndex {
            let nextIndex = source.index(index, offsetBy: 2)
            let byteString = source[index..<nextIndex]
            
            // Scanner를 사용하여 16진수 문자열을 UInt8(바이트) 값으로 변환
            let scanner = Scanner(string: String(byteString))
            var byte: UInt64 = 0
            
            // scanHexInt64를 사용하여 16진수 스캔
            if scanner.scanHexInt64(&byte) {
                // 성공적으로 스캔되면 Data에 추가
                data.append(UInt8(byte))
            } else {
                // 유효하지 않은 16진수 문자열이 포함된 경우 변환 실패
                return nil
            }
            
            index = nextIndex
        }
        
        // 데이터가 성공적으로 변환되었는지 확인하고 반환
        return data
    }
    
}

 
