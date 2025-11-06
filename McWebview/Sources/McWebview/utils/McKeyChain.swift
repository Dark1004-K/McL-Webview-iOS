//
//  McKeychain.swift
//  McWebview
//
//  Created by 류정하 on 9/25/25.
//

import Foundation
import Security

@MainActor
open class McKeyChain {
    private static var instance : McKeyChain?
    private static let MCKEYCHAIN_PREF_KEY = "mc_keychain_preference"
    private static var name : String?
    public static func getInstance() -> McKeyChain {
        if instance == nil { instance = McKeyChain() }
        return instance!
    }
    
    public static func initialization() {
        McKeyChain.name = "mcl_shared_prefs_\(MCKEYCHAIN_PREF_KEY)"
    }
    
    private init() {
//        self.name = "mcl_shared_prefs_\(MCKEYCHAIN_PREF_KEY)"
//        print("McKeyChain initialized with name: \(self.name)")
    }
    
    public static func release() {
        self.instance = nil;
    }
    
    public func putString(value:String, key:String) {
        guard let data = value.data(using: .utf8) else { return }
        let query:[CFString: Any]=[kSecClass: kSecClassGenericPassword, kSecAttrService: McKeyChain.name!, kSecAttrAccount: key, kSecValueData: data]
        
        var obj : CFTypeRef?
        if (SecItemCopyMatching(query as CFDictionary, &obj) == errSecSuccess) {
            if SecItemUpdate(query as CFDictionary, [kSecValueData:data] as CFDictionary) == errSecSuccess {
//                print("[SecItemUpdate >> save() : Success: \(key)]")
            } else {
//                print("[SecItemUpdate >> save() : Fail : \(key)]")
            }
        } else {
            let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
            if status == errSecSuccess {
//                print("[SecItemAdd >> save() : Success : \(key)]")
            }
            else {
//                print("[SecItemAdd >> save() : Fail : \(key)]")
            }
        }
    }
    
    public func getString(key:String) -> String? {
        let query:[CFString: Any]=[kSecClass: kSecClassGenericPassword, kSecAttrService: McKeyChain.name!, kSecAttrAccount : key, kSecMatchLimit : kSecMatchLimitOne, kSecReturnData: true]
     
        // 키 체인에 저장된 값을 읽어옴
        var obj : CFTypeRef?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &obj)
        
        // 처리 결과가 성공인 경우 >> 키 체인에서 읽어온 값을 Data 타입으로 변환 >> 다시 String 타입으로 변환
        if status == errSecSuccess {
//            print("[Keychain >> load() : Success \(key)]")
            guard let data = obj as? Data else { return nil }
            let result = String(decoding: data, as: UTF8.self)
            return result
        } else {
//            print("[Keychain >> load() : Fail \(key)]")
        }
        return nil
    }
    
    public func getString(teamId: String, key:String) -> String? {
        let sKey = "\(teamId).\(key)"
        let query:[CFString: Any]=[
             kSecClass: kSecClassGenericPassword,
             
             // **********************************************
             // [수정] kSecAttrService 대신 kSecAttrGeneric 사용
             // KeychainItemWrapper의 Identifier는 kSecAttrGeneric에 저장됨
             // **********************************************
             kSecAttrGeneric: "Account Number",
             
             kSecAttrAccessGroup : sKey,
             
             // kSecAttrAccount는 KeychainItemWrapper가 쿼리에 사용하지 않으므로 제외
             
             kSecReturnData: kCFBooleanTrue,
             kSecMatchLimit: kSecMatchLimitOne
         ]
     
        // 키 체인에 저장된 값을 읽어옴
        var obj : CFTypeRef?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &obj)
        
        // 처리 결과가 성공인 경우 >> 키 체인에서 읽어온 값을 Data 타입으로 변환 >> 다시 String 타입으로 변환
        if status == errSecSuccess {
//            print("[Keychain >> load() : Success \(key)]")
            guard let data = obj as? Data else { return nil }
            let result = String(decoding: data, as: UTF8.self)
            return result
        } else {
//            print("[Keychain >> load() : Fail \(key)]")
        }
        return nil
    }
    
    
    public func putDictionary(value:[String:Any?], key:String)
    {
        guard let json = try? JSONSerialization.data(withJSONObject: value, options:[]) else { return }
        let query:[CFString: Any]=[kSecClass: kSecClassGenericPassword, kSecAttrService: McKeyChain.name!, kSecAttrAccount: key, kSecValueData: json]
        
        var obj : CFTypeRef?
        if (SecItemCopyMatching(query as CFDictionary, &obj) == errSecSuccess) {
            if SecItemUpdate(query as CFDictionary, [kSecValueData:json] as CFDictionary) == errSecSuccess {
//                print("[SecItemUpdate >> save() : Success: \(key)]")
            } else {
//                print("[SecItemUpdate >> save() : Fail : \(key)]")
            }
        } else {
            let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
            if status == errSecSuccess {
//                print("[SecItemAdd >> save() : Success : \(key)]")
            }
            else {
//                print("[SecItemAdd >> save() : Fail : \(key)]")
            }
        }
    }
    
    public func getDictionary(key:String) -> [String:Any?]?
    {
        let query:[CFString: Any]=[kSecClass: kSecClassGenericPassword, kSecAttrService: McKeyChain.name!, kSecAttrAccount : key, kSecMatchLimit : kSecMatchLimitOne, kSecReturnData: true]
     
        // 키 체인에 저장된 값을 읽어옴
        var obj : CFTypeRef?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &obj)
        
        // 처리 결과가 성공인 경우 >> 키 체인에서 읽어온 값을 Data 타입으로 변환 >> 다시 String 타입으로 변환
        if status == errSecSuccess {
//            print("[Keychain >> load() : Success \(key)]")
            guard let existingItem = obj as? Data else { return nil }
            guard let data = try? JSONSerialization.jsonObject(with: existingItem, options: []) else { return nil }
            return data as? [String:Any?]
            
        } else {
//            print("[Keychain >> load() : Fail \(key)]")
        }
        return nil
    }
}
