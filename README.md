# เรียนรู้และทดสอบเขียนแอพ iOS ด้วย Swift เพื่อสแกนหาอุปกรณ์ iBeacon
โปรเจคนี้ผมพยายามทำให้แอพสามารถสแกนหาอุปกรณ์ beacon ได้ทั้งตอนที่เปิดแอพอยู่, แอพทำงานใน background mode และขณะที่ไม่ได้เปิดแอพ
ถ้าแอพทำงานใน background mode และขณะที่ไม่ได้เปิดแอพ จะมี Notification เตือนให้รู้เมื่อพบอุปกรณ์ Beacon

## เปิดการสแกน Location ใน Background mode
ขั้นแรกหลังจากสร้างโปรเจคใหม่ ให้ไปเปิดให้สามารถสแกน Location ใน Background mode ได้ โดยทำตามขั้นตอนนี้
![screenshot-01](https://raw.githubusercontent.com/golfz/learn-swift-ibeacon/master/screenshot-01.jpg)

## ขอสิทธิในการ monitor location
ต่อมาให้เพิ่มข้อมูลการขอสิทธิในการ monitor location ในไฟล์ Info.plist
```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>App ต้องใช้งาน Location</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>App ต้องใช้งาน Location</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>App ต้องใช้งาน Location</string>
```

## Code ส่วนที่สำคัญ

### Import CoreLocation
```swift
import CoreLocation
```

### Implement protocol : CLLocationManagerDelegate
```swift
class VCMain: ... , CLLocationManagerDelegate
```

### สร้าง Object สำหรับ CLLocationManager และ CLBeaconRegion
```swift
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
```

### Implement event ต่างๆ ของ CLLocationManagerDelegate

#### รับ event การเปลี่ยนแปลง Authorization
```swift
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
```

#### ใส่อันนี้เพื่อให้ได้รับสถานะ 
สำหรับกรณีที่สั่งให้เริ่ม monitor แต่มือถืออยู่ใน Region อยู่แล้ว
ถ้าไม่ใส่จะไม่ได้รับ didEnterRegion
```swift
func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    manager.requestState(for: region)
}
```

#### ต่อเนื่องจากอันข้างบน
```swift
func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
    if state == .inside {
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
    } else {

    }
}
```

#### Event เมื่อมือถือเข้าและออกจาก Region
```swift
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
```

#### Event เมื่อวัดระยะ beacon แต่ละตัวใน Region
ใน event นี้สามารถขอค่า Major , Minor ออกมาได้
```swift
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
```
