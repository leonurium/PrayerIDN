//
//  DateComponents+String.swift
//  Pods-PrayerIDN_Example
//
//  Created by Rangga Leo on 12/01/21.
//

import Foundation

extension DateComponents {
    func connvertToSetring() -> String? {
        let cal = Calendar.current
        guard let date = cal.date(from: self) else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
