//
//  CreateNewCategoryViewModel.swift
//  Tracker
//
//  Created by Дима on 11.09.2024.
//

import Foundation

final class CreateNewCategoryViewModel {
    weak var trackersCategoryStore: TrackerCategoryStore?
    
    var categoryName: String = "" {
        didSet {
            onCategoryNameChanged?(categoryName)
        }
    }
    
    var isDoneButtonEnabled: Bool {
        return !categoryName.isEmpty
    }
    
    var onCategoryNameChanged: Binding<String>?
    var onDoneButtonStateChanged: Binding<Bool>?
    
    func createNewCategory() {
        guard !categoryName.isEmpty else { return }
        let newCategory = TrackerCategory(title: categoryName, trackers: [])
        trackersCategoryStore?.createCategory(with: newCategory)
    }
    
    func updateDoneButtonState() {
        onDoneButtonStateChanged?(isDoneButtonEnabled)
    }
}
