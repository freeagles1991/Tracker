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
    
    private var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("UIApplication.shared.delegate is not of type AppDelegate")
        }
        return delegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    var fetchedResultsController: NSFetchedResultsController<TrackerEntity>?
    weak var trackersVC: TrackersViewControllerProtocol?
    private var lastUsedPredicate: NSPredicate = NSPredicate()
    
    //MARK: Public
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
    
    override init() {
        super.init()
        let predicate = NSPredicate(value: true)
        setupFetchedResultsController(predicate)
    }
    
    // MARK: Настраиваем FRC
    func setupFetchedResultsController(_ predicate: NSPredicate) {
        let fetchRequest: NSFetchRequest<TrackerEntity> = TrackerEntity.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        lastUsedPredicate = predicate
        
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "pinnedOrCategory",
            cacheName: nil
        )
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Не удалось выполнить выборку данных: \(error)")
        }
    }
    
    // MARK: Обновляем предикат в FRC
    func updateFetchedResultsController(with predicate: NSPredicate, trackerTitlePredicate: NSPredicate? = nil) {
        
        lastUsedPredicate = predicate

        let combinedPredicate = combinePredicates(basePredicate: predicate, titlePredicate: trackerTitlePredicate)

        fetchedResultsController?.fetchRequest.predicate = combinedPredicate
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Ошибка при выполнении выборки: \(error)")
        }
    }
    
    // MARK: Объединяем предикаты
    private func combinePredicates(basePredicate: NSPredicate, titlePredicate: NSPredicate?) -> NSPredicate {
        if let titlePredicate = titlePredicate {
            return NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicate, titlePredicate])
        } else {
            return basePredicate
        }
    }
    
    //MARK: Поиск трекеров
    func searchTracker(with title: String) -> [Tracker]? {
        let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", title)
        
        if title != "" {
            updateFetchedResultsController(with: lastUsedPredicate, trackerTitlePredicate: titlePredicate)
        } else {
            updateFetchedResultsController(with: lastUsedPredicate)
        }
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        
        let trackers = fetchedObjects.compactMap { trackerEntity in
            return convertEntityToTracker(trackerEntity)
        }
        
        return trackers
    }
    
    //MARK: TrackerEntity to Tracker
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
    
    //MARK: Все трекеры
    public func fetchTrackers() -> [Tracker]? {
        let predicate = NSPredicate(value: true)
        
        self.updateFetchedResultsController(with: predicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        
        return fetchedObjects.compactMap { trackerEntity in
            convertEntityToTracker(trackerEntity)
        }
    }
    
    //MARK: Фильтруем трекеры по дате
    public func fetchTrackers(by date: Date) -> [Tracker]? {
        guard let selectedWeekday = Weekday.fromDate(date) else { return [] }
        
        let predicate = NSPredicate(format: "schedule CONTAINS[cd] %@", selectedWeekday.rawValue)
        
        self.updateFetchedResultsController(with: predicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        
        return fetchedObjects.compactMap { trackerEntity in
            convertEntityToTracker(trackerEntity)
        }
    }
    //MARK: Завершенные трекеры
    public func fetchCompleteTrackers(by date: Date) -> [Tracker]? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let hasRecordForExactDatePredicate = NSPredicate(format: "SUBQUERY(records, $record, $record.date >= %@ AND $record.date < %@).@count > 0", startOfDay as NSDate, endOfDay as NSDate)
        
        guard let selectedWeekday = Weekday.fromDate(date) else {
            return []
        }
        
        let scheduledOnDayPredicate = NSPredicate(format: "schedule CONTAINS[cd] %@", selectedWeekday.rawValue)
        
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [hasRecordForExactDatePredicate, scheduledOnDayPredicate])
        
        self.updateFetchedResultsController(with: combinedPredicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        
        return fetchedObjects.compactMap { trackerEntity in
            convertEntityToTracker(trackerEntity)
        }
    }
    
    //MARK: Незавершенные трекеры
    public func fetchIncompleteTrackers(by date: Date) -> [Tracker]? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let noRecordForDatePredicate = NSPredicate(format: "SUBQUERY(records, $record, $record.date >= %@ AND $record.date < %@).@count == 0", startOfDay as NSDate, endOfDay as NSDate)
        
        guard let selectedWeekday = Weekday.fromDate(date) else {
            return []
        }
        
        let scheduledOnDayPredicate = NSPredicate(format: "schedule CONTAINS[cd] %@", selectedWeekday.rawValue)
        
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [noRecordForDatePredicate, scheduledOnDayPredicate])
        
        self.updateFetchedResultsController(with: combinedPredicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        
        return fetchedObjects.compactMap { trackerEntity in
            convertEntityToTracker(trackerEntity)
        }
    }
    
    //MARK: Получаем TrackerEntity
    public func fetchTrackerEntity(_ id: UUID) -> TrackerEntity? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        self.updateFetchedResultsController(with: predicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return TrackerEntity()
        }

        let trackerEntity = fetchedObjects.first

        return trackerEntity

    }
    
    //MARK: Создаем трекер
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
    
    //MARK: Обновляем трекер
    func updateTracker(for tracker: Tracker, to newCategory: TrackerCategoryEntity? = nil) {
        let predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        self.updateFetchedResultsController(with: predicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects,
              let trackerEntity = fetchedObjects.first else {
            print("Tracker not found")
            return
        }
        
        trackerEntity.title = tracker.title
        trackerEntity.emoji = tracker.emoji
        trackerEntity.scheduleArray = tracker.schedule
        trackerEntity.color = tracker.color
        trackerEntity.isPinned = tracker.isPinned
        
        if let newCategory = newCategory {
            if let oldCategory = trackerEntity.category {
                oldCategory.removeFromTrackers(trackerEntity)
            }

            trackerEntity.category = newCategory
            newCategory.addToTrackers(trackerEntity)
        }
        
        appDelegate.saveContext()
    }
    
    //MARK: Удаляем трекер
    public func removeTracker(with id: UUID) {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        self.updateFetchedResultsController(with: predicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects,
                let trackerEntity = fetchedObjects.first else {
            return
        }

        context.delete(trackerEntity)
        appDelegate.saveContext()
    }
    
}

