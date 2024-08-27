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
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    // Создание пустой категории трекеров
    public func createCategory(with category: TrackerCategory) {
        guard let categoryEntityDescription = NSEntityDescription.entity(forEntityName: "TrackerCategoryEntity", in: context) else {
            print("Failed to make categoryEntityDescription")
            return
        }
        
        let categoryEntity = TrackerCategoryEntity(entity: categoryEntityDescription, insertInto: context)
        categoryEntity.title = category.title
        
        appDelegate.saveContext()
    }
    
    // Загрузка всех категорий
    public func fetchCategories() -> [TrackerCategory] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryEntity")
        
        do {
            if let categoryEntities = try context.fetch(fetchRequest) as? [TrackerCategoryEntity] {
                return categoryEntities.compactMap { entity in
                    guard let title = entity.title,
                          let trackerEntities = entity.trackers?.allObjects as? [TrackerEntity] else {
                        return nil
                    }
                    
                    // Преобразуем трекеры из Core Data в массив трекеров
                    let trackers = trackerEntities.compactMap { trackerEntity in
                        return Tracker(id: trackerEntity.id!,
                                       title: trackerEntity.title!,
                                       color: trackerEntity.color!,
                                       emoji: trackerEntity.emoji!,
                                       schedule: trackerEntity.schedule as! [Weekday])
                    }
                    
                    return TrackerCategory(title: title, trackers: trackers)
                }
            }
        } catch {
            print("Ошибка при загрузке категорий: \(error.localizedDescription)")
        }
        
        return []
    }

    // Загрузка категории по названию
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
            
            // Преобразуем трекеры из Core Data в массив трекеров
            let trackers = trackerEntities.compactMap { trackerEntity in
                return Tracker(id: trackerEntity.id!,
                               title: trackerEntity.title!,
                               color: trackerEntity.color!,
                               emoji: trackerEntity.emoji!,
                               schedule: trackerEntity.schedule as! [Weekday])
            }
            
            return TrackerCategory(title: categoryEntity.title!, trackers: trackers)
            
        } catch {
            print("Ошибка при загрузке категории: \(error.localizedDescription)")
        }
        
        return nil
    }

    // Обновление категории
    public func updateCategory(with updatedCategory: TrackerCategory) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryEntity")
        fetchRequest.predicate = NSPredicate(format: "title == %@", updatedCategory.title)
        
        do {
            guard let categories = try context.fetch(fetchRequest) as? [TrackerCategoryEntity],
                  let categoryToUpdate = categories.first else {
                print("Категория не найдена")
                return
            }
            
            // Здесь можно обновить трекеры или другие данные категории
            
            // Сохраняем изменения в контексте
            try context.save()
            print("Категория успешно обновлена")
            
        } catch {
            print("Ошибка обновления категории: \(error.localizedDescription)")
        }
    }

    // Удаление категории
    public func deleteCategory(withTitle title: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryEntity")
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            guard let categories = try context.fetch(fetchRequest) as? [TrackerCategoryEntity],
                  let categoryToDelete = categories.first else {
                print("Категория не найдена")
                return
            }
            
            // Удаляем категорию из контекста
            context.delete(categoryToDelete)
            
            // Сохраняем изменения в контексте
            try context.save()
            print("Категория успешно удалена")
            
        } catch {
            print("Ошибка при удалении категории: \(error.localizedDescription)")
        }
    }
    // Получаем TrackerCategoryEntity
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
    // Фильтруем категории по дате
    public func filterTrackers(for date: Date) -> [TrackerCategory] {
        // Получаем все категории из хранилища
        let categories = fetchCategories()
        // Преобразуем дату в день недели
        guard let selectedWeekday = Weekday.fromDate(date) else {return []}
        
        var filteredCategories: [TrackerCategory] = []
        
        for category in categories {
            // Фильтруем трекеры по дню недели
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.schedule.contains(selectedWeekday)
            }
            
            // Если есть трекеры для этого дня, добавляем новую категорию с отфильтрованными трекерами
            if !filteredTrackers.isEmpty {
                let filteredCategory = TrackerCategory(title: category.title, trackers: filteredTrackers)
                filteredCategories.append(filteredCategory)
            }
        }
        
        return filteredCategories
    }

}

