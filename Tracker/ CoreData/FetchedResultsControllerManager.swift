////
////  FetchedResultsControllerManager.swift
////  Tracker
////
////  Created by Дима on 31.08.2024.
////
//
//import Foundation
//import CoreData
//import UIKit
//
//class FetchedResultsControllerManager: NSObject, NSFetchedResultsControllerDelegate {
//    
//    
//    
//    private init(managedObjectContext: NSManagedObjectContext) {
//        super.init()
//        setupFetchedResultsController()
//    }
//
//    // Перенести в TrackersStore и можно загружать загружать уже отфильтрованые по дате трекеры. Сделать в каждый Store по одному fetchedResultsController
//    
//    
//
//
//    // MARK: - NSFetchedResultsControllerDelegate
//
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        // Prepare UI for updates
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            // Handle insertion
//            break
//        case .delete:
//            // Handle deletion
//            break
//        case .update:
//            // Handle update
//            break
//        case .move:
//            // Handle move
//            break
//        @unknown default:
//            fatalError("Unknown change type encountered.")
//        }
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        // Finalize UI updates
//    }
//}
//
