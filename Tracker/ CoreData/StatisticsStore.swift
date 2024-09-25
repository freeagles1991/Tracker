//
//  StatisticsStore.swift
//  Tracker
//
//  Created by Дима on 25.09.2024.
//

import Foundation
import CoreData
import UIKit

final class StatisticsStore {
    var fetchedResultsController: NSFetchedResultsController<TrackerEntity>?
    private let trackerStore = TrackerStore.shared
    
    private var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("UIApplication.shared.delegate is not of type AppDelegate")
        }
        return delegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    //MARK: Настраиваем FRC
    func setupFetchedResultsController(_ predicate: NSPredicate, with trackerTitlePredicate: NSPredicate? = nil) {
        let fetchRequest: NSFetchRequest<TrackerEntity> = TrackerEntity.fetchRequest()
        
        fetchRequest.sortDescriptors = [
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
    
    //MARK: Завершенные трекеры
    public func fetchAllRecordsCount() -> Int {
        let allRecordsPredicate = NSPredicate(format: "records.@count > 0")
        
        self.setupFetchedResultsController(allRecordsPredicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            print("No fetched objects found")
            return 0
        }
        
        var totalRecordsCount = 0
        for trackerEntity in fetchedObjects {
            if let records = trackerEntity.records?.count {
                totalRecordsCount += records
            } else {
                print("No records found for tracker entity: \(trackerEntity)")
            }
        }
        
        return totalRecordsCount
    }
    
    //MARK: Идеальные дни
    public func fetchPerfectDaysCount(from earliestDate: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var dates: [Date] = []
        var currentDate = calendar.startOfDay(for: earliestDate)
        
        while currentDate <= today {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        let scheduledDates = dates.filter { date in
            guard let selectedWeekday = Weekday.fromDate(date) else { return false }
            let predicate = NSPredicate(format: "schedule CONTAINS[cd] %@", selectedWeekday.rawValue)
            self.setupFetchedResultsController(predicate)
            
            let hasScheduledTrackers = fetchedResultsController?.fetchedObjects?.isEmpty == false
            return hasScheduledTrackers
        }
        
        var perfectDays = scheduledDates.filter { date in
            return trackerStore.fetchIncompleteTrackers(by: date)?.isEmpty ?? false
        }
        
        if let selectedWeekday = Weekday.fromDate(today) {
            let predicate = NSPredicate(format: "schedule CONTAINS[cd] %@", selectedWeekday.rawValue)
            self.setupFetchedResultsController(predicate)
            
            let hasScheduledTrackers = fetchedResultsController?.fetchedObjects?.isEmpty == false
            if hasScheduledTrackers {
                let incompleteTrackersToday = trackerStore.fetchIncompleteTrackers(by: today)?.isEmpty ?? false
                if incompleteTrackersToday {
                    perfectDays.append(today)
                }
            }
        }
        
        return perfectDays.count
    }
    
    //MARK: Среднее значение
    public func fetchAverageTrackersPerDay(from earliestDate: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var dates: [Date] = []
        var currentDate = calendar.startOfDay(for: earliestDate)
        
        while currentDate <= today {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        let totalRecordsCount = fetchAllRecordsCount()
        
        let daysCount = dates.count
        guard daysCount > 0 else { return 0 } // Защита от деления на ноль
        
        let averageTrackersPerDay = Double(totalRecordsCount) / Double(daysCount)
        
        return Int(round(averageTrackersPerDay))
    }
    
    //MARK: Лучший период
    public func fetchBestPeriod(from earliestDate: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var dates: [Date] = []
        var currentDate = calendar.startOfDay(for: earliestDate)
        
        // Создаем массив дат от earliestDate до текущего дня
        while currentDate <= today {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        var bestPeriod = 0
        var currentStreak = 0
        
        // Проверяем каждый день на соответствие расписанию и выполненные трекеры
        for date in dates {
            guard let completedTrackers = trackerStore.fetchCompleteTrackers(by: date) else {
                // Если нет выполненных трекеров, сбрасываем текущую последовательность
                currentStreak = 0
                continue
            }
            
            // Если на день нет запланированных трекеров, пропускаем день
            guard !completedTrackers.isEmpty else {
                continue
            }
            
            var allTrackersMatch = true
            for tracker in completedTrackers {
                let schedule = tracker.schedule
                guard let selectedWeekday = Weekday.fromDate(date) else { return 0 }
                
                // Если трекер запланирован на этот день, но не выполнен, сбрасываем последовательность
                if !schedule.contains(selectedWeekday) {
                    allTrackersMatch = false
                    break
                }
            }
            
            if allTrackersMatch {
                // Если все запланированные трекеры выполнены, увеличиваем текущую последовательность
                currentStreak += 1
                bestPeriod = max(bestPeriod, currentStreak)
            } else {
                // Сбрасываем последовательность, если трекеры не выполнены
                currentStreak = 0
            }
        }
        
        return bestPeriod
    }
}
