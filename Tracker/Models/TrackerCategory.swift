//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Дима on 03.08.2024.
//

import Foundation

struct TrackerCategory: Codable {
    let title: String
    let trackers: [Tracker]

    init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
}
