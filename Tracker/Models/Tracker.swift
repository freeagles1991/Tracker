//
//  Trackers.swift
//  Tracker
//
//  Created by Дима on 03.08.2024.
//

import Foundation

enum Weekday: String, CaseIterable, Codable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
}

struct Tracker: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let color: String
    let emoji: String
    let schedule: [Weekday]
    
    init(id: UUID = UUID(), title: String, color: String, emoji: String, schedule: [Weekday]) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}
