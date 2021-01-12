//
//  ViewController.swift
//  PrayerIDN
//
//  Created by ranggaleoo on 01/11/2021.
//  Copyright (c) 2021 ranggaleoo. All rights reserved.
//

import UIKit
import CoreLocation
import PrayerIDN

class ViewController: UIViewController {
    
    private var locationManager: CLLocationManager = {
        $0.requestWhenInUseAuthorization()
        $0.startUpdatingHeading()
        $0.startUpdatingLocation()
        return $0
    }(CLLocationManager())

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        let cal = Calendar(identifier: Calendar.Identifier.iso8601)
        let date = cal.dateComponents([.year, .month, .day], from: Date())
        
        if let currentLoc = locationManager.location?.coordinate {
            let prayer = PrayerIDN(coordinate: PrayerIDN.Coordinate(lat: currentLoc.latitude, long: currentLoc.longitude), date: date)
            prayer.delegate = self
            debugPrint(prayer.times)
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let cal = Calendar(identifier: Calendar.Identifier.iso8601)
        let date = cal.dateComponents([.year, .month, .day], from: Date())
        guard let location = locations.last else { return }
        let coordinate = PrayerIDN.Coordinate(lat: location.coordinate.latitude, long: location.coordinate.longitude)
        let prayer = PrayerIDN(coordinate: coordinate, date: date)
        prayer.delegate = self
    }
}

extension ViewController: PrayerDelegate {
    func failWhenRequestApi(error: Error) {
        debugPrint(error.localizedDescription)
    }
    
    func failWhenDefinePlaceMark(error: Error) {
        debugPrint(error.localizedDescription)
    }
    
    func didUpdateTimes(times: PrayerIDN.Times) {
        debugPrint(times)
    }
}

