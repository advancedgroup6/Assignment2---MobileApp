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
    
    func populateCellData(withMessage message:Message!){
        lblSender.text = message.strSenderName
        lblDate.text = message.strDate// getDateFromString(strDate: message.strDate) ?? ""
        lblContent.text = message.strContent ?? ""
        imgViewIsread.image = message.isRead == true ? UIImage(named:"circle_grey") : UIImage(named: "circle_blue")
        btnUnlock.isSelected = !message.isLocked
    }

}
