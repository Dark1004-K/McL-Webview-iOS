//
//  McWebFunction.swift
//  McWebviewFramework
//
//  Created by DarkAngel on 9/16/25.
//

open class McWebFunction {
    var name: String
    var function: (String, [String: Any?]?) -> (Void)
    
    public init(name: String, using function: @escaping (String, [String: Any?]?) -> (Void)) {
        self.name = name
        self.function = function
    }
    
    public func exec(callbackId: String, param: [String: Any?]? = nil) {
        self.function(callbackId, param)
    }
    
}
