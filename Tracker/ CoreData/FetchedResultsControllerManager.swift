//
//  FetchedResultsControllerManager.swift
//  Tracker
//
//  Created by Дима on 31.08.2024.
//

import Foundation
import CoreData
import UIKit

class FetchedResultsControllerManager: NSObject, NSFetchedResultsControllerDelegate {
    static let shared: FetchedResultsControllerManager = {
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        ?? NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        return FetchedResultsControllerManager(managedObjectContext: context)
    }()
    
    var fetchedResultsController: NSFetchedResultsController<TrackerCategoryEntity>!
    
    private override init() {
        super.init()
    }
    
    private init(managedObjectContext: NSManagedObjectContext) {
        super.init()
        setupFetchedResultsController(with: managedObjectContext)
    }

    private func setupFetchedResultsController(with context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<TrackerCategoryEntity> = TrackerCategoryEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
    
    var numberOfSections: Int {
           fetchedResultsController.sections?.count ?? 0
       }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func object(at indexPath: IndexPath) -> TrackerCategoryEntity? {
        fetchedResultsController.object(at: indexPath)
    }

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

