//
//  McWebRequest.swift
//  McWebviewFramework
//
//  Created by DarkAngel on 9/2/25.
//

import Foundation

public enum McWebResponseStatus: String {
    case success = "success"
    case failure = "failure"
}

open class McWebRequest
{
    var status: McWebResponseStatus
    var callbackId: String
    var param: McWebParam?
    
    init (status: McWebResponseStatus, callbackId: String, param: McWebParam?) {
        self.status = status
        self.callbackId = callbackId
        self.param = param
    }
}
