//
//  TrackerStore.swift
//  Tracker
//
//  Created by Дима on 24.08.2024.
//

import Foundation
import CoreData
import UIKit

final class TrackerStore: NSObject {
    static let shared = TrackerStore()
    private override init() {}
    
    private var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("UIApplication.shared.delegate is not of type AppDelegate")
        }
        return delegate
    }
    
    var trackersVC: TrackersViewController?
    var fetchedResultsController: NSFetchedResultsController<TrackerEntity>?
    
    // Настраиваем FRC
    func setupFetchedResultsController(_ predicate: NSPredicate) {
        let fetchRequest: NSFetchRequest<TrackerEntity> = TrackerEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "title", ascending: true)
        ]
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "pinnedOrCategory",
            cacheName: nil
        )
        guard let fetchedResultsController else { return }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    var numberOfSections: Int {
        fetchedResultsController?.sections?.count ?? 0
       }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        
        fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }

    func object(at indexPath: IndexPath) -> Tracker? {
        guard let fetchedResultsController else { return Tracker.defaultTracker }
        let trackerEntity = fetchedResultsController.object(at: indexPath)
        return convertEntityToTracker(trackerEntity)
    }
    
    func header(at indexPath: IndexPath) -> String? {
        guard let fetchedResultsController else { return "NoName" }
        let trackerEntity = fetchedResultsController.object(at: indexPath)
        return trackerEntity.pinnedOrCategory
    }
    
    private func convertEntityToTracker(_ trackerEntity: TrackerEntity) -> Tracker? {
        guard
            let id = trackerEntity.id,
            let title = trackerEntity.title,
            let color = trackerEntity.color,
            let emoji = trackerEntity.emoji,
            let schedule = trackerEntity.scheduleArray
        else {
            return nil
        }

        return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule, isPinned: trackerEntity.isPinned)
    }
    
    public func fetchTrackers(by date: Date) -> [Tracker]? {
        guard let selectedWeekday = Weekday.fromDate(date) else { return [] }
        
        let predicate = NSPredicate(format: "schedule CONTAINS[cd] %@", selectedWeekday.rawValue)
        
        self.setupFetchedResultsController(predicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        
        return fetchedObjects.compactMap { trackerEntity in
            convertEntityToTracker(trackerEntity)
        }
    }

    public func fetchTrackerEntity(_ id: UUID) -> TrackerEntity? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        self.setupFetchedResultsController(predicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return TrackerEntity()
        }

        let trackerEntity = fetchedObjects.first

        return trackerEntity

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
        trackerEntity.scheduleArray = tracker.schedule
        trackerEntity.color = tracker.color
        trackerEntity.isPinned = tracker.isPinned
        
        trackerEntity.category = category
        category.addToTrackers(trackerEntity)
        
        appDelegate.saveContext()
    }
    
    func updateTracker(for tracker: Tracker, to newCategory: TrackerCategoryEntity? = nil) {
        let predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        self.setupFetchedResultsController(predicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects,
              let trackerEntity = fetchedObjects.first else {
            print("Tracker not found")
            return
        }
        
        // Обновляем свойства трекера
        trackerEntity.title = tracker.title
        trackerEntity.emoji = tracker.emoji
        trackerEntity.scheduleArray = tracker.schedule
        trackerEntity.color = tracker.color
        trackerEntity.isPinned = tracker.isPinned
        
        if let newCategory = newCategory {
            // Удаляем трекер из старой категории
            if let oldCategory = trackerEntity.category {
                oldCategory.removeFromTrackers(trackerEntity)
            }

            // Устанавливаем новую категорию
            trackerEntity.category = newCategory
            newCategory.addToTrackers(trackerEntity)
        }
        
        // Сохраняем изменения
        appDelegate.saveContext()
    }

    
    public func removeTracker(with id: UUID) {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        self.setupFetchedResultsController(predicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects,
                let trackerEntity = fetchedObjects.first else {
            return
        }

        context.delete(trackerEntity)
        appDelegate.saveContext()
    }
    
}
