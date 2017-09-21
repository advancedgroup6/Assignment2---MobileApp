//
//  ReadMessageViewController.swift
//  MessageMe
//
//  Created by Rumit Singh Tuteja on 9/17/17.
//  Copyright © 2017 Rumit Singh Tuteja. All rights reserved.
//

import UIKit
import Alamofire

class ReadMessageViewController: UIViewController {
    var objMessage:Message!
    @IBOutlet weak var btnReplyAction: UIBarButtonItem!

    
    @IBOutlet weak var txtViewMessage: UITextView!
   
    @IBOutlet weak var txtFieldRegion: UITextField!
    @IBOutlet weak var txtFieldFrom: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        additionalUISetup()
        populateUI()
        // Do any additional setup after loading the view.
    }

    private func populateUI(){
        txtFieldRegion.text = objMessage?.strRegionName
        txtFieldFrom.text = objMessage?.strSenderName
        txtViewMessage.text = objMessage?.strContent
    }
    
    private func additionalUISetup(){
        txtFieldFrom.leftViewMode = .always
        txtFieldFrom.leftView = Common.label(withText: "From: ")
        txtFieldRegion.leftViewMode = .always
        txtFieldRegion.leftView = Common.label(withText: "Region: ")
    }
    
    @IBAction func btnDeleteMessageAction(_ sender: Any) {
        deleteMessage()
        // service to delete message
        // pop view controller on completion handler.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func deleteMessage(){
        Alamofire.request(
            URL(string: "http://18.220.138.212:8080/deleteMsg/"+objMessage.strMessageID)!,
            method: .get,
            parameters: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess, let dict = response.result.value as? [String:Any?] else {
                    print("Error while fetching remote rooms: \(response.result.error)")
                    return
                }
                if let status = dict["status"] as? String{
                    if status == "200" {
                        self.navigationController?.popViewController(animated: true)
                        // alert to say message successfully deleted
                    }
                }
                print(response)
        }
        
    }
    
    // mark read service
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let composeMessageVC = segue.destination as! ComposeMessageViewController
        composeMessageVC.objMessage = self.objMessage
    }
 

}
