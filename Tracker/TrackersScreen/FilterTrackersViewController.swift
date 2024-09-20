//
//  FilterTrackersViewController.swift
//  Tracker
//
//  Created by Дима on 19.09.2024.
//

import Foundation
import UIKit

final class FilterTrackersViewController: UIViewController {
    private let tableView = UITableView()
    private let tableContainerView = UIView()
    private var tableContainerViewHeightConstraint = NSLayoutConstraint()
    private var selectedIndexPath: IndexPath?
    var delegate: TrackersViewController?
    
    private var selectedFilter: FilterType = .allTrackers
    
    private var screenTitleLabel = UILabel()
    private let cellHeight: CGFloat = 75
    private let maxTableHeight: CGFloat = 500
    
    // Localized strings for the filter options
    private let filters = [
        NSLocalizedString("FilterTrackersScreen_AllTrackers", comment: "Все трекеры"),
        NSLocalizedString("FilterTrackersScreen_TodayTrackers", comment: "Трекеры на сегодня"),
        NSLocalizedString("FilterTrackersScreen_CompletedTrackers", comment: "Завершенные"),
        NSLocalizedString("FilterTrackersScreen_UncompletedTrackers", comment: "Не завершенные")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupScreenTitle()
        setupTableView()
        
        updateTableView()
    }
    
    private func setupScreenTitle() {
        let label = UILabel()
        let font = UIFont(name: "SFProText-Medium", size: 16)
        label.text = NSLocalizedString("FilterTrackersScreen_Title", comment: "Фильтры")
        label.textColor = .black
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 22),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.06)
        ])
        
        self.screenTitleLabel = label
    }
    
    private func setupTableView() {
        tableView.register(FilterCell.self, forCellReuseIdentifier: "filterCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        tableContainerView.addSubview(tableView)
        tableContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableContainerView)
        
        NSLayoutConstraint.activate([
            tableContainerView.topAnchor.constraint(equalTo: screenTitleLabel.bottomAnchor, constant: 30),
            tableContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: tableContainerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainerView.bottomAnchor),
        ])
        
        tableContainerViewHeightConstraint = tableContainerView.heightAnchor.constraint(equalToConstant: 300)
        tableContainerViewHeightConstraint.isActive = true
    }
    
    func setFilter(_ filter: FilterType) {
        self.selectedFilter = filter
        updateTableView()
    }
    
    //MARK: Private
    
    private func updateTableView() {
        switch selectedFilter {
        case .allTrackers:
            selectedIndexPath = IndexPath(row: 0, section: 0)
        case .todayTrackers:
            selectedIndexPath = IndexPath(row: 1, section: 0)
        case .completedTrackers:
            selectedIndexPath = IndexPath(row: 2, section: 0)
        case .uncompletedTrackers:
            selectedIndexPath = IndexPath(row: 3, section: 0)
        }
        
        tableView.reloadData()
    }
}


extension FilterTrackersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath) as? FilterCell else {
            return FilterCell()
        }
        
        let filterTitle = filters[indexPath.row]
        cell.configure(with: filterTitle, isSelected: indexPath == selectedIndexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousIndexPath = selectedIndexPath
        selectedIndexPath = indexPath
        
        let filterType: FilterType
        switch indexPath.row {
        case 0:
            filterType = .allTrackers
        case 1:
            filterType = .todayTrackers
        case 2:
            filterType = .completedTrackers
        case 3:
            filterType = .uncompletedTrackers
        default:
            return
        }
        
        selectedFilter = filterType
        delegate?.handleFilterSelection(filterType)
        
        var indexPathsToReload: [IndexPath] = [indexPath]
        if let previousIndexPath = previousIndexPath {
            indexPathsToReload.append(previousIndexPath)
        }
        
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}

final class FilterCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = UIColor(named: "background")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        accessoryType = isSelected ? .checkmark : .none
    }
}

