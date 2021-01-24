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
        let cal = Calendar(identifier: Calendar.Identifier.iso8601)
        let date = cal.dateComponents([.year, .month, .day], from: Date())
        
        if let currentLoc = locationManager.location?.coordinate {
            let prayer = PrayerIDN(coordinate: PrayerIDN.Coordinate(lat: currentLoc.latitude, long: currentLoc.longitude), date: date)
            prayer.delegate = self
        }
        
        let quran = QuranIDN()
        quran.delegate = self
//        quran.getVerse(chapter_id: 113, verse_ids: [1,2,3])
        quran.getChapter()
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

extension ViewController: QuranIDNDelegate {
    func didGetChapter(chapters: [QuranIDN.QuranChapter]) {
        print(chapters)
    }
    
    func failGetChapter(error: Error) {
        print(error.localizedDescription)
    }
    
    func didGetVerse(chapter: QuranIDN.QuranChapter) {
        print(chapter)
    }

    func failGetVerse(error: Error) {
        print(error.localizedDescription)
    }
}
