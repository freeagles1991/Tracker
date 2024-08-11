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
    
    // MARK: - Trackers
    
    var trackers: [Tracker] {
        get {
            // Получаем данные из UserDefaults
            if let data = UserDefaults.standard.data(forKey: trackersKey),
               let decodedTrackers = try? JSONDecoder().decode([Tracker].self, from: data) {
                return decodedTrackers
            }
            return []
        }
        set {
            // Сохраняем данные в UserDefaults
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: trackersKey)
            }
        }
    }
    
    // MARK: - Categories
    
    var categories: [TrackerCategory] {
        get {
            // Получаем данные из UserDefaults
            if let data = UserDefaults.standard.data(forKey: categoriesKey),
               let decodedCategories = try? JSONDecoder().decode([TrackerCategory].self, from: data) {
                return decodedCategories
            }
            return []
        }
        set {
            // Сохраняем данные в UserDefaults
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: categoriesKey)
            }
        }
    }
    
    // MARK: - Добавление/Удаление трекеров и категорий
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
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
            // Удаляем категорию, если в ней больше нет трекеров
            if updatedCategories[index].trackers.isEmpty {
                updatedCategories.remove(at: index)
            }
        }
        categories = updatedCategories
    }
    
    func removeAllCategoriesExceptFirst() {
        guard categories.count > 1 else { return } // Если есть только одна категория, ничего не делаем
        categories = [categories[0]] // Оставляем только первую категорию
    }
}

