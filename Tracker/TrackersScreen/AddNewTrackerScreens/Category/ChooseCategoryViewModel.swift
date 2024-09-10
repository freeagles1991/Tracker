//
//  ChooseCategoryViewModel.swift
//  Tracker
//
//  Created by Дима on 10.09.2024.
//

typealias Binding<T> = (T) -> Void

import Foundation

final class ChooseCategoryViewModel {
    var categories: [TrackerCategory] = []
    var selectedCategory: TrackerCategory?
    
    private let trackersCategoryStore = TrackerCategoryStore.shared
    
    var onCategoriesUpdated: Binding<[TrackerCategory]>?
    var onCategorySelected: Binding<TrackerCategory?>?
    
    func loadCategories() {
        categories = trackersCategoryStore.categories
        onCategoriesUpdated?(categories)
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index]
        onCategorySelected?(selectedCategory)
    }
}
