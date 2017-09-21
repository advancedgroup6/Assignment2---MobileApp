//
//  ComposeMessageViewController.swift
//  MessageMe
//
//  Created by Rumit Singh Tuteja on 9/17/17.
//  Copyright © 2017 Rumit Singh Tuteja. All rights reserved.
//

import UIKit
import Alamofire

class ComposeMessageViewController: UIViewController,  UITextViewDelegate, UITextFieldDelegate{
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var txtFieldSendTo: UITextField!
    @IBOutlet weak var txtFieldRegion: UITextField!
    @IBOutlet weak var txtViewMessage: UITextView!
    var receiverName:String? = nil
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    var objMessage:Message?{
        willSet{
            if newValue?.strRegionName != nil && newValue?.strSenderName != nil {
                self.receiverName = newValue?.strSenderName
                self.perform(#selector(prepareUIForReply), with: nil, afterDelay: 0.1)
            }
        }
    }
    var arrRegions:[Beacon]! = []
    var arrUsers:[User]! = []
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"RegionUpdates"), object:["message":objMessage])
        additionalUISetup()
        fetchAllUsers()
        fetchAllRegions()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

    @IBAction func btnSendMessageAction(_ sender: Any) {
        if validMessage(){
            postMessageToServer()
        }
    }
    
    func btnRegionPickerHandler(_ btn:Any){
        // action sheet to pick region
        self.view.endEditing(true)
        presentRegionPickerActionSheet()
    }
    @IBAction func btnSendAction(_ sender: Any) {
        if validMessage() {
            postMessageToServer()
        }
    }
    
    func btnSendToPickerHadler(_ btn:Any){
        // action sheet to pick contact
        self.view.endEditing(true)
        presentNamesPickerActionSheet()
    }
    
    @IBAction func btnReadyAction(_ sender: Any) {
        self.view.endEditing(true)
    }
    private func additionalUISetup(){
        txtFieldSendTo.leftViewMode = .always
        txtFieldSendTo.leftView = Common.label(withText: "To:")
        txtFieldSendTo.rightViewMode = .always
        txtFieldSendTo.rightView = Common.button(withImage: UIImage(named:"ic_action_person"), withActionHandler: #selector(btnSendToPickerHadler), target: self)
        txtFieldRegion.leftViewMode = .always
        txtFieldRegion.leftView = Common.label(withText: "Region:")
        txtFieldRegion.rightViewMode = .always
        txtFieldRegion.rightView = Common.button(withImage: UIImage(named:"location"), withActionHandler: #selector(btnRegionPickerHandler), target: self)
        txtViewMessage.becomeFirstResponder()
    }

    func prepareUIForReply(){
        self.txtFieldRegion.isUserInteractionEnabled = false
        self.txtFieldSendTo.isUserInteractionEnabled = false
        txtFieldSendTo.text = objMessage?.strSenderName
        txtFieldRegion.text = objMessage?.strRegionName
        txtViewMessage.becomeFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.objMessage?.strContent = textView.text
    }
   
    
    private func presentRegionPickerActionSheet(){
        let actionSheet = UIAlertController(title:"Select Region", message:nil, preferredStyle:.actionSheet)
        for beacon in arrRegions {
            actionSheet.addAction(UIAlertAction(title:beacon.strRegionName, style:.default) { action in
                if self.objMessage == nil {
                    self.objMessage = Message()
                }
                self.objMessage!.strMajor = beacon.strMajor
                self.objMessage!.strMinor = beacon.strMinor
                self.objMessage?.strMajorMinor = beacon.strMajorMinor
                self.objMessage?.strRegionName = beacon.strRegionName
                self.txtFieldRegion.text = self.objMessage?.strRegionName
            })
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.contentInset.bottom = 255
        textView.scrollIndicatorInsets.bottom = 255
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.contentInset.bottom = 0
        textView.scrollIndicatorInsets.bottom = 0
        self.objMessage?.strContent = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        self.bottomSpaceConstraint.constant = 8
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.view.layoutIfNeeded() ?? ()
        })
    }
    
    
    private func presentNamesPickerActionSheet(){
        let actionSheet = UIAlertController(title:"Select Receiver", message:nil, preferredStyle:.actionSheet)
        for user in arrUsers {
            actionSheet.addAction(UIAlertAction(title:user.strEmailID, style:.default) { action in
                if self.objMessage == nil {
                    self.objMessage = Message()
                }
                self.objMessage?.strTo = action.title
                self.txtFieldSendTo.text = self.objMessage?.strTo
            })
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func fetchAllRegions(){
        Alamofire.request(
            URL(string: "http://18.220.138.212:8080/getAllRegions")!,
            method: .get,
            parameters: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess, let dict = response.result.value as? [String:Any?] else {
                    print("Error while fetching remote rooms: \(response.result.error)")
                    return
                }
                
                if let status = dict["status"] as? String, let arrRegionsList = dict["regionList"] as? [[String:Any]]{
                    if status == "200" {
                        print(arrRegionsList)
                        for dictRegion in arrRegionsList {
                            let region = Beacon(params:dictRegion)
                            self.arrRegions.append(region)
                        }
                    }
                }
//                guard let value = response.result.value as? [String: Any],
//                    let rows = value["rows"] as? [[String: Any]] else {
//                        print("Malformed data received from fetchAllRooms service")
//                        return
//                }
                

        }
        
    }
    
    
    private func fetchAllUsers(){
        Alamofire.request(
            URL(string: "http://18.220.138.212:8080/getAllUsers")!,
            method: .get,
            parameters: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess, let dict = response.result.value as? [String:Any?] else {
                    print("Error while fetching remote rooms: \(response.result.error)")
                    return
                }
                if let status = dict["status"] as? String, let arrUsersList = dict["usersList"] as? [[String:Any?]] {
                    if status == "200" {
                        for dictUser in arrUsersList {
                            let user = User(withParams:dictUser)
                            self.arrUsers.append(user)
                            print(self.arrUsers)
                        }
                    }
                }
                
//                guard let value = response.result.value as? [String: Any],
//                    let rows = value["rows"] as? [[String: Any]] else {
//                        print("Malformed data received from fetchAllRooms service")
//                        return
//                }
                print(response)
        }
        
    }
    
    private func validMessage() -> Bool {
        if objMessage?.strMajorMinor.characters.count != 0 && objMessage?.strSenderName?.characters.count != 0 && objMessage?.strContent?.characters.count != 0{
            return true
        }
        return false
    }
    
    private func postMessageToServer(){

        let params = ["sender":Common.inSessionUser!.strName!, "receiver":self.receiverName != nil ? self.receiverName : objMessage?.strTo, "msg":objMessage!.strContent!, "majorminor":objMessage!.strMajorMinor!] as [String : Any]
        
        Alamofire.request(
            URL(string: "http://18.220.138.212:8080/sendMsg")!,
            method: .post,
            parameters: params)
            .validate(contentType: ["application/json"])
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess, let dict = response.result.value as? [String:Any?] else {
                    // invoke alert message here.
                    print("Error while posting message: \(response.result.error)")
                    return
                }
                if let status = dict["status"] as? String {
                    if status == "200" {
                        // present message post success alert
                        self.navigationController?.popViewController(animated: true)
                    }
                }
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
