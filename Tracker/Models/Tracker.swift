//
//  Trackers.swift
//  Tracker
//
//  Created by Дима on 03.08.2024.
//

import Foundation

struct Tracker: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let color: String
    let emoji: String
    let schedule: [Weekday]
    let isPinned: Bool
    
    init(id: UUID = UUID(), title: String, color: String, emoji: String, schedule: [Weekday], isPinned: Bool? = nil) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isPinned = isPinned ?? false
    }
    
    static let defaultTracker: Tracker = Tracker(
        title: "Default Title",
        color: "Default Color",
        emoji: "😊",
        schedule: Weekday.allCases)
}
