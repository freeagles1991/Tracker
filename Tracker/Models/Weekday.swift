//
//  Weekday.swift
//  Tracker
//
//  Created by Дима on 03.09.2024.
//

import Foundation

public enum Weekday: String, CaseIterable, Codable {
    case monday = "monday"
    case tuesday = "tuesday"
    case wednesday = "wednesday"
    case thursday = "thursday"
    case friday = "friday"
    case saturday = "saturday"
    case sunday = "sunday"
    
    var localized: String {
        print(NSLocalizedString(self.rawValue, comment: "Weekday name"))
        return NSLocalizedString(self.rawValue, comment: "Weekday name")
    }
    
    static func fromDate(_ date: Date) -> Weekday? {
            let calendar = Calendar.current
            let weekdayIndex = calendar.component(.weekday, from: date)
            
            let firstWeekday = calendar.firstWeekday

            let adjustedIndex = (weekdayIndex - firstWeekday + 7) % 7
            
            let weekdays: [Weekday] = [
                .monday,
                .tuesday,
                .wednesday,
                .thursday,
                .friday,
                .saturday,
                .sunday
            ]
            
            return weekdays[adjustedIndex]
        }
}
