//
//  PrayerWorker.swift
//  Pods-PrayerIDN_Example
//
//  Created by Rangga Leo on 11/01/21.
//

import Foundation

internal struct URLConstant {
    static let server = "https://api.banghasan.com/"
    static let api_sholat = server + "sholat/format/json/"
}

internal class PrayerWorker {
    static let shared = PrayerWorker()
    
    func getCityCode(city: String? = nil, completion: @escaping (Result<CityResponse, Error>) -> Void) {
        var url: String = ""
        if let _city = city?.lowercased() {
            url = URLConstant.api_sholat + "kota/nama/" + _city
        } else {
            url = URLConstant.api_sholat + "kota"
        }
        debugLog(url)
        HTTPRequest.shared.connect(url: url, params: nil, model: CityResponse.self) { (result) in
            completion(result)
        }
    }
    
    func getPrayerTimes(city_code: String, date: String, completion: @escaping (Result<PrayerTimesResponse, Error>) -> Void) {
        let url = URLConstant.api_sholat + "jadwal/kota/" + city_code + "/tanggal/" + date
        debugLog(url)
        HTTPRequest.shared.connect(url: url, params: nil, model: PrayerTimesResponse.self) { (result) in
            completion(result)
        }
    }
}

struct RequestQuery: Codable {
    let format: String
    let nama: String?
    let tanggal: String?
}

struct CityResponse: Codable {
    let status: String
    let query: RequestQuery
    let kota: [City]
}

struct City: Codable {
    let id, nama: String
}

struct PrayerTimesResponse: Codable {
    let status: String
    let query: RequestQuery
    let jadwal: PrayerTimesItem
}

struct PrayerTimesItem: Codable {
    let status: String
    let data: PrayerTimesIDN
}

struct PrayerTimesIDN: Codable {
    let ashar, dhuha, dzuhur, imsak: String
    let isya, maghrib, subuh, tanggal: String
    let terbit: String
}

