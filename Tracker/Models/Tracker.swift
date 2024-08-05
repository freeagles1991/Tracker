//
//  Trackers.swift
//  Tracker
//
//  Created by Дима on 03.08.2024.
//

import Foundation

enum Weekday: String, CaseIterable, Codable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
}

struct Tracker: Identifiable, Codable {
    let id: UUID
    var title: String
    var color: String
    var emoji: String
    var schedule: [Weekday]
    
    init(id: UUID = UUID(), title: String, color: String, emoji: String, schedule: [Weekday]) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}
