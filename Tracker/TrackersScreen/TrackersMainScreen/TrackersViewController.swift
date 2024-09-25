//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Дима on 26.07.2024.
//

import Foundation
import UIKit

final class TrackersViewController: UIViewController {
    let analiticsService: AnalyticsService
    let trackerStore = TrackerStore.shared
    private var trackers: [Tracker]?
    private let trackerCategoryStore = TrackerCategoryStore.shared
    private let trackerRecordStore = TrackerRecordStore.shared
    private let chooseTrackerTypeVC =  ChooseTrackerTypeViewController()
    private let filterTrackersVC = FilterTrackersViewController()
    
    private var datePicker = UIDatePicker()
    private var selectedDate: Date? = Date()

    private var emptyStateView = UIView()
    private var nothingFoundStateView = UIView()
    private var searchBar = UISearchBar()
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 9
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(named: "white")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private let filterButton: UIButton = {
            let button = UIButton(type: .system)
        button.setTitle(TrackersMainScreenConst.filtersButtonString, for: .normal)
        button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.backgroundColor = UIColor(named: "blue")
            button.layer.cornerRadius = 16
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
    
    enum TrackerContextMenu: String {
        case pinTrackerString = "TrackerContextMenu_PinTracker"
        case unpinTrackerString = "TrackerContextMenu_UnpinTracker"
        case editTrackerString = "TrackerContextMenu_EditTracker"
        case deleteTrackerString = "TrackerContextMenu_DeleteTracker"

        var localized: String {
            return NSLocalizedString(self.rawValue, comment: "")
        }
    }
    
    enum TrackersMainScreenConst {
        static let navBarTitleString = NSLocalizedString("TrackersMainScreen_NavBarTitle", comment: "Трекеры")
        static let emptyStateViewString = NSLocalizedString("TrackersMainScreen_EmptyStateView", comment: "Что будем отслеживать?")
        static let searchBarPlaceholderString = NSLocalizedString("TrackersMainScreen_SearchBarPlaceholder", comment: "Поиск")
        static let filtersButtonString = NSLocalizedString("TrackersMainScreen_FiltersButton", comment: "Фильтры")
        static let pinnedSectionString = NSLocalizedString("TrackersMainScreen_PinnedSection", comment: "Закрепленные")
        static let nothingFoundString = NSLocalizedString("TrackersMainScreen_NothingFound", comment: "Ничего не найдено")
    }
    
    let itemsPerRow: CGFloat = 2
    let sectionInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    let interItemSpacing: CGFloat = 9
    
    init(analiticsService: AnalyticsService) {
        self.analiticsService = analiticsService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "white")
        
        trackerStore.trackersVC = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setupNavigationBar()
        setupSearchBar()
        setupEmptyStateView()
        setupNothingFoundStateView()
        setupCollectionView()
        setupFilterButton()
        
        updateCollectionView(with: FilterStore.selectedFilter)
        
        let analyticsEvent = AnalyticsEvent(
            eventType: .open,
            screen: "Main",
            item: nil
        )
        analiticsService.sendEvent(analyticsEvent)
    }
    
