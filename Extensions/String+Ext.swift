//
//  String+Ext.swift
//  Pods-PrayerIDN_Example
//
//  Created by Rangga Leo on 12/01/21.
//

import Foundation

extension String {
    func convertToDate(format: String = "HH:mm") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        guard let dateObjectWithTime = dateFormatter.date(from: self) else { return nil }
        
        let gregorian = Calendar(identifier: .iso8601)
        let now = Date()
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        var dateComponents = gregorian.dateComponents(components, from: now)
        
        let calendar = Calendar.current
        dateComponents.hour = calendar.component(.hour, from: dateObjectWithTime)
        dateComponents.minute = calendar.component(.minute, from: dateObjectWithTime)
        dateComponents.second = 0
        
        return gregorian.date(from: dateComponents)
    }
}
