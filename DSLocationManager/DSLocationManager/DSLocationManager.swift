//
//  DSLocationManager.swift
//  DSLocationManager
//
//  Created by Dinesh Saini on 8/25/17.
//  Copyright © 2017 Dinesh Saini. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import CoreTelephony


enum LocationMessage : String {
    case MSGDenied = "Location is denied by user"
    case MSGAuthorizedAlways = "Location authorization is always use"
    case MSGAuthorizedWhenInUse = "Location authorization when in use"
    case MSGNotDetermined = "Location authorization not determined"
    case MSGRestricted = "Location authorization restricted"
}

struct LMMessage {
    static let Setting = "Setting"
    static let Cancel = "Cancel"
    static let LocationService = "Location Service"
    static let LocationManager = "Location Manager"
    static let LocationDisable = "Location service is disable, please enable location service to get current location"
    static let LocationServiceDenied = "Location Service Denied"
    static let LocationServiceRestricted = "Location Service Restricted"
    
}

enum LocationRequest {
    case RequestWhenInUse   // get location only when application use
    case RequestAlways  // getting location always (all time)
    case RequestLocation // For Single location update
    
}

class DSLocationManager : NSObject,CLLocationManagerDelegate{
    
    
    /// Shared instance object of DSLocationManager
    static var shared = DSLocationManager()
    
    
    private var geocoder        :   CLGeocoder!
    private var placemark       :   CLPlacemark!
    private var locationManager :   CLLocationManager!
    var currentLocation         :   CLLocation?
    
    var updatedLocationCloser           : ((_ location: CLLocation) -> Void) = {_ in }
    var failureCloser                   : ((_ error: Error) -> Void) = {_ in }
    
    
    /// Check location manager authorization
    func locationManagerAuthorization() -> Void {
        
        switch CLLocationManager.authorizationStatus() {
            
        case .denied:
            self.locationManagerAlert(message: LMMessage.LocationServiceDenied)
            break
            
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
            
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
            
        case .notDetermined:
            if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)){
                locationManager.requestWhenInUseAuthorization()
            }
            break
            
        case .restricted:
            self.locationManagerAlert(message: LMMessage.LocationServiceRestricted)
            break
        }
    }
    

    /// Check location service is enable or disable
    func checkLocationService() -> Bool {
        
        if !CLLocationManager.locationServicesEnabled(){
            return false
        }
        else{
            return true
        }
    }

    
    func stopLocationUpdate() -> Void {
        if let lm = locationManager{
            lm.stopUpdatingLocation()
        }
    }
    
    
    func startLocationUpdate() -> Void {
        //self.checkLocationService()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if checkLocationService(){
            self.locationManagerAuthorization()
        }
        else{
            self.locationServiceDisableAlert()
        }
    }
    
//    MARK:- Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        failureCloser(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .denied,.restricted,.notDetermined:
            
            self.stopLocationUpdate()
            
            break
            
        case .authorizedAlways,.authorizedWhenInUse:
            
            locationManager.startUpdatingLocation()
            
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        updatedLocationCloser(currentLocation!)
    }
    
    
//    MARK:- Alert Methods
    func locationServiceDisableAlert() -> Void {
        let alertController = UIAlertController(title: LMMessage.LocationService, message: LMMessage.LocationDisable, preferredStyle: .alert)
        
        let actionSetting = UIAlertAction(title: LMMessage.Setting, style: UIAlertActionStyle.destructive, handler: { (action) in
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
            
        })
        
        let actionCancel = UIAlertAction(title: LMMessage.Cancel, style: UIAlertActionStyle.cancel, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionSetting)
        
        
        if UIApplication.topViewController() == nil{
            self.perform(#selector(locationServiceDisableAlert), with: self, afterDelay: 3)
        }
        else{
            if let controller = UIApplication.topViewController(){
                controller.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    func locationManagerAlert(message : String) -> Void {
        let alertController = UIAlertController(title: LMMessage.LocationManager, message: message, preferredStyle: .alert)
        
        let actionCancel = UIAlertAction(title: LMMessage.Cancel, style: UIAlertActionStyle.cancel, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(actionCancel)
        if let controller = UIApplication.topViewController(){
            controller.present(alertController, animated: true, completion: nil)
        }
    }
    
}


extension UIApplication {
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
}
