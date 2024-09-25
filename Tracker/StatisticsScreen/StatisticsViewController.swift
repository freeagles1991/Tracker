//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Дима on 26.07.2024.
//

import Foundation
import UIKit

final class StatisticsViewController: UIViewController {
    private let trackersStore = TrackerStore.shared
    private let trackerRecordStore = TrackerRecordStore.shared
    private let statisticsStore: StatisticsStore
    
    private let screenTitleString = "Статистика"
    private let emptyStateString = "Анализировать пока нечего"
    
    private let tableView = UITableView()
    private var emptyStateView = UIView()
    
    enum StatisticListString: String, CaseIterable {
        case best_period
        case perfect_days
        case trackers_complete
        case average

        var localized: String {
            switch self {
            case .best_period:
                return NSLocalizedString("StatisticsScreen_best_period", comment: "Лучший период")
            case .perfect_days:
                return NSLocalizedString("StatisticsScreen_perfect_days", comment: "Идеальные дни")
            case .trackers_complete:
                return NSLocalizedString("StatisticsScreen_trackers_complete", comment: "Трекеров завершено")
            case .average:
                return NSLocalizedString("StatisticsScreen_average", comment: "Среднее значение")
            }
        }
    }
    
    private var perfectDaysCount = 0
    private var trackersCompleteCount = 0
    private var averageCount = 0
    private var bestPeriodCount = 0
    
    init(statisticStore: StatisticsStore) {
        self.statisticsStore = statisticStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "white")
        setupNavigationBar()
        setupTableView()
        setupEmptyStateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        getStatisticsData()
        updateUI()
    }
    
    private func setupEmptyStateView() {
        let emptyStateView = UIView()
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        
        let imageView = UIImageView(image: UIImage(named: "emptyStatisticsIcon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(imageView)
        
        let label = UILabel()
        label.text = emptyStateString
        label.font = UIFont(name: "SFProText-Medium", size: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(label)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
        
        self.emptyStateView = emptyStateView
    }
    
    private func setupNavigationBar() {
        navigationItem.title = screenTitleString
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SatisticsCell.self, forCellReuseIdentifier: "SatisticsCell")
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    //MARK: Private
    
    private func getStatisticsData() {
        guard let erliestRecord = trackerRecordStore.fetchEarliestTrackerRecord()?.date else { 
            perfectDaysCount = 0
            averageCount = 0
            bestPeriodCount = 0
            trackersCompleteCount = 0
            return }
        
        perfectDaysCount = statisticsStore.fetchPerfectDaysCount(from: erliestRecord)
        averageCount = statisticsStore.fetchAverageTrackersPerDay(from: erliestRecord)
        bestPeriodCount = statisticsStore.fetchBestPeriod(from: erliestRecord)
        trackersCompleteCount = statisticsStore.fetchAllRecordsCount()
    }
    
    private func updateUI() {
        emptyStateView.isHidden = isStatisticsEmpty() ? false : true
        tableView.isHidden = isStatisticsEmpty() ? true : false
        print(isStatisticsEmpty())
    }
    
    private func isStatisticsEmpty() -> Bool {
        if perfectDaysCount == 0,
           trackersCompleteCount == 0,
           averageCount == 0,
           bestPeriodCount == 0 {
            return true
        } else {
            return false
        }
    }
}

extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StatisticListString.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SatisticsCell", for: indexPath) as! SatisticsCell
        let statisticType: StatisticListString
        var counter = 0
        switch indexPath.row {
        case 0:
            statisticType = .best_period
            counter = bestPeriodCount
        case 1:
            statisticType = .perfect_days
            counter = perfectDaysCount
        case 2:
            statisticType = .trackers_complete
            counter = trackersCompleteCount
        case 3:
            statisticType = .average
            counter = averageCount
        default:
            statisticType = .average
            counter = 0
        }
        
        let description = statisticType.localized
        let number = counter
        cell.configure(with: String(describing: number), description: description)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let statisticsCell = cell as? SatisticsCell {
            statisticsCell.setupGradientFill()
        }
    }
}


