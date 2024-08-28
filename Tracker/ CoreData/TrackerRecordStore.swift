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
    
    //Загрузка всех записей
    public func fetchAllTrackerRecords() -> [TrackerRecord] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerRecordEntity")
        
        do {
            // Выполняем запрос и приводим результат к массиву TrackerRecordEntity
            if let recordEntities = try context.fetch(fetchRequest) as? [TrackerRecordEntity] {
                // Преобразуем каждый TrackerRecordEntity в TrackerRecord
                return recordEntities.compactMap { entity in
                    guard let date = entity.date, let trackerEntity = entity.tracker else {
                        return nil
                    }
                    return TrackerRecord(trackerID: trackerEntity.id!, date: date)
                }
            }
        } catch {
            print("Ошибка при загрузке всех записей трекеров: \(error.localizedDescription)")
        }
        
        return []
    }

    //Загрузка записей для трекера по ID
    public func fetchTrackerRecord(byID trackerID: UUID) -> TrackerRecord? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerRecordEntity")
        // Устанавливаем предикат для фильтрации записей по trackerID
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@", trackerID as CVarArg)
        
        do {
            // Выполняем запрос и проверяем результат
            if let recordEntities = try context.fetch(fetchRequest) as? [TrackerRecordEntity],
               let entity = recordEntities.first {
                // Используем guard для безопасного извлечения значений
                guard let date = entity.date, let id = entity.trackerID else {
                    return nil
                }
                // Возвращаем объект TrackerRecord
                return TrackerRecord(trackerID: id, date: date)
            }
        } catch {
            print("Ошибка при загрузке записи трекера: \(error.localizedDescription)")
        }
        return nil
    }

    //Создание записи
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
    
    //Удаление записи
    public func deleteTrackerRecord(with trackerID: UUID, on date: Date) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerRecordEntity")
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@ AND date == %@", trackerID as CVarArg, date as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if !results.isEmpty {
                for record in results {
                    context.delete(record as! NSManagedObject)
                }
                
                try context.save()
            } else {
                print("No records found for delete")
            }
        } catch {
            print("Error fetching records: \(error)")
        }
    }
}
