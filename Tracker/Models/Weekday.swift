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
        return NSLocalizedString(self.rawValue, comment: "Weekday name")
    }
    
    static func fromDate(_ date: Date) -> Weekday? {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date)
        let firstWeekday = calendar.firstWeekday
        
        let mondayFirstWeekdays: [Weekday] = [
            .monday,
            .tuesday,
            .wednesday,
            .thursday,
            .friday,
            .saturday,
            .sunday
        ]
        
        let sundayFirstWeekdays: [Weekday] = [
            .sunday,
            .monday,
            .tuesday,
            .wednesday,
            .thursday,
            .friday,
            .saturday
        ]
        
        let weekdaysArray = firstWeekday == 1 ? sundayFirstWeekdays : mondayFirstWeekdays
        var adjustedIndex = weekdayIndex - firstWeekday
        if adjustedIndex < 0 {
            adjustedIndex += 7
        }
        
        return weekdaysArray[adjustedIndex]
    }
}

extension Set where Element == Weekday {
    func toString() -> String {
        let abbreviations: [Weekday: String] = [
            .monday: "Пн",
            .tuesday: "Вт",
            .wednesday: "Ср",
            .thursday: "Чт",
            .friday: "Пт",
            .saturday: "Сб",
            .sunday: "Вс"
        ]
        let abbreviationsArray = self.compactMap { abbreviations[$0] }
        return abbreviationsArray.joined(separator: ", ")
    }
}
