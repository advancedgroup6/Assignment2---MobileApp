//
//  Common.swift
//  MessageMe
//
//  Created by Rumit Singh Tuteja on 9/17/17.
//  Copyright © 2017 Rumit Singh Tuteja. All rights reserved.
//

import Foundation
import UIKit

class Common:NSObject{
    
    static var inSessionUser:User?
    
    static func label(withText strText:String) -> UILabel{
        let label = UILabel();
        label.frame = CGRect(x:0,y:0,width:0.0,height:30)
        label.textAlignment = .left
        label.text = " " + strText + " "
        label.sizeToFit()
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.white
        return label
    }
    
    static func button(withImage img:UIImage!, withActionHandler handler:Selector, target:Any) -> UIButton {
        let btn = UIButton(type:.custom)
        btn.frame = CGRect(x:0, y:0, width:45, height:45)
        btn.addTarget(target, action: handler, for: .touchUpInside)
        btn.setImage(img, for: .normal)
        return btn
    }
    
    static func displayAlert(message:String, onViewController vc:UIViewController){
        var myAlert = UIAlertController(title:"Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title:"OK", style:UIAlertActionStyle.default, handler:nil)
        myAlert.addAction(okAction)
        vc.present(myAlert, animated: true, completion: nil)
        
    }
}
