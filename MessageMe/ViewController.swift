//
//  ViewController.swift
//  SampleFullStack
//
//  Created by Rumit Singh Tuteja on 8/30/17.
//  Copyright © 2017 Rumit Singh Tuteja. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtFieldConfirmPassword: UITextField!
    @IBOutlet weak var txtFieldName: UITextField!
    
    @IBOutlet weak var txtFieldPhoneNo: UITextField!
    @IBOutlet weak var txtFieldEmailID: UITextField!
    @IBOutlet weak var txtFieldAddress: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        additionalUISetup()
        checkForSessionInfo()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        txtFieldPassword.text = ""
        txtFieldEmailID.text = ""
        txtFieldPhoneNo.text = ""
        txtFieldName.text = ""
        txtFieldAddress.text = ""
    }
    
    func additionalUISetup(){
        txtFieldName.becomeFirstResponder()
    }   

    func checkForSessionInfo(){
        let userDefaults = UserDefaults.standard
        if let dictData = userDefaults.value(forKey: "sessionDetails") as? [String: Any]{
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let meessagesVC = storyboard.instantiateViewController(withIdentifier: "inboxVC") as! MessagesTableViewController
            let objUser = User(params: dictData["userDetails"] as? [String : Any] ?? [:], withToken:dictData["token"] as! String)
            Common.inSessionUser = objUser
            self.navigationController?.pushViewController(meessagesVC, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func validFields() -> Bool{
        if txtFieldName.text?.characters.count == 0 || txtFieldEmailID.text?.characters.count == 0 || txtFieldAddress.text?.characters.count == 0 || txtFieldPhoneNo.text?.characters.count == 0 || txtFieldPassword.text?.characters.count == 0 {
            return false
        }
        
        if txtFieldPassword.text != txtFieldConfirmPassword.text{
            Common.displayAlert(message: "Password and confirm password fields do not match", onViewController: self)
            return false
        }
        return true
    }
    
    @IBAction func btnSubmitAction(_ sender: Any) {
//        let dict = ["username":txtFieldName.text, "description": txtFIeldDescription.text, "emailid":txtFieldEmailID.text]
        if validFields(){
            let dict = ["name":txtFieldName.text!,
                        "emailID":txtFieldEmailID.text!,
                        "phoneNo":txtFieldPhoneNo.text!,
                        "address" :txtFieldAddress.text!,
                        "password":txtFieldPassword.text!]
            sendSignupRequest(dictParams: dict)
        }else{
            displayAlert(message: "Please enter valid details.")
        }
    }
    
    func prepareSessionForUser(jsonString:[String:Any]){
        let defaults = UserDefaults.standard
        defaults.set(jsonString, forKey: "sessionInfo")
    }
    
    func displayAlert(message:String){
        let myAlert = UIAlertController(title:"Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title:"OK", style:UIAlertActionStyle.default, handler:nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func sendSignupRequest(dictParams:[String:String]){
        if let urlString = URL(string: Services.wsBaseURL + Services.wsSignUP){
            var request = URLRequest(url: urlString)
            let jsonData = try? JSONSerialization.data(withJSONObject: dictParams, options: .prettyPrinted)
            if let json = jsonData {
                request.httpMethod = "POST"
                request.httpBody = json
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                let session = URLSession.shared
                let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "Error getting data")
                        self.displayAlert(message: "Couldnt signup, please try again.")

                    }else{
                        if data != nil {
                            if let jsonString = try? JSONSerialization.jsonObject(with: data!, options:    []) as! [String:Any] {
                                let status = jsonString["status"] as! String
                                if status == "200" {
                                    print(jsonString)
                                    let objUser = User(params: jsonString["userDetails"] as? [String : Any] ?? [:], withToken:jsonString["token"] as! String)
                                    let storyboard = UIStoryboard(name: "Main", bundle:nil)
                                    let messagesVC = storyboard.instantiateViewController(withIdentifier: "inboxVC") as! MessagesTableViewController
                                    Common.inSessionUser = objUser
                                    self.prepareSessionForUser(jsonString: jsonString)
                                    DispatchQueue.main.async {
                                        self.navigationController?.pushViewController(messagesVC, animated: true)
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.displayAlert(message: "Signup failed. Please try again later.")
                                }
                                print("no printable data")
                            }
                        }
                    }
                })
                task.resume()
            }
        }
        
        

        
        //        do {
//        }catch let error {
//            print(error.localizedDescription)
//        }
    }
}

