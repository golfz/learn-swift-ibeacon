//
//  AppDelegate.swift
//  ibeacon
//
//  Created by Surattikorn Chumkaew on 3/5/2561 BE.
//  Copyright © 2561 example. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    
    let locationManager = CLLocationManager()
    let systemSoundID: SystemSoundID = 1016


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        self.enableLocationServices()
        monitorBeacons()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            enableLocationServices()
        }
    }
    
    
    
    func enableLocationServices() {
        print("enableLocationServices")
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestAlwaysAuthorization()
            print(".notDetermined")
            break
            
        case .restricted, .denied:
            // Disable location features
            //            disableMyLocationBasedFeatures()
            print(".restricted, .denied")
            break
            
        case .authorizedWhenInUse:
            // Enable basic location features
            //            enableMyWhenInUseFeatures()print(".Not determined")
            print(".authorizedWhenInUse")
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            //            enableMyAlwaysFeatures()
            print(".authorizedAlways")
            break
        }
    }
    
    func monitorBeacons() {
        print("monitorBeacons")
        if CLLocationManager.isMonitoringAvailable(for:
            CLBeaconRegion.self) {
            // Match all beacons with the specified UUID
            let proximityUUID = UUID(uuidString:
                "00112233-4455-6677-8899-AABBCCDDEEFF")
            let beaconID = "com.example.myBeaconRegion"
            
            // Create the region and begin monitoring it.
            let region = CLBeaconRegion(proximityUUID: proximityUUID!,
                                        identifier: beaconID)
            region.notifyEntryStateOnDisplay = true
            region.notifyOnEntry = true
            region.notifyOnExit = true
            self.locationManager.startMonitoring(for: region)
//            self.locationManager.startRangingBeacons(in: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didEnterRegion region: CLRegion) {
        print("didEnterRegion")
        if region is CLBeaconRegion {
            // Start ranging only if the feature is available.
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(in: region as! CLBeaconRegion)
                
                // Store the beacon so that ranging can be stopped on demand.
                //                beaconsToRange.append(region as! CLBeaconRegion)
                print("beaconToRange")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didRangeBeacons beacons: [CLBeacon],
                         in region: CLBeaconRegion) {
        print("didRangeBeacons")
        if beacons.count > 0 {
            print("beacons.count: \(beacons.count)")
            let nearestBeacon = beacons.first!
            let major = CLBeaconMajorValue(truncating: nearestBeacon.major)
            let minor = CLBeaconMinorValue(truncating: nearestBeacon.minor)
            
            print(major)
            print(minor)
            
            switch nearestBeacon.proximity {
            case .near, .immediate:
                // Display information about the relevant exhibit.
                print(".near")
                AudioServicesPlaySystemSound (systemSoundID)
                break
                
            default:
                // Dismiss exhibit information, if it is displayed.
                print("default")
                AudioServicesPlaySystemSound (systemSoundID)
                break
            }
        }
    }
    
    


}

