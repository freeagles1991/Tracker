//
//  TrackerEntity+CoreDataProperties.swift
//  Tracker
//
//  Created by Дима on 03.09.2024.
//
//

import Foundation
import CoreData


extension TrackerEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerEntity> {
        return NSFetchRequest<TrackerEntity>(entityName: "TrackerEntity")
    }

    @NSManaged public var color: String?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var schedule: String?
    @NSManaged public var title: String?
    @NSManaged public var category: TrackerCategoryEntity?
    @NSManaged public var records: NSSet?
    
    // Computed property для работы с schedule как с [Weekday]
    public var scheduleArray: [Weekday]? {
        get {
            // Декодируем строку JSON в массив Weekday
            guard let schedule = schedule else { return [] }
            let decoder = JSONDecoder()
            if let data = schedule.data(using: .utf8),
               let weekdays = try? decoder.decode([Weekday].self, from: data) {
                return weekdays
            }
            return []
        }
        set {
            // Кодируем массив Weekday в строку JSON
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(newValue) {
                schedule = String(data: data, encoding: .utf8)
            }
        }
    }

}

// MARK: Generated accessors for records
extension TrackerEntity {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: TrackerRecordEntity)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: TrackerRecordEntity)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)

}

extension TrackerEntity : Identifiable {

}

