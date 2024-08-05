//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Дима on 03.08.2024.
//

import Foundation

struct TrackerRecord: Codable {
    let trackerID: UUID
    let date: Date

    init(id: UUID = UUID(), trackerID: UUID, date: Date) {
        self.trackerID = trackerID
        self.date = date
    }
}
