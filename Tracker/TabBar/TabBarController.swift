//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Дима on 26.07.2024.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    private let trackersTabBarTitle = NSLocalizedString("TabBar_trackersTabBarTitle", comment: "Трекеры")
    private let statisticsTabBarTitle = NSLocalizedString("TabBar_statisticsTabBarTitle", comment: "Статистика")
    private let customTabBarHeight: CGFloat = 90.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var tabBarFrame = tabBar.frame
        tabBarFrame.size.height = customTabBarHeight
        tabBarFrame.origin.y = view.frame.height - customTabBarHeight
        tabBar.frame = tabBarFrame
    }
    
    private func setupViewControllers() {
        let trackerStore = TrackerStore()
        let trackerCategoryStore = TrackerCategoryStore()
        let trackerRecordStore = TrackerRecordStore()
        
        let trackersViewController = TrackersViewController(trackerStore: trackerStore, trackerCatergoryStore: trackerCategoryStore, trackerRecordStore: trackerRecordStore, analiticsService: AnalyticsService())
        
        let statisticsViewController = StatisticsViewController(trackerStore: trackerStore, trackerRecordStore: trackerRecordStore, statisticStore: StatisticsStore())
        
        trackersViewController.tabBarItem = UITabBarItem(title: trackersTabBarTitle, image: UIImage(systemName: "record.circle.fill"), tag: 0)
        statisticsViewController.tabBarItem = UITabBarItem(title: statisticsTabBarTitle, image: UIImage(systemName: "hare"), tag: 1)
        
        let navigationControllerTrackers = UINavigationController(rootViewController: trackersViewController)
        let navigationControllerStatistics = UINavigationController(rootViewController: statisticsViewController)
        
        
        viewControllers = [navigationControllerTrackers, navigationControllerStatistics]
    }
    
    private func setupTabBarAppearance() {
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .gray
        tabBar.addTopBorder(with: .gray, andHeight: 1.0)
    }
}

