//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Дима on 24.08.2024.
//

import Foundation
import CoreData
import UIKit

final class TrackerCategoryStore {
    static let shared = TrackerCategoryStore()
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
    
    private let fetchedResultsController = FetchedResultsControllerManager.shared.fetchedResultsController
    
    public func createCategory(with category: TrackerCategory) {
        guard let categoryEntityDescription = NSEntityDescription.entity(forEntityName: "TrackerCategoryEntity", in: context) else {
            print("Failed to make categoryEntityDescription")
            return
        }
        
        let categoryEntity = TrackerCategoryEntity(entity: categoryEntityDescription, insertInto: context)
        categoryEntity.title = category.title
        
        appDelegate.saveContext()
    }
    
    var categories: [TrackerCategory] {
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        
        return fetchedObjects.compactMap { entity in
            guard let title = entity.title,
                  let trackerEntities = entity.trackers?.allObjects as? [TrackerEntity] else {
                return nil
            }
            
            let trackers = trackerEntities.compactMap { trackerEntity in
                if let id = trackerEntity.id,
                   let title = trackerEntity.title,
                   let color = trackerEntity.color,
                   let emoji = trackerEntity.emoji,
                   let schedule = trackerEntity.schedule as? [Weekday] {
                    return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
                } else {
                    return nil
                }
            }
            
            return TrackerCategory(title: title, trackers: trackers)
        }
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
                   let schedule = trackerEntity.schedule as? [Weekday] {
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
    
    public func filterCategories(for date: Date) -> [TrackerCategory] {
        let categories = categories
        guard let selectedWeekday = Weekday.fromDate(date) else {return []}
        
        var filteredCategories: [TrackerCategory] = []
        
        for category in categories {
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.schedule.contains(selectedWeekday)
            }
            
            if !filteredTrackers.isEmpty {
                let filteredCategory = TrackerCategory(title: category.title, trackers: filteredTrackers)
                filteredCategories.append(filteredCategory)
            }
        }
        
        return filteredCategories
    }
    
}

