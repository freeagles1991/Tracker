//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Дима on 03.08.2024.
//

import Foundation

struct TrackerCategory: Codable {
    var title: String
    var trackers: [Tracker]

    init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
}
