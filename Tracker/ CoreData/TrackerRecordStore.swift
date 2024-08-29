//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Дима on 24.08.2024.
//

import Foundation
import CoreData
import UIKit

final class TrackerRecordStore{
    static let shared = TrackerRecordStore()
    private init() {}
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    public func fetchTrackerRecords(byID trackerID: UUID) -> [TrackerRecord] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerRecordEntity")
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@", trackerID as CVarArg)
        
        do {
            if let recordEntities = try context.fetch(fetchRequest) as? [TrackerRecordEntity] {
                return recordEntities.compactMap { entity in
                    guard let date = entity.date, let trackerEntity = entity.tracker else {
                        return nil
                    }
                    return TrackerRecord(trackerID: trackerEntity.id!, date: date)
                }
            }
        } catch {
            print("Ошибка при загрузке записи трекера: \(error.localizedDescription)")
        }
        return []
    }
    
    func fetchTrackerRecords(byID trackerID: UUID, on date: Date) -> [TrackerRecord] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerRecordEntity")
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        fetchRequest.predicate = NSPredicate(
            format: "trackerID == %@ AND date >= %@ AND date < %@",
            trackerID as CVarArg, startOfDay as NSDate, endOfDay as NSDate
        )
        
        do {
            if let recordEntities = try context.fetch(fetchRequest) as? [TrackerRecordEntity] {
                return recordEntities.compactMap { entity in
                    guard let date = entity.date, let trackerEntity = entity.tracker, let trackerEntityID = trackerEntity.id else {
                        return nil
                    }
                    return TrackerRecord(trackerID: trackerEntityID, date: date)
                }
            }
        } catch {
            print("Ошибка при загрузке записей трекера: \(error.localizedDescription)")
        }
        return []
    }
    
    public func createTrackerRecord(with tracker: Tracker, on date: Date) {
        guard let recordEntityDescription = NSEntityDescription.entity(forEntityName: "TrackerRecordEntity", in: context) else {
            print("Failed to make recordEntityDescription")
            return
        }
        
        let recordEntity = TrackerRecordEntity(entity: recordEntityDescription, insertInto: context)
        recordEntity.date = date
        recordEntity.trackerID = tracker.id
        
        guard let trackerEntity = TrackerStore.shared.fetchTrackerEntity(tracker.id) else { return }
        recordEntity.tracker = trackerEntity
        
        appDelegate.saveContext()
    }
    
    public func removeTrackerRecord(with trackerID: UUID, on date: Date) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerRecordEntity")
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        print("Удаление записи - TrackerID \(trackerID), дата \(date)")
        
        fetchRequest.predicate = NSPredicate(
            format: "trackerID == %@ AND date >= %@ AND date < %@",
            trackerID as CVarArg, startOfDay as NSDate, endOfDay as NSDate
        )
        
        do {
            let results = try context.fetch(fetchRequest)
            if !results.isEmpty {
                for record in results {
                    context.delete(record as! NSManagedObject)
                }
                try context.save()
            } else {
                print("Записи для удаления не найдены")
            }
        } catch {
            print("Ошибка при получении записей: \(error.localizedDescription)")
        }
    }
}