    //MARK: UI
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewTracker))
        addButton.tintColor = UIColor(named: "black")
        navigationItem.leftBarButtonItem = addButton
        
        navigationItem.title = TrackersMainScreenConst.navBarTitleString
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        self.datePicker = datePicker
        
        let datePickerButton = UIBarButtonItem(customView: datePicker)
        
        navigationItem.rightBarButtonItem = datePickerButton
    }
    
    private func setupSearchBar() {
        let searchBar = UISearchBar()
        searchBar.barStyle = .default
        searchBar.placeholder = TrackersMainScreenConst.searchBarPlaceholderString
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        self.searchBar = searchBar
    }
    
    private func setupEmptyStateView() {
        let emptyStateView = UIView()
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        
        let imageView = UIImageView(image: UIImage(named: "EmptyTrackersIcon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(imageView)
        
        let label = UILabel()
        label.text = TrackersMainScreenConst.emptyStateViewString
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
    
    private func setupNothingFoundStateView() {
        let nothingFoundStateView = UIView()
        nothingFoundStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nothingFoundStateView)
        
        let imageView = UIImageView(image: UIImage(named: "nothingFoundIcon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nothingFoundStateView.addSubview(imageView)
        
        let label = UILabel()
        label.text = TrackersMainScreenConst.nothingFoundString
        label.font = UIFont(name: "SFProText-Medium", size: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        nothingFoundStateView.addSubview(label)
        
        NSLayoutConstraint.activate([
            nothingFoundStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            nothingFoundStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: nothingFoundStateView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: nothingFoundStateView.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: nothingFoundStateView.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: nothingFoundStateView.bottomAnchor)
        ])
        
        self.nothingFoundStateView = nothingFoundStateView
    }
    
    private func setupCollectionView() {
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(TrackersHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
    
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
    
    private func setupFilterButton() {
        view.addSubview(filterButton)

        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -26),
            filterButton.widthAnchor.constraint(equalToConstant: 150),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    private func updateUI() {
        guard let trackers else { return }
        if trackers.isEmpty && FilterStore.selectedFilter == .allTrackers {
            emptyStateView.isHidden = false
            nothingFoundStateView.isHidden = true
            collectionView.isHidden = true
        } else {
            if trackers.isEmpty {
                emptyStateView.isHidden = true
                nothingFoundStateView.isHidden = false
                collectionView.isHidden = true
            } else {
                emptyStateView.isHidden = true
                nothingFoundStateView.isHidden = true
                collectionView.isHidden = false
            }
        }
    }
    
    //MARK: Buttons
    @objc private func createNewTracker() {
        let navigationController = UINavigationController(rootViewController: chooseTrackerTypeVC)
        navigationController.setNavigationBarHidden(true, animated: false)
         chooseTrackerTypeVC.trackersVC = self
        
        let analyticsEvent = AnalyticsEvent(
            eventType: .click,
            screen: "Main",
            item: .add_track
        )
        analiticsService.sendEvent(analyticsEvent)
        
        present( navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        self.selectedDate = sender.date
        switch FilterStore.selectedFilter {
        case .allTrackers:
            updateCollectionView(with: .allTrackers)
        case .todayTrackers:
            updateCollectionView(with: .allTrackers)
            filterTrackersVC.setFilter(.allTrackers)
        case .completedTrackers:
            updateCollectionView(with: .completedTrackers)
        case .uncompletedTrackers:
            updateCollectionView(with: .uncompletedTrackers)
        }
    }
    
    @objc private func filterButtonTapped() {
        filterTrackersVC.delegate = self
        
        let analyticsEvent = AnalyticsEvent(
            eventType: .click,
            screen: "Main",
            item: .filter
        )
        analiticsService.sendEvent(analyticsEvent)
        
        present(filterTrackersVC, animated: true)
    }
    
    //MARK: Public
    func updateCollectionView() {
        self.updateCollectionView(with: FilterStore.selectedFilter)
    }
    
    private func updateCollectionView(with filter: FilterType) {
        switch filter {
        case .allTrackers:
            trackers = trackerStore.fetchTrackers()
        case .todayTrackers:
            let date = Date()
            datePicker.date = date
            trackers = trackerStore.fetchTrackers(by: date)
        case .completedTrackers:
            guard let selectedDate else {return}
            trackers = trackerStore.fetchCompleteTrackers(by: selectedDate)
        case .uncompletedTrackers:
            guard let selectedDate else {return}
            trackers = trackerStore.fetchIncompleteTrackers(by: selectedDate)
        }
        updateUI()
        collectionView.reloadData()
    }
    
    func getDateFromUIDatePicker() -> Date? {
        guard let selectedDate = selectedDate else { return nil }
        return selectedDate
    }
    
    func setTrackerComplete(for tracker: Tracker, on date: Date) {
        self.addRecord(for: tracker, on: date)
        updateCollectionView(with: FilterStore.selectedFilter)
    }
    
    func setTrackerIncomplete(for tracker: Tracker, on date: Date) {
        self.removeRecord(for: tracker, on: date)
        updateCollectionView(with: FilterStore.selectedFilter)
    }
    
    func addTracker(_ tracker: Tracker, toCategory categoryTitle: String) {
        guard let trackerCategoryEntity = trackerCategoryStore.fetchCategoryEntity(byTitle: categoryTitle) else {
            print("Категория с названием \(categoryTitle) не найдена")
            return
        }
            trackerStore.createTracker(with: tracker, in: trackerCategoryEntity)
        print("Трекер \(tracker.title) добавлен в категорию \(categoryTitle)")
        self.updateCollectionView(with: FilterStore.selectedFilter)
    }
    
    func handleFilterSelection(_ filterType: FilterType) {
        updateCollectionView(with: filterType)
    }
    
    //MARK: Private
    private func removeTracker(_ tracker: Tracker) {
        guard let trackerEntity = trackerStore.fetchTrackerEntity(tracker.id), let category = trackerEntity.category else {
            print("Трекер с названием \(tracker.title) не найден в базе")
            return
        }
        trackerStore.removeTracker(with: tracker.id)
        print("Трекер \(tracker.title) удален из категории \(category)")
        self.updateCollectionView(with: FilterStore.selectedFilter)
    }
    
    private func removeRecord(for tracker: Tracker, on date: Date) {
        trackerRecordStore.removeTrackerRecord(with: tracker.id, on: date)
        print("Запись трекера \(tracker.title) удалена")
        print(trackerRecordStore.fetchTrackerRecords(byID: tracker.id))
    }
    
    private func addRecord(for tracker: Tracker, on date: Date) {
        guard let trackerEntity = trackerStore.fetchTrackerEntity(tracker.id) else {
            print("Запись трекера \(tracker.title) НЕ выполнена")
            return }
        trackerRecordStore.createTrackerRecord(with: trackerEntity, on: date)
        print("Запись трекера \(tracker.title) выполнена")
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let bottomOffset = scrollView.contentOffset.y + scrollView.frame.size.height
//        if bottomOffset >= scrollView.contentSize.height {
//            filterButton.isHidden = true // Скрыть кнопку "Фильтры" в конце списка
//        } else {
//            filterButton.isHidden = false // Показать кнопку, если до конца списка не доскроллили
//        }
//    }
}


extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDataSource
    
    ///Количество секций
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print(trackerStore.numberOfSections)
        return trackerStore.numberOfSections
    }
    /// Количество элементов в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(trackerStore.numberOfRowsInSection(section))
        return trackerStore.numberOfRowsInSection(section)
    }
    
    /// Настраиваем ячейку
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else { return TrackerCell() }
        guard
            let selectedDate = selectedDate,
            let tracker = trackerStore.object(at: indexPath)
        else { return cell}
        cell.configure(with: tracker, on: selectedDate)
        cell.trackersVC = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as? TrackersHeaderView else { return TrackersHeaderView() }
        headerView.label.text = trackerStore.header(at: indexPath)
        return headerView
    }
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = view.frame.width
        let paddingSpace = sectionInsets.left + sectionInsets.right + interItemSpacing * (itemsPerRow - 1)
        let availableWidth = screenWidth - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        let heightPerItem = widthPerItem * (148 / 167)
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    ///Настраиваем размер layout для заголовка секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    // Отступы для секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // Горизонтальное расстояние между ячейками
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    
    // Вертикальные отступы между строками ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - Context Menu Configuration
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell,
                  let tracker = cell.getTracker() else { return nil }
            
            let pinTracker = UIAction(
                title: self.isTrackerPinned(tracker) ?
                TrackerContextMenu.unpinTrackerString.localized : TrackerContextMenu.pinTrackerString.localized,
                identifier: nil
            ) { _ in
                self.toggleTrackerPin(tracker)
            }
            let editTracker = UIAction(title: TrackerContextMenu.editTrackerString.localized, identifier: nil) { [weak self] _ in
                guard let self, let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell, let tracker = cell.getTracker() else { return }
                
                let analyticsEvent = AnalyticsEvent(
                    eventType: .click,
                    screen: "Main",
                    item: .edit
                )
                self.analiticsService.sendEvent(analyticsEvent)
                
                let editTrackerVC = CreateNewTrackerViewController(isRegularEvent: true, isEditingTracker: true, editableTracker: tracker)
                editTrackerVC.trackersVC = self
                self.present(editTrackerVC, animated: true)

            }
            let deleteTracker = UIAction(title: TrackerContextMenu.deleteTrackerString.localized, identifier: nil, attributes: .destructive) { [weak self] _ in
                guard let self, let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell, let tracker = cell.getTracker() else { return }
                
                let analyticsEvent = AnalyticsEvent(
                    eventType: .click,
                    screen: "Main",
                    item: .delete
                )
                self.analiticsService.sendEvent(analyticsEvent)
                
                self.removeTracker(tracker)
            }
            return UIMenu(title: "", children: [pinTracker, editTracker, deleteTracker])
        }
        return config
    }
    
    private func isTrackerPinned(_ tracker: Tracker) -> Bool {
        guard let isPinned = trackerStore.fetchTrackerEntity(tracker.id)?.isPinned else { return false}
        return isPinned
    }

    private func toggleTrackerPin(_ tracker: Tracker) {
        let currentState = isTrackerPinned(tracker)
        let updatedTracker = Tracker(id: tracker.id ,title: tracker.title, color: tracker.color, emoji: tracker.emoji, schedule: tracker.schedule, isPinned: !currentState)
        trackerStore.updateTracker(for: updatedTracker)
        print(updatedTracker.isPinned)
        self.updateCollectionView(with: FilterStore.selectedFilter)
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }

        // Настраиваем параметры анимации подсветки
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear // Прозрачный фон для подсветки
        parameters.visiblePath = UIBezierPath(roundedRect: cell.getCellColorRectView().bounds, cornerRadius: 16)
        
        // Возвращаем зону подсветки для ячейки
        return UITargetedPreview(view: cell, parameters: parameters)
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) else {
            return nil
        }

        // Возвращаем зону подсветки для ячейки при закрытии меню
        return UITargetedPreview(view: cell)
    }
}

//MARK: UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Вызываем метод для поиска трекеров с введенным названием
        trackers = trackerStore.searchTracker(with: searchText)
        updateUI()
        collectionView.reloadData()
        
    }
}



