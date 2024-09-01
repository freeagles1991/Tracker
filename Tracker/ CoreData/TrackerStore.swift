//
//  TrackerStore.swift
//  Tracker
//
//  Created by Дима on 24.08.2024.
//

import Foundation
import CoreData
import UIKit

final class TrackerStore{
    static let shared = TrackerStore()
    private init() {}
    
    private var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("UIApplication.shared.delegate is not of type AppDelegate")
        }
        return delegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    public func createTracker(with tracker: Tracker, in category: TrackerCategoryEntity) {
        guard let trackerEntityDescription = NSEntityDescription.entity(forEntityName: "TrackerEntity", in: context) else {
            print("Failed to make trackerEntityDescription")
            return
        }
        
        let trackerEntity = TrackerEntity(entity: trackerEntityDescription, insertInto: context)
        trackerEntity.id = tracker.id
        trackerEntity.title = tracker.title
        trackerEntity.emoji = tracker.emoji
        trackerEntity.schedule = tracker.schedule as NSObject
        trackerEntity.color = tracker.color
        
        trackerEntity.category = category
        category.addToTrackers(trackerEntity)
        
        appDelegate.saveContext()
    }
    
    public func fetchTrackerEntity(_ id: UUID) -> TrackerEntity? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let trackerEntities = try context.fetch(fetchRequest) as? [TrackerEntity],
                  let trackerEntity = trackerEntities.first else {
                return nil
            }
            return trackerEntity
            
        } catch {
            print("Ошибка при загрузке трекера: \(error.localizedDescription)")
        }
        return nil
    }
    
    public func removeTracker(with id: UUID) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let trackers = try context.fetch(fetchRequest) as? [NSManagedObject],
                  let trackerToDelete = trackers.first else {
                print("Трекер не найден")
                return
            }
            
            context.delete(trackerToDelete)
            
            try context.save()
            print("Трекер успешно удален")
            
        } catch {
            print("Ошибка при удалении трекера: \(error.localizedDescription)")
        }
    }
    
}
