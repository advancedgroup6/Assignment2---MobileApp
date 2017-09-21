//
//  User.swift
//  SampleFullStack
//
//  Created by Rumit Singh Tuteja on 8/31/17.
//  Copyright © 2017 Rumit Singh Tuteja. All rights reserved.
//

import UIKit

class User: NSObject {
    var strName:String?
    var strEmailID:String?
    var strAddress:String?
    var strPhoneNo:String?
    var strPassword:String?
    var strSessionToken:String?
  
    
    func loadParams(params:[String:Any]){
        strName = params["name"] as? String ?? ""
        strEmailID = params["emailID"] as? String ?? ""
        strAddress = params["address"] as? String ?? ""
        strPhoneNo = params["phoneNo"] as? String ?? ""
        strPassword = params["password"] as? String ?? ""

    }
    init(params:[String:Any], withToken strToken:String){
        super.init()
        loadParams(params: params)
        strSessionToken = strToken
    }
    
    init(withParams params:[String:Any]){
        super.init()
        loadParams(params: params)
    }
}
