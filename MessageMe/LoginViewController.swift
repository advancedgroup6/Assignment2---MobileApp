//
//  LoginViewController.swift
//  SampleFullStack
//
//  Created by Rumit Singh Tuteja on 8/31/17.
//  Copyright © 2017 Rumit Singh Tuteja. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtFieldEmailID: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkForSessionInfo()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        additionalUISetup()
    }
    
    func additionalUISetup(){
        txtFieldEmailID.becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        txtFieldEmailID.text = ""
        txtFieldPassword.text = ""
    }
    
    func checkForSessionInfo(){
        let userDefaults = UserDefaults.standard
        if let dictData = userDefaults.value(forKey: "sessionInfo") as? [String: Any]{
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let profileVC = storyboard.instantiateViewController(withIdentifier: "inboxVC") as! MessagesTableViewController
            let objUser = User(params: dictData["userDetails"] as? [String : Any] ?? [:], withToken:dictData["token"] as! String)
            Common.inSessionUser = objUser
            self.navigationController?.pushViewController(profileVC, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func validFields() -> Bool{
        if self.txtFieldEmailID.text?.characters.count != 0 && self.txtFieldPassword.text?.characters.count != 0 {
            return true
        }
        displayAlert(message: "Please enter your credentials")
        return false
    }
    
   
    
    @IBAction func btnSubmitAction(_ sender: Any) {
        if validFields() {
            createSesisonWithDetails(params: ["emailID":txtFieldEmailID.text!,"password":txtFieldPassword.text!])
        }
    }
    
    func createSesisonWithDetails(params:[String:String]){
        if let urlString = URL(string: Services.wsBaseURL + Services.wsLogin){
            var request = URLRequest(url: urlString)
            let jsonData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            if let json = jsonData{
                request.httpBody = json
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                let session = URLSession.shared
                let task = session.dataTask(with:request, completionHandler: {(data, response, error)in
                    if error != nil {
                        print(error?.localizedDescription ?? "Error in login")
                        DispatchQueue.main.async {
                            self.displayAlert(message: "Authentication failure")
                        }
                    }else{
                        if data != nil {
                            if let jsonString = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]{
                                let status = jsonString["status"] as! String
                                if status == "200" {
                                    print(jsonString)
                                    let objUser = User(params: jsonString["userDetails"] as? [String : Any] ?? [:], withToken:jsonString["token"] as! String)
                                    Common.inSessionUser = objUser
                                    let storyboard = UIStoryboard(name: "Main", bundle:nil)
                                    let messagesVC = storyboard.instantiateViewController(withIdentifier: "inboxVC") as! MessagesTableViewController
                                    self.prepareSessionForUser(jsonString:jsonString)
                                    DispatchQueue.main.async {
                                        self.navigationController?.pushViewController(messagesVC, animated: true)
                                    }
                                }else{
                                    DispatchQueue.main.async {
                                        self.displayAlert(message: "Authentication failure")
                                    }
                                }
                            }
                        }
                    }
                })
                task.resume()
            }
        }
    }
    
    func displayAlert(message:String){
        let myAlert = UIAlertController(title:"Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title:"OK", style:UIAlertActionStyle.default, handler:nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func prepareSessionForUser(jsonString:[String:Any]){
        let defaults = UserDefaults.standard
        defaults.set(jsonString, forKey: "sessionInfo")
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
