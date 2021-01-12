//
//  PrayerIDN.swift
//  Pods-PrayerIDN_Example
//
//  Created by Rangga Leo on 11/01/21.
//

import Foundation
import CoreLocation

public protocol PrayerDelegate: class {
    func failWhenRequestApi(error: Error)
    func failWhenDefinePlaceMark(error: Error)
    func didUpdateTimes(times: PrayerIDN.Times)
}

public class PrayerIDN: NSObject {
    public struct Times {
        public let fajr: Date
        public let sunrise: Date
        public let dhuhr: Date
        public let asr: Date
        public let maghrib: Date
        public let isha: Date
    }
    
    public struct Coordinate {
        public let latitude: Double
        public let longitude: Double
        
        public init(lat: Double, long: Double) {
            latitude = lat
            longitude = long
        }
    }
    
    private var locationManager: CLLocationManager = {
        $0.startUpdatingHeading()
        $0.startUpdatingLocation()
        return $0
    }(CLLocationManager())
    
    public weak var delegate: PrayerDelegate?
    private var coordinate: Coordinate
    private var requestDate: DateComponents
    private var timer : Timer?
    private var isAllowRequest: Bool = true
    public var times: Times? {
        didSet {
            if let time = self.times {
                delegate?.didUpdateTimes(times: time)
            }
        }
    }
    
    public init(coordinate: Coordinate, date: DateComponents) {
        self.coordinate = coordinate
        self.requestDate = date
        super.init()
        locationManager.delegate = self
        timer = Timer(timeInterval: 300, target: self, selector: #selector(didChangeTime), userInfo: nil, repeats: true)
    }
    
    @objc private func didChangeTime() {
        isAllowRequest = true
    }
    
    private func getCode(cityName: String) {
        PrayerWorker.shared.getCityCode(city: cityName) { (result) in
            switch result {
            case .failure(let err):
                self.delegate?.failWhenRequestApi(error: err)
            case .success(let res):
                guard
                    let date = self.requestDate.connvertToSetring(),
                    let code = res.kota.first?.id
                else { return }
                self.getTimes(code: code, date: date)
            }
        }
    }
    
    private func getTimes(code: String, date: String) {
        PrayerWorker.shared.getPrayerTimes(city_code: code, date: date) { (result) in
            switch result {
            case .failure(let err):
                self.delegate?.failWhenRequestApi(error: err)
            case .success(let res):
                guard
                    let fajrDate = res.jadwal.data.subuh.convertToDate(),
                    let sunriseDate = res.jadwal.data.terbit.convertToDate(),
                    let dhuhrDate = res.jadwal.data.dzuhur.convertToDate(),
                    let asrDate = res.jadwal.data.ashar.convertToDate(),
                    let maghribDate = res.jadwal.data.maghrib.convertToDate(),
                    let ishaDate = res.jadwal.data.isya.convertToDate()
                else { self.delegate?.failWhenRequestApi(error: NSError(domain: "error convert to time", code: 101, userInfo: nil)); return }
                let times = Times(fajr: fajrDate, sunrise: sunriseDate, dhuhr: dhuhrDate, asr: asrDate, maghrib: maghribDate, isha: ishaDate)
                self.times = times
            }
        }
    }
    
    private func getPlace(for location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let err = error {
                self.delegate?.failWhenDefinePlaceMark(error: err)
                completion(nil)
                return
            }
            
            if let place = placemarks?.last {
                completion(place)
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}

extension PrayerIDN: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if isAllowRequest {
            isAllowRequest = false
            getPlace(for: location) { (placemark) in
                if let city = placemark?.locality {
                    self.getCode(cityName: city)
                }
            }
        }
    }
}


