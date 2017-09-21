//
//  Beacon.swift
//  MessageMe
//
//  Created by Rumit Singh Tuteja on 9/17/17.
//  Copyright © 2017 Rumit Singh Tuteja. All rights reserved.
//

import UIKit

class Beacon: NSObject {
    var strBeaconID:String!
    var strMajor:String?
    var strMinor:String?
    var strMajorMinor:String!
    var strRegionName:String!
    var proximity:CLProximity
    init(params:[String:Any]){
        proximity = .far
        super.init()
        strBeaconID = params["_id"] as? String ?? ""
        strRegionName = params["category"] as? String ?? ""
        strMajorMinor = params["majorminor"] as? String ?? ""
    }
    
    init(beacon:CLBeacon){
        proximity = beacon.proximity
        super.init()
        strBeaconID = String(describing: beacon.proximityUUID)
        strMajorMinor = String(describing: beacon.major) + String(describing: beacon.minor)
    }
}
