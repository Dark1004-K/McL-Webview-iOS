//
//  McPropertyResultModel.swift
//  McWebview
//
//  Created by 류정하 on 9/25/25.
//

class McPropertyResultModel: McWebParam {
    private var key:String
    private var value:String?
    
    init(key: String, value: String?) {
        self.key = key
        self.value = value
    }
    
    func toDictionary() -> [String: Any?]? {
        return ["key":self.key, "value":self.value]
    }
}
