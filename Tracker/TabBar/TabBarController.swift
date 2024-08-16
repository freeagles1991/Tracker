//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Дима on 26.07.2024.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    private let trackersTabBarTitle = "Трекеры"
    private let statisticsTabBarTitle = "Статистика"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    private func setupViewControllers() {
        let trackersViewController = TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        
        trackersViewController.tabBarItem = UITabBarItem(title: trackersTabBarTitle, image: UIImage(systemName: "record.circle.fill"), tag: 0)
        statisticsViewController.tabBarItem = UITabBarItem(title: statisticsTabBarTitle, image: UIImage(systemName: "hare"), tag: 1)
        
        let navigationController = UINavigationController(rootViewController: trackersViewController)
        
        viewControllers = [navigationController, statisticsViewController]
    }
    
    private func setupTabBarAppearance() {
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .gray
    }
}

