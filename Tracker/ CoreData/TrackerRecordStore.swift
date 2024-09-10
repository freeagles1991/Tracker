//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Дима on 24.08.2024.
//

import Foundation
import CoreData
import UIKit

final class TrackerRecordStore: NSObject {
    static let shared = TrackerRecordStore()
    private override init() {}
    
    private var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("UIApplication.shared.delegate is not of type AppDelegate")
        }
        return delegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    var fetchedResultsController: NSFetchedResultsController<TrackerRecordEntity>?
    
    // Настраиваем FRC
    func setupFetchedResultsController(_ predicate: NSPredicate) {
        let fetchRequest: NSFetchRequest<TrackerRecordEntity> = TrackerRecordEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        guard let fetchedResultsController else { return }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
    
    public func fetchTrackerRecords(byID trackerID: UUID) -> [TrackerRecord] {
        let predicate = NSPredicate(format: "tracker.id == %@", trackerID as CVarArg)
        self.setupFetchedResultsController(predicate)

        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        return fetchedObjects.compactMap { entity in
            guard let date = entity.date, let trackerEntity = entity.tracker, let id = trackerEntity.id else {
                return nil
            }
            return TrackerRecord(trackerID: id, date: date)
        }
    }
    
    func fetchTrackerRecords(byID trackerID: UUID, on date: Date) -> [TrackerRecord] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            fatalError("Не удалось получить конец дня")
        }
        
        let predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerID as CVarArg, startOfDay as NSDate, endOfDay as NSDate
        )
        
        self.setupFetchedResultsController(predicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        return fetchedObjects.compactMap { entity in
            guard let date = entity.date, let trackerEntity = entity.tracker, let id = trackerEntity.id else {
                return nil
            }
            return TrackerRecord(trackerID: id, date: date)
        }
    }
    
    public func createTrackerRecord(with trackerEntity: TrackerEntity, on date: Date) {
        guard let recordEntityDescription = NSEntityDescription.entity(forEntityName: "TrackerRecordEntity", in: context) else {
            print("Failed to make recordEntityDescription")
            return
        }
        
        let recordEntity = TrackerRecordEntity(entity: recordEntityDescription, insertInto: context)
        recordEntity.date = date
        recordEntity.tracker = trackerEntity
        
        appDelegate.saveContext()
    }
    
    public func removeTrackerRecord(with trackerID: UUID, on date: Date) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerRecordEntity")
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            fatalError("Не удалось получить конец дня")
        }
        
        print("Удаление записи - TrackerID \(trackerID), дата \(date)")
        
        fetchRequest.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerID as CVarArg, startOfDay as NSDate, endOfDay as NSDate
        )
        
        do {
            let results = try context.fetch(fetchRequest)
            if !results.isEmpty {
                for record in results {
                    guard let managedObject = record as? NSManagedObject else {
                        continue
                    }
                    context.delete(managedObject)
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

