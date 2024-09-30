//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Дима on 24.08.2024.
//

import Foundation
import CoreData
import UIKit

final class TrackerCategoryStore: NSObject {
    static let shared = TrackerCategoryStore()
    private override init() {
        super.init()
        setupFetchedResultsController()
    }
    
    var chooseCategoryVC: ChooseCategoryViewController?
    
    private var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("UIApplication.shared.delegate is not of type AppDelegate")
        }
        return delegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    var fetchedResultsController: NSFetchedResultsController<TrackerCategoryEntity>?
    
    // Настраиваем FRC
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryEntity> = TrackerCategoryEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
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

    
    var categories: [TrackerCategory] {
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        
        return fetchedObjects.compactMap { entity in
            return convertEntityToTrackerCategory(entity)
        }
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }

    func object(at indexPath: IndexPath) -> TrackerCategory? {
        guard let fetchedResultsController else { return TrackerCategory.defaultTrackerCategory }
        let trackerCategoryEntity = fetchedResultsController.object(at: indexPath)
        return convertEntityToTrackerCategory(trackerCategoryEntity)
    }
    
    private func convertEntityToTrackerCategory(_ trackerCategoryEntity: TrackerCategoryEntity) -> TrackerCategory? {
        guard let title = trackerCategoryEntity.title,
              let trackerEntities = trackerCategoryEntity.trackers?.allObjects as? [TrackerEntity] else {
            return nil
        }
        
        let trackers = trackerEntities.compactMap { trackerEntity in
            if let id = trackerEntity.id,
               let title = trackerEntity.title,
               let color = trackerEntity.color,
               let emoji = trackerEntity.emoji,
               let schedule = trackerEntity.scheduleArray {
                return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
            } else {
                return nil
            }
        }
        
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    public func createCategory(with category: TrackerCategory) {
        guard let categoryEntityDescription = NSEntityDescription.entity(forEntityName: "TrackerCategoryEntity", in: context) else {
            print("Failed to make categoryEntityDescription")
            return
        }
        
        let categoryEntity = TrackerCategoryEntity(entity: categoryEntityDescription, insertInto: context)
        categoryEntity.title = category.title
        categoryEntity.trackers = []
        
        appDelegate.saveContext()
    }
    
    public func fetchCategory(byTitle title: String) -> TrackerCategory? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryEntity")
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            guard let categoryEntities = try context.fetch(fetchRequest) as? [TrackerCategoryEntity],
                  let categoryEntity = categoryEntities.first else {
                return nil
            }
            
            guard let trackerEntities = categoryEntity.trackers?.allObjects as? [TrackerEntity] else {
                return nil
            }
            
            let trackers = trackerEntities.compactMap { trackerEntity in
                if let id = trackerEntity.id,
                   let title = trackerEntity.title,
                   let color = trackerEntity.color,
                   let emoji = trackerEntity.emoji,
                   let schedule = trackerEntity.scheduleArray {
                    return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
                } else {
                    return nil
                }
            }
            
            return TrackerCategory(title: title, trackers: trackers)
            
        } catch {
            print("Ошибка при загрузке категории: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    public func removeCategory(withTitle title: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryEntity")
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            guard let categories = try context.fetch(fetchRequest) as? [TrackerCategoryEntity],
                  let categoryToDelete = categories.first else {
                print("Категория не найдена")
                return
            }
            
            context.delete(categoryToDelete)
            
            try context.save()
            print("Категория успешно удалена")
            
        } catch {
            print("Ошибка при удалении категории: \(error.localizedDescription)")
        }
    }
    
    public func fetchCategoryEntity(byTitle title: String) -> TrackerCategoryEntity? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryEntity")
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let categoryEntities = try context.fetch(fetchRequest) as? [TrackerCategoryEntity]
            return categoryEntities?.first
        } catch {
            print("Ошибка при загрузке категории: \(error.localizedDescription)")
        }
        return nil
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    // MARK: - NSFetchedResultsControllerDelegate

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        chooseCategoryVC?.tableView.performBatchUpdates(nil)
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath {
                chooseCategoryVC?.tableView.insertRows(at: [newIndexPath], with: .bottom)
            }
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
        chooseCategoryVC?.tableView.performBatchUpdates(nil)
    }
}

