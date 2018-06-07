//
//  ViewController.swift
//  ibeacon
//
//  Created by Surattikorn Chumkaew on 3/5/2561 BE.
//  Copyright © 2561 example. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

var countNotification: Int = 0;
let beaconUuid = "00112233-4455-6677-8899-AABBCCDDEEFF"
let beaconRegionId = "com.example.ibeacon"

class VCMain: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var txtUUID: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    // Notification
    let myNotification = Notification.Name(rawValue:"iBeacon")
    var isGrantedNotificationAccess = false
    
    // Core Bluetooth properties
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.allowsBackgroundLocationUpdates = true
        return manager
    }()
    
    lazy var ibeaconRegion:CLBeaconRegion = {
        let proximityUUID = UUID(uuidString: beaconUuid)
        let region = CLBeaconRegion(proximityUUID: proximityUUID!, identifier: beaconRegionId)
        region.notifyEntryStateOnDisplay = true
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }()
    
    struct IBeaconItem{
        var major = 0
        var minor = 0
        var range = ""
    }
    
    var ibeaconList:[IBeaconItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.txtUUID.text = beaconUuid
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.requestNotificationAuthorization()
        self.enableLocationServices()
        self.locationManager.requestState(for: self.ibeaconRegion)
        self.showBadgeCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ibeaconList.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: "TblcellBeaconItem", bundle: nil), forCellReuseIdentifier: "TblcellBeaconItem")
        let cell = tableView.dequeueReusableCell(withIdentifier: "TblcellBeaconItem", for: indexPath) as! TblcellBeaconItem
        
        let major = self.ibeaconList[indexPath.row].major
        let minor = self.ibeaconList[indexPath.row].minor
        let range = self.ibeaconList[indexPath.row].range
        
        cell.txtMajorMinor.text = "Major : \(major)   Minor : \(minor)"
        cell.txtRange.text = range
        
        return cell
    }
    
    // MARK: - Core Location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            // Disable your app's location features
            disableLocationServices()
            break
            
        case .authorizedAlways:
            // Enable any of your app's location services.
            self.enableLocationServices()
            break
            
        case .notDetermined, .authorizedWhenInUse:
            break
        }
    }
    
    func disableLocationServices() {
        self.locationManager.stopRangingBeacons(in: self.ibeaconRegion)
        self.locationManager.stopMonitoring(for: self.ibeaconRegion)
    }
    
    func enableLocationServices() {
        print("enableLocationServices()")
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            print(".notDetermined")
            self.locationManager.requestAlwaysAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            // disableMyLocationBasedFeatures()
            print(".restricted, .denied")
            break
            
        case .authorizedWhenInUse:
            // Enable basic location features
            print(".authorizedWhenInUse")
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            print(".authorizedAlways")
            startMonitorBeacons()
            break
        }
    }
    
    func startMonitorBeacons() {
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            self.locationManager.startMonitoring(for: self.ibeaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
        } else {
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLBeaconRegion {
            // Start ranging only if the feature is available.
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(in: region as! CLBeaconRegion)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // perform actions when exit region
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        if self.ibeaconList.count > 0 && beacons.count <= 0 {
            manager.stopRangingBeacons(in: region)
            self.ibeaconList = []
            self.tableview.reloadData()
            return
        }
        
        if self.ibeaconList.count == 0 && beacons.count > 0 {
            self.performNotification(title: "Found new beacon devices", body: "Tap to view more details")
        }
        
        self.ibeaconList = []
        
        for aBeacon in beacons {
            let major = Int( CLBeaconMajorValue(truncating: aBeacon.major) )
            let minor = Int( CLBeaconMinorValue(truncating: aBeacon.minor) )
            
            var range = ""
            
            switch aBeacon.proximity {
            case .immediate:
                range = "Range : Immediate"
                break
                
            case .near:
                range = "Range : Near"
                break
                
            case .far:
                range = "Range : Far"
                break
                
            case .unknown:
                range = "Range : Unknown"
                break
            }
            
            self.ibeaconList.append(IBeaconItem(major: major, minor: minor, range: range))
        }
        
        self.tableview.reloadData()
        
    }
    // - End: Core Location - ///////////////////////////
    
    
    // MARK: - Notification
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                if error == nil {
                    print("grant: \(granted)")
                    self.isGrantedNotificationAccess = granted
                    
                } else {
                    print(error ?? "error")
                }
        }
        )
    }
    
    func performNotification(title:String, body:String) {
        
        print("Perform notification.")
        
        if isGrantedNotificationAccess {
            //add notification code here
            print("grant notification.")
            
            countNotification += 1
            self.showBadgeCount()
            
            //Set the content of the notification
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default()
            
            //Set the trigger of the notification -- here a timer.
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 1.0,
                repeats: false)
            
            //Set the request for the notification from the above
            let uuid = UUID().uuidString
            let notificationId = "com.example.ibeacon.\(uuid)"
            let request = UNNotificationRequest(
                identifier: notificationId,
                content: content,
                trigger: trigger
            )
            
            //Add the notification to the currnet notification center
            UNUserNotificationCenter.current().add(
                request, withCompletionHandler: nil)
            
        } else {
            print("no grant notification.")
        }
    }
    // - End: Notification - ///////////////////////////
    
    
    func showBadgeCount() {
        self.setBadgeCount(badgeCount: countNotification)
    }
    
    func setBadgeCount(badgeCount: Int) {
        let application = UIApplication.shared
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = badgeCount
    }


}

