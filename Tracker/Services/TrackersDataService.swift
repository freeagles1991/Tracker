//
//  TrackersDataService.swift
//  Tracker
//
//  Created by Дима on 10.08.2024.
//

import Foundation

class TrackerDataService {
    static let shared = TrackerDataService()
    private init() {}
    
    private let trackersKey = "trackers"
    private let categoriesKey = "categories"
    private let recordsKey = "records"
    
    // MARK: - Trackers
    
    var trackers: [Tracker] {
        get {
            if let data = UserDefaults.standard.data(forKey: trackersKey),
               let decodedTrackers = try? JSONDecoder().decode([Tracker].self, from: data) {
                return decodedTrackers
            }
            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: trackersKey)
            }
        }
    }
    
    // MARK: - Categories
    
    var categories: [TrackerCategory] {
        get {
            if let data = UserDefaults.standard.data(forKey: categoriesKey),
               let decodedCategories = try? JSONDecoder().decode([TrackerCategory].self, from: data) {
                return decodedCategories
            }
            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: categoriesKey)
            }
        }
    }
    
    // MARK: - Records (новая логика для хранения записей)
    
    var records: [TrackerRecord] {
        get {
            if let data = UserDefaults.standard.data(forKey: recordsKey),
               let decodedRecords = try? JSONDecoder().decode([TrackerRecord].self, from: data) {
                return decodedRecords
            }
            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: recordsKey)
            }
        }
    }
    
    // MARK: - Добавление/Удаление трекеров и категорий
    
    func addTracker(_ tracker: Tracker, toCategory categoryTitle: String) {
        var updatedCategories = categories
        if let index = updatedCategories.firstIndex(where: { $0.title == categoryTitle }) {
            updatedCategories[index].trackers.append(tracker)
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            updatedCategories.append(newCategory)
        }
        categories = updatedCategories
    }
    
    func removeTracker(_ tracker: Tracker, from categoryTitle: String) {
        var updatedCategories = categories
        if let index = updatedCategories.firstIndex(where: { $0.title == categoryTitle }) {
            updatedCategories[index].trackers.removeAll { $0.id == tracker.id }
            if updatedCategories[index].trackers.isEmpty {
                updatedCategories.remove(at: index)
            }
        }
        categories = updatedCategories
    }
    
    func removeAllCategoriesExceptFirst() {
        guard categories.count > 1 else { return }
        categories = [categories[0]]
    }
    
    // MARK: - Добавление/Удаление записей трекеров
    
    func addRecord(for tracker: Tracker, on date: Date) {
        var updatedRecords = records
        let newRecord = TrackerRecord(trackerID: tracker.id, date: date)
        updatedRecords.append(newRecord)
        records = updatedRecords
        print("Запись трекера \(tracker.title) выполнена")
    }
    
    func removeRecord(for tracker: Tracker, on date: Date) {
        var updatedRecords = records
        updatedRecords.removeAll { $0.trackerID == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date) }
        records = updatedRecords
        print("Запись трекера \(tracker.title) удалена")
    }
    
    func isTrackerCompleted(_ tracker: Tracker) -> Bool {
        return records.contains { $0.trackerID == tracker.id }
    }
    
    func numberOfRecords(for tracker: Tracker) -> Int {
        return records.filter { $0.trackerID == tracker.id }.count
    }
    
    func removeAllData() {
        trackers = []
        categories = []
        records = []
        
        print("Все трекеры, категории и записи были удалены")
    }
}


