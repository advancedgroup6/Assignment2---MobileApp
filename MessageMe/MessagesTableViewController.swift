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
        // 4. We need to request this authorization for every beacon manager
        self.beaconManager.requestAlwaysAuthorization()
        NotificationCenter.default.addObserver(self, selector: #selector(regionUpdatesReceived), name:  NSNotification.Name(rawValue: "RegionUpdates"), object: nil)
        super.viewDidLoad()

//        self.tableView.register(MessageCellTableViewCell.self, forCellReuseIdentifier:
//            MessageCellTableViewCell.cellReuseID)
        self.tableView.register(UINib(nibName:"MessageTableViewCell", bundle:nil), forCellReuseIdentifier: MessageCellTableViewCell.cellReuseID)
        self.navigationItem.setHidesBackButton(true, animated: false)
//        self.fetchAllMessages()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
//        if let dictMessages = self.dictMessages {
//            return dictMessages.keys.count
//        }
        return 1// dictMessages.count
    }

    @IBAction func refreshMessagesAction(_ sender: Any) {
        fetchAllMessages()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        if let region = arrRegions?[section]{
//            if let arrMessages = dictMessages?[region.strMajorMinor] {
//                return arrMessages.count
//            }
//        }
        return self.dictMessages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCellTableViewCell.cellReuseID, for: indexPath) as! MessageCellTableViewCell
//        let objRegion = arrRegions![indexPath.section]
//        let objMessage = dictMessages![objRegion.strRegionName]![indexPath.row];
//        let objMessage = dictMessages![objRegion.strMajorMinor]![indexPath.row];
        let objMessage = dictMessages[indexPath.row]
        cell.populateCellData(withMessage:objMessage)
        // Configure the cell...
        return cell
    }
    
    func canViewMessage(message:Message) -> Bool{
        // all beacon activity
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let regionName = arrRegions![indexPath.section].strMajorMinor
//        let message = (dictMessages[regionName!]?[indexPath.row])!
        let message = dictMessages[indexPath.row]
        if canViewMessage(message: message){
            if (message.isRead)! {
                pushToRead(message:message)
            }else{
                markMessageRead(message: message)
            }
        }else{
            // alert saying cant view here, go in the region to unlock
            
        }
        
    }
    
    private func pushToRead(message:Message){
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        let readMessageVC = storyboard.instantiateViewController(withIdentifier: "readMessage") as! ReadMessageViewController
        readMessageVC.objMessage = message
        self.navigationController?.pushViewController(readMessageVC, animated: true)
    }
    
    private func markMessageRead(message:Message!){
        Alamofire.request(
            URL(string: "http://18.220.138.212:8080/updateMsgRead/" + message.strMessageID)!,
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
                        self.pushToRead(message: message)
                    }else {
                        // turn animator off and show alert for no messages, please try later
                    }
                }
        }
    }
   
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
     func fetchAllMessages(){
        let userID = Common.inSessionUser?.strEmailID
        Alamofire.request(
            URL(string: "http://18.220.138.212:8080/getMessages/" + userID!)!,
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
//                        for beacon in self.arrRegions! {
//                            var arrForRegion = [Message]()
//                            for dictMsg in arrMessages {
//                                let message = Message(withParams:dictMsg)
//                                if message.strRegionName == beacon.strMajorMinor {
//                                    arrForRegion.append(message)
//                                }
//                            }
//                            // sort by date here.
//                            self.dictMessages?[beacon.strMajorMinor] = arrForRegion
//                        }
                        for dictMessage in arrMessages {
                            let message = Message(withParams: dictMessage)
                            self.dictMessages.append(message)
                        }
                        self.tableView.reloadData()
                    }else {
                        // turn animator off and show alert for no messages, please try later
                    }
                }
        }
    }
    
    func markUnlocked(message:Message){
        Alamofire.request(
            URL(string: "http://18.220.138.212:8080/updateMsgLock/" + message.strMessageID)!,
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
                        message.isLocked = false
                        self.pushToRead(message: message)
                    }else {
                        // turn animator off and show alert for no messages, please try later
                    }
                }
        }
        
    }
    
    func reloadTable(){
        self.tableView.reloadData()
    }
    
    func performLockRefresh(){
        let nearestBeacon = self.arrRegions.first
//        let arrNearestBeaconMessages = self.dictMessages[(nearestBeacon?.strMajorMinor)!]
        for message in self.dictMessages! {
            if nearestBeacon?.strMajorMinor == message.strMajorMinor{
                markUnlocked(message: message)
            }
        }
        DispatchQueue.main.async {
            self.perform(#selector(self.fetchAllMessages), with: nil, afterDelay: 1.0)
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
