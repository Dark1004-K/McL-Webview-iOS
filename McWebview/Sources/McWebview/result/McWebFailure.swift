//
//  McWebFailure.swift
//  McWebviewFramework
//
//  Created by DarkAngel on 9/16/25.
//

open class McWebFailure: McWebParam {
    var message: String?
    public init(message: String?) {
        self.message = message
    }
    
    public func toDictionary() -> [String : Any?]? {
        return ["message": self.message]
    }
}

