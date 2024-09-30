//
//  ChooseCategoryViewModel.swift
//  Tracker
//
//  Created by Дима on 10.09.2024.
//

import Foundation

final class ChooseCategoryViewModel {
    var categories: [TrackerCategory] = []
    var selectedCategory: TrackerCategory?
    
    weak var trackersCategoryStore: TrackerCategoryStore?
    
    var onCategoriesUpdated: Binding<[TrackerCategory]>?
    var onCategorySelected: Binding<TrackerCategory?>?
    
    func loadCategories() {
        guard let trackersCategoryStore else { return} 
        categories = trackersCategoryStore.categories
        onCategoriesUpdated?(categories)
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index]
        onCategorySelected?(selectedCategory)
    }
}
