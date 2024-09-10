//
//  Weekday.swift
//  Tracker
//
//  Created by Дима on 03.09.2024.
//

import Foundation

public enum Weekday: String, CaseIterable, Codable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    static func fromDate(_ date: Date) -> Weekday? {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date)
        
        let weekdays = [
            Weekday.sunday,
            Weekday.monday,
            Weekday.tuesday,
            Weekday.wednesday,
            Weekday.thursday,
            Weekday.friday,
            Weekday.saturday
        ]
        
        return weekdays[weekdayIndex - 1]
    }
}
