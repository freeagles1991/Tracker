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
    
    var fetchedResultsController: NSFetchedResultsController<TrackerEntity>?
    
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
        return trackerEntity.category?.title
    }
    
    
    private func convertEntityToTracker(_ trackerEntity: TrackerEntity) -> Tracker? {
        guard
            let id = trackerEntity.id,
            let title = trackerEntity.title,
            let color = trackerEntity.color,
            let emoji = trackerEntity.emoji,
            let schedule = trackerEntity.schedule as? [Weekday]
        else {
            return nil
        }

        return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
    }
    
    // Настраиваем FRC
    func setupFetchedResultsController(for date: Date) {
        let fetchRequest: NSFetchRequest<TrackerEntity> = TrackerEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        // Предполагаем, что у вас есть метод Weekday.fromDate(date) и свойство schedule у TrackerEntity
        guard let selectedWeekday = Weekday.fromDate(date) else { return }
        
        // Фильтруем по дню недели
        let predicate = NSPredicate(format: "ANY trackers.schedule CONTAINS %@", selectedWeekday.rawValue)
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        guard let fetchedResultsController else { return }
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
    
    //Загружаем трекеры
    var filteredTrackers: [Tracker] {
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return []
        }

        return fetchedObjects.compactMap { trackerEntity in
            convertEntityToTracker(trackerEntity)
        }
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
extension TrackerStore: NSFetchedResultsControllerDelegate {
    // MARK: - NSFetchedResultsControllerDelegate

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Prepare UI for updates
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            // Handle insertion
            break
        case .delete:
            // Handle deletion
            break
        case .update:
            // Handle update
            break
        case .move:
            // Handle move
            break
        @unknown default:
            fatalError("Unknown change type encountered.")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Finalize UI updates
    }
}
