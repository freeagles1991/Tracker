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
        // Создаем контроллеры для табов
        let trackersViewController = TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        
        // Настраиваем табы
        trackersViewController.tabBarItem = UITabBarItem(title: trackersTabBarTitle, image: UIImage(systemName: "record.circle.fill"), tag: 0)
        statisticsViewController.tabBarItem = UITabBarItem(title: statisticsTabBarTitle, image: UIImage(systemName: "hare"), tag: 1)
        
        let navigationController = UINavigationController(rootViewController: trackersViewController)
        
        // Добавляем контроллеры в TabBarController
        viewControllers = [navigationController, statisticsViewController]
    }
    
    private func setupTabBarAppearance() {
        // Устанавливаем цвет для активного таба
        tabBar.tintColor = .systemBlue // Цвет активного таба
        tabBar.unselectedItemTintColor = .gray // Цвет неактивных табов (опционально)
    }
}

