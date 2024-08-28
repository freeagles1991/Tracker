//
//  TrackerStore.swift
//  Tracker
//
//  Created by Дима on 24.08.2024.
//

import Foundation
import CoreData
import UIKit

final class TrackerStore{
    static let shared = TrackerStore()
    private init() {}
    
    private let trackerCategoryStore = TrackerCategoryStore.shared
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    // Создаем трекер и добавляем его в категорию
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
        
        // Добавляем трекер в категорию
        trackerEntity.category = category
        category.addToTrackers(trackerEntity)
        
        appDelegate.saveContext()
    }
    
    //Загружаем список трекеров
    public func fetchTrackers() -> [Tracker] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerEntity")
        
        do {
            // Выполняем запрос к базе данных и приводим результат к массиву TrackerEntity
            if let trackerEntities = try context.fetch(fetchRequest) as? [TrackerEntity] {
                // Преобразуем каждую TrackerEntity в ваш тип данных Tracker
                return trackerEntities.compactMap { entity in
                    guard let id = entity.id,
                          let title = entity.title,
                          let color = entity.color,
                          let emoji = entity.emoji,
                          let schedule = entity.schedule as? [Weekday] else {
                        return nil
                    }
                    return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
                }
            }
        } catch {
            print("Ошибка при загрузке трекеров: \(error.localizedDescription)")
        }
        return []
    }

    //Загружаем указанный трекер
    public func fetchTracker(_ id: UUID) -> Tracker? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            // Выполняем запрос к базе данных
            guard let trackerEntities = try context.fetch(fetchRequest) as? [TrackerEntity],
                  let trackerEntity = trackerEntities.first else {
                return nil
            }
            
            // Преобразуем NSManagedObject в ваш тип Tracker
            let tracker = Tracker(id: trackerEntity.id!,
                                  title: trackerEntity.title!,
                                  color: trackerEntity.color!,
                                  emoji: trackerEntity.emoji!,
                                  schedule: trackerEntity.schedule as! [Weekday])
            return tracker
            
        } catch {
            print("Ошибка при загрузке трекера: \(error.localizedDescription)")
        }
        return nil
    }
    
    //Загружаем указанный трекер Entity
    public func fetchTrackerEntity(_ id: UUID) -> TrackerEntity? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            // Выполняем запрос к базе данных
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

    //Обновляем трекер
    public func updateTracker(with updatedTracker: Tracker) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", updatedTracker.id as CVarArg)
        
        do {
            // Выполняем запрос для получения трекера, который необходимо обновить
            guard let trackers = try context.fetch(fetchRequest) as? [NSManagedObject],
                  let trackerToUpdate = trackers.first else {
                print("Трекер не найден")
                return
            }
            
            // Обновляем поля трекера
            trackerToUpdate.setValue(updatedTracker.title, forKey: "title")
            trackerToUpdate.setValue(updatedTracker.emoji, forKey: "emoji")
            trackerToUpdate.setValue(updatedTracker.schedule as NSObject, forKey: "schedule")
            trackerToUpdate.setValue(updatedTracker.color, forKey: "color")
            
            // Сохраняем изменения в контексте
            try context.save()
            print("Трекер успешно обновлен")
            
        } catch {
            print("Ошибка обновления трекера: \(error.localizedDescription)")
        }
    }
    //Удаляем трекер
    public func deleteTracker(with id: UUID) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            // Выполняем запрос для получения трекера, который необходимо удалить
            guard let trackers = try context.fetch(fetchRequest) as? [NSManagedObject],
                  let trackerToDelete = trackers.first else {
                print("Трекер не найден")
                return
            }
            
            // Удаляем трекер из контекста
            context.delete(trackerToDelete)
            
            // Сохраняем изменения в контексте
            try context.save()
            print("Трекер успешно удален")
            
        } catch {
            print("Ошибка при удалении трекера: \(error.localizedDescription)")
        }
    }

}
