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
                NSSortDescriptor(key: "category.title", ascending: true),
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
    
    public func fetchTrackers() -> [Tracker]? {
        let predicate = NSPredicate(value: true)
        
        self.setupFetchedResultsController(predicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        
        return fetchedObjects.compactMap { trackerEntity in
            convertEntityToTracker(trackerEntity)
        }
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
    
    public func fetchCompleteTrackers(by date: Date) -> [Tracker]? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        print("=== Поиск завершенных трекеров за дату ===")
        print("Дата начала: \(startOfDay), Дата конца: \(endOfDay)")
        
        // Предикат для трекеров с записями за указанную дату
        let hasRecordForDatePredicate = NSPredicate(format: "ANY records.date >= %@ AND ANY records.date < %@", startOfDay as NSDate, endOfDay as NSDate)
        print("Создан предикат для трекеров с записями за указанную дату")
        
        // Предикат для трекеров, запланированных на день недели
        guard let selectedWeekday = Weekday.fromDate(date) else {
            print("Не удалось определить день недели для даты")
            return []
        }
        let scheduledOnDayPredicate = NSPredicate(format: "schedule CONTAINS[cd] %@", selectedWeekday.rawValue)
        print("Создан предикат для трекеров, запланированных на \(selectedWeekday.rawValue)")
        
        // Комбинированный предикат (и трекер имеет запись, и запланирован на день недели)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [hasRecordForDatePredicate, scheduledOnDayPredicate])
        print("Создан объединенный предикат для трекеров, имеющих записи и запланированных на день недели")
        
        // Настройка FetchedResultsController с комбинированным предикатом
        self.setupFetchedResultsController(combinedPredicate)
        print("FetchedResultsController настроен с комбинированным предикатом")
        
        // Получаем результаты
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            print("Не найдено завершенных трекеров")
            return []
        }
        
        print("Найдено \(fetchedObjects.count) завершенных трекеров за указанную дату")
        
        // Конвертация сущностей трекеров в объекты Tracker
        let completeTrackers = fetchedObjects.compactMap { trackerEntity in
            convertEntityToTracker(trackerEntity)
        }
        
        print("Возвращено \(completeTrackers.count) завершенных трекеров")
        print("=== Конец поиска трекеров ===")
        
        return completeTrackers
    }
    
    public func fetchIncompleteTrackers(by date: Date) -> [Tracker]? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        print("=== Поиск незавершенных трекеров за дату ===")
        print("Дата начала: \(startOfDay), Дата конца: \(endOfDay)")
        
        // Предикат для отсутствия записей за указанную дату
        let noRecordForDatePredicate = NSPredicate(format: "SUBQUERY(records, $record, $record.date >= %@ AND $record.date < %@).@count == 0", startOfDay as NSDate, endOfDay as NSDate)
        print("Создан предикат для отсутствия записей за указанную дату")
        
        // Предикат для того, чтобы трекеры были запланированы на конкретный день
        guard let selectedWeekday = Weekday.fromDate(date) else {
            print("Не удалось определить день недели для даты")
            return []
        }
        let scheduledOnDayPredicate = NSPredicate(format: "schedule CONTAINS[cd] %@", selectedWeekday.rawValue)
        print("Создан предикат для трекеров, запланированных на \(selectedWeekday.rawValue)")
        
        // Комбинированный предикат (и трекер запланирован, и нет записей за указанную дату)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [noRecordForDatePredicate, scheduledOnDayPredicate])
        print("Создан объединенный предикат для трекеров, запланированных на день и не имеющих записей за этот день")
        
        // Настройка FetchedResultsController с комбинированным предикатом
        self.setupFetchedResultsController(combinedPredicate)
        print("FetchedResultsController настроен с комбинированным предикатом")
        
        // Получаем результаты
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            print("Не найдено незавершенных трекеров")
            return []
        }
        
        print("Найдено \(fetchedObjects.count) незавершенных трекеров за указанную дату")
        
        // Конвертация сущностей трекеров в объекты Tracker
        let incompleteTrackers = fetchedObjects.compactMap { trackerEntity in
            convertEntityToTracker(trackerEntity)
        }
        
        print("Возвращено \(incompleteTrackers.count) незавершенных трекеров")
        print("=== Конец поиска трекеров ===")
        
        return incompleteTrackers
    }
    
    public func fetchAllRecordsCount() -> Int {
        let allRecordsPredicate = NSPredicate(format: "records.@count > 0")
        
        self.setupFetchedResultsController(allRecordsPredicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            print("No fetched objects found")
            return 0
        }
        
        print("Fetched \(fetchedObjects.count) tracker entities with records")
        
        var totalRecordsCount = 0
        for trackerEntity in fetchedObjects {
            if let records = trackerEntity.records?.count {
                totalRecordsCount += records
            } else {
                print("No records found for tracker entity: \(trackerEntity)")
            }
        }
        
        print("Total records count: \(totalRecordsCount)")
        return totalRecordsCount
    }
    
    public func fetchPerfectDaysCount(from earliestDate: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date()) // Начало текущего дня
        
        print("=== Старт расчета идеальных дней ===")
        print("Рассматриваем даты от: \(earliestDate) до: \(today)")
        
        // 1. Создаем массив дат в диапазоне от earliestDate до сегодняшнего дня
        var dates: [Date] = []
        var currentDate = calendar.startOfDay(for: earliestDate)
        
        while currentDate <= today {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        print("Создано \(dates.count) дат для проверки.")
        
        // 2. Фильтруем даты, на которые запланированы трекеры
        let scheduledDates = dates.filter { date in
            guard let selectedWeekday = Weekday.fromDate(date) else { return false }
            let predicate = NSPredicate(format: "schedule CONTAINS[cd] %@", selectedWeekday.rawValue)
            self.setupFetchedResultsController(predicate)
            
            let hasScheduledTrackers = fetchedResultsController?.fetchedObjects?.isEmpty == false
            print("Дата: \(date), Запланированные трекеры: \(hasScheduledTrackers ? "Есть" : "Нет")")
            return hasScheduledTrackers
        }
        
        print("Найдено \(scheduledDates.count) дат с запланированными трекерами.")
        
        // 3. Проверяем, является ли день "идеальным" (нет незавершенных трекеров)
        var perfectDays = scheduledDates.filter { date in
            let incompleteTrackers = fetchIncompleteTrackers(by: date)?.isEmpty ?? false
            print("Дата: \(date), Незавершенные трекеры: \(incompleteTrackers ? "Нет" : "Есть")")
            return incompleteTrackers
        }
        
        // 4. Добавляем текущий день в расчет
        if !scheduledDates.contains(today) {
            let incompleteTrackersToday = fetchIncompleteTrackers(by: today)?.isEmpty ?? false
            print("Текущая дата: \(today), Незавершенные трекеры: \(incompleteTrackersToday ? "Нет" : "Есть")")
            
            if incompleteTrackersToday {
                print("Текущий день добавлен как идеальный.")
                perfectDays.append(today)
            }
        }
        
        print("Найдено \(perfectDays.count) идеальных дней.")
        
        // 5. Возвращаем количество "идеальных дней"
        print("=== Конец расчета идеальных дней ===")
        return perfectDays.count
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
