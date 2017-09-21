//
//  Message.swift
//  MessageMe
//
//  Created by Rumit Singh Tuteja on 9/17/17.
//  Copyright © 2017 Rumit Singh Tuteja. All rights reserved.
//

import UIKit

class Message: NSObject {
    var strDate:String!
    var strMajorMinor:String!
    var strSenderName:String?
    var strSenderID:String!
    var strTo:String?
    var strContent:String?
    var strRegionName:String?
    var strMajor:String!
    var strMinor:String!
    var strMessageID:String!
    var isRead:Bool!
    var isLocked:Bool!
    
    override init(){
        super.init()
    }
    
    init(withParams params:[String:Any]){
        super.init()
        strMajorMinor = params["majorminor"] as? String ?? ""
        strDate = params["date"] as? String ?? ""
        strSenderName = params["sender"] as? String ?? ""
        strTo = params["receiver"] as? String ?? ""
        strContent = params["msg"] as? String ?? ""
        strRegionName = params["region"] as? String ?? ""
        isRead = params["isRead"] as? Bool ?? false
        isLocked = params["isLocked"] as? Bool ?? true
        strMessageID = params["_id"] as? String ?? ""
    }
}
