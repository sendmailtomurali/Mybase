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
import CoreMotion

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    var msgbody = "Dummy"
    var callObs : CXCallObserver!
    var callObserver: CXCallObserver!
    var registered : Bool = false
    var count: Int = 0
    let locationManager:CLLocationManager = CLLocationManager()
    let motionActivityManager = CMMotionActivityManager()
    
    @IBOutlet weak var txtSpeed: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Krishnan:Notification Parameters
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, Error in})
        
        //Krishnan:Call default Parameters
        callObserver = CXCallObserver()
        callObserver.setDelegate(self as CXCallObserverDelegate, queue: nil) // nil queue means main thread
        
        //
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Krishnan: For every update, count up
        
        // Location Manager
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivityManager.startActivityUpdates(to: OperationQueue.main) { (motion) in
                
                self.txtSpeed.text = (motion?.automotive)! ? "Automotive True" : "Automotive False"
                self.msgbody = (motion?.automotive)! ? "Automotive : True" : "Automotive : False"
                //self.automotiveLabel.text = (motion?.automotive)! ? "True" : "False"
                
            }
        }
        else{
            self.txtSpeed.text = "No Data Available"
            self.msgbody = "No Data Available"
        }
        
        for currentLocation in locations{
            print("\(index): \(currentLocation)")
            count += 1
            print (count)
            //Nofification to check if this program runs in background
            
            let content = UNMutableNotificationContent()
            content.title = "The count is : " + String(count)
            content.subtitle = "Significant Location"
            content.body = "Activity is " + msgbody
            content.badge = count as NSNumber
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
            
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
