//
//  WalkViewController.swift
//  DogBook
//
//  Created by 李一正 on 2018/8/6.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit
import CoreLocation

class WalkViewController: UIViewController {

    @IBOutlet weak var meterLabel: UILabel!
    let communicator = Communicator()
    let locationManager = CLLocationManager()
    var myDogId = -1
    var meter = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.meterLabel.text = "0.0"
        }
    }
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        
        var data = [String:Any]()
        data["status"] = ADD_METER
        data["dogId"] = myDogId
        data["meter"] = meter
        communicator.doPost(url: DogServlet, data: data) { (result) in
            
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    
    func configureView() {
        // Ask user's permission.
        locationManager.requestAlwaysAuthorization()
        
        // Background loaction update support.
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        guard CLLocationManager.locationServicesEnabled() else {
            // Show hint to user.
            return
        }
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else {
            // Show hint to user.
            return
        }
        
        // Prepare locationManager.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        // distanceFilter 移動超過 1 公尺 才算移動
        locationManager.distanceFilter = 1.0
        locationManager.startUpdatingLocation()
        
        
    }
        
}
extension WalkViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        meter += 1
        meterLabel.text = "\(meter)"
    }
}
