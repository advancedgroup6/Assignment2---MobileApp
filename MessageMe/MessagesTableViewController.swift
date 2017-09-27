//
//  MessagesTableViewController.swift
//  MessageMe
//
//  Created by Rumit Singh Tuteja on 9/17/17.
//  Copyright © 2017 Rumit Singh Tuteja. All rights reserved.
//

import UIKit
import Alamofire

class MessagesTableViewController: UITableViewController, ESTBeaconManagerDelegate {
    var refreshCounter = 0
    var dictMessages:[Message]! = []
    var arrRegions:[Beacon]! = []
    let beaconManager = ESTBeaconManager()
    let beaconRegion = CLBeaconRegion(
        proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
        identifier: "ranged region")
    func regionUpdatesReceived(_ notification:NSNotification){
    }
    @IBAction func btnLogoutActtion(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "sessionInfo")
        userDefaults.synchronize()
        self.navigationController?.popToRootViewController(animated: false)
    }

    override func viewDidLoad() {
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        NotificationCenter.default.addObserver(self, selector: #selector(regionUpdatesReceived), name:  NSNotification.Name(rawValue: "RegionUpdates"), object: nil)
        super.viewDidLoad()
        self.tableView.register(UINib(nibName:"MessageTableViewCell", bundle:nil), forCellReuseIdentifier: MessageCellTableViewCell.cellReuseID)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.tableView.estimatedRowHeight = 85.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.beaconManager.stopRangingBeacons(in: self.beaconRegion)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.beaconManager.startRangingBeacons(in: self.beaconRegion)
        super.viewWillAppear(animated)
        if !isMovingFromParentViewController {
            fetchAllMessages()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchAllMessages()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1// dictMessages.count
    }

    @IBAction func refreshMessagesAction(_ sender: Any) {
        fetchAllMessages()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.dictMessages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCellTableViewCell.cellReuseID, for: indexPath) as! MessageCellTableViewCell
        let objMessage = dictMessages[indexPath.row]
        cell.populateCellData(withMessage:objMessage)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = dictMessages[indexPath.row]
        if !message.isLocked {
            if (message.isRead)! {
                self.tableView.deselectRow(at: indexPath, animated: true)
                pushToRead(message:message)
            }else{
                markMessageRead(message: message, forIndexPath: indexPath)
            }
        }else{
            Common.displayAlert(message: "This message is locked, please move to the region and try again.", onViewController: self)
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    private func pushToRead(message:Message){
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        let readMessageVC = storyboard.instantiateViewController(withIdentifier: "readMessage") as! ReadMessageViewController
        readMessageVC.objMessage = message
        self.navigationController?.pushViewController(readMessageVC, animated: true)
    }
    
    private func markMessageRead(message:Message!, forIndexPath indexPath:IndexPath){
        Alamofire.request(
            URL(string: Services.wsBaseURL + Services.wsMarkMessageRead + "/`" +  message.strMessageID + "/" + Common.inSessionUser!.strSessionToken! + "/" + Common.inSessionUser!.strEmailID!)!,
            method: .get,
            parameters: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess, let dict = response.result.value as? [String:Any?] else {
                    print("Error while fetching remote rooms: \(response.result.error)")
                    return
                }
                if let status = dict["status"] as? String {
                    if status == "200" {
                        message.isRead = true
                        self.tableView.deselectRow(at: indexPath, animated: true)
                        self.pushToRead(message: message)
                    }else {
                    }
                }
        }
    }
   
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
     func fetchAllMessages(){
        let userID = Common.inSessionUser?.strEmailID
        Alamofire.request(
            URL(string: Services.wsBaseURL + "getMessages/" + userID! + "/" + Common.inSessionUser!.strSessionToken!)!,
            method: .get,
            parameters: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess, let dict = response.result.value as? [String:Any?] else {
                    print("Error while fetching remote rooms: \(response.result.error)")
                    return
                }
                if let status = dict["status"] as? String, let arrMessages = dict["msgList"] as? [[String:Any?]] {
                    if status == "200" {
                        self.dictMessages.removeAll()
                        for dictMessage in arrMessages {
                            let message = Message(withParams: dictMessage)
                            self.dictMessages.append(message)
                        }
                        self.tableView.reloadData()
                    }else if status == "500" {
                        Common.displayAlert(message: "Session expired, please login again.", onViewController: self)
                        DispatchQueue.main.async {
                            self.navigationController?.popToRootViewController(animated: false)
                        }
                    }
                
                }
        }
    }
    
    func markUnlocked(beacon:Beacon){
        Alamofire.request(
            URL(string: Services.wsBaseURL + Services.wsMarkUnlocked + "/" +  Common.inSessionUser!.strEmailID! + "/" + beacon.strMajorMinor + "/" + Common.inSessionUser!.strEmailID!)!,
            method: .get,
            parameters: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess, let dict = response.result.value as? [String:Any?] else {
                    print("Error while fetching remote rooms: \(response.result.error)")
                    return
                }
                if let status = dict["status"] as? String {
                    if status == "200" {
                        for message in self.dictMessages! {
                            if beacon.strMajorMinor == message.strMajorMinor{
                                message.isLocked = false
                            }
                        }
                        self.tableView.reloadData()
                    }else {
                        // turn animator off and show alert for no messages, please try later
                    }
                }
        }
        
    }
    

    func performLockRefresh(){
        if let firstBeacon = self.arrRegions.first {
            markUnlocked(beacon: firstBeacon)
        }
    }
    
    func cancel() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performLockRefresh), object: nil)
    }
    
    func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon],
                       in region: CLBeaconRegion) {
        if let nearestBeacon = beacons.first {
            let nearestBeacon = Beacon(beacon:nearestBeacon)
            if nearestBeacon.strMajorMinor == self.arrRegions.first?.strMajorMinor{
                return
            }
        }
        cancel()
        for beacon in beacons{
            let beacon = Beacon(beacon: beacon)
            self.arrRegions.append(beacon)
        }
        self.perform(#selector(performLockRefresh), with: nil, afterDelay: 10.0)
    }
}
