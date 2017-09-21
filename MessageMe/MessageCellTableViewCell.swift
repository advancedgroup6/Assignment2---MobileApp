//
//  MessageCellTableViewCell.swift
//  MessageMe
//
//  Created by Rumit Singh Tuteja on 9/17/17.
//  Copyright © 2017 Rumit Singh Tuteja. All rights reserved.
//

import UIKit

class MessageCellTableViewCell: UITableViewCell {
    static let cellReuseID = "messageCell"
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var btnUnlock: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgViewIsread: UIImageView!
    @IBOutlet weak var lblSender: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func getDateFromString(strDate:String!) -> String?{
        return nil
    }
    
    func dateFromString(strDate:String) -> String!{
//        let dateFormatter = DateFormatter()
//        //YYYY-MM-DD HH:MI:SS
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ" //Your date format
//        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
//        let date = dateFormatter.date(from: strDate) //according to date format your date string
//        print(date ?? "") //Convert String to Date
////        Date to String:
//        dateFormatter.dateFormat = "MMM d, yyyy" //Your New Date format as per requirement change it own
//        let newDate = dateFormatter.string(from: date!) //pass Date here
//        print(newDate) //New formatted Date string
//        return newDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        
        guard let date = dateFormatter.date(from: strDate) else {
            assert(false, "no date from string")
            return ""
        }
        dateFormatter.dateFormat = "dd/mm/yy HH:mm"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let timeStamp = dateFormatter.string(from: date)
        return timeStamp
    }
    
    func populateCellData(withMessage message:Message!){
        lblSender.text = message.strSenderName
        lblDate.text = dateFromString(strDate: message.strDate) ?? ""
        lblContent.text = message.strContent ?? ""
        imgViewIsread.image = message.isRead == true ? UIImage(named:"circle_grey") : UIImage(named: "circle_blue")
        btnUnlock.isSelected = !message.isLocked
    }

}
