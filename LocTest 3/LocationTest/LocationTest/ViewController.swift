//
//  ViewController.swift
//  LocationTest
//
//  Created by Kalaiselvi Krishnan on 6/4/18.
//  Copyright © 2018 Kalaiselvi Krishnan. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import CallKit

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    var msgbody = "Dummy"
    var callObs : CXCallObserver!
    var callObserver: CXCallObserver!
    var registered : Bool = false
    var count: Int = 0
    let locationManager:CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var txtSpeed: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    //Krishnan:Notification Parameters
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, Error in})
   
    //Krishnan:Use default parameters and start the background service.
    //We are not pausing in this build yet
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        print(registered)
        
        //Krishnan:Call default Parameters
        callObserver = CXCallObserver()
        callObserver.setDelegate(self as! CXCallObserverDelegate, queue: nil) // nil queue means main thread
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        registered = true
        print(registered)
        
        //Krishnan:Start fine location updates with default parameters for preset count
        if (registered == true) && (count < 20) {
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        }
        
        //Krishnan: For every update, count up
        for currentLocation in locations{
            print("\(index): \(currentLocation)")
            count += 1
            print (count)
            txtSpeed.text = String(currentLocation.speed)
        
        //Krishnan: When counter reaches preset, stop fine and switch to Significant
            if (registered == true) && count >= 20 {
                locationManager.stopUpdatingLocation()
                locationManager.startMonitoringSignificantLocationChanges()
            }
        
        //Krishnan: Reset Counter
            if registered == false {
                count = 0
            }
        
        //Nofification to check if this program runs in background
            msgbody = String(currentLocation.speed)
            let content = UNMutableNotificationContent()
            content.title = "The 5 seconds are up!"
            content.subtitle = "Really"
            content.body = msgbody
            content.badge = 1
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: "TimerDone", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            print("Disconnected")
            registered = false
        }
        if call.isOutgoing == true && call.hasConnected == false {
            print("Dialing")
        }
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            print("Incoming")
        }
        
        if call.hasConnected == true && call.hasEnded == false {
            print("Connected")
            registered = true
        }
    }
}
