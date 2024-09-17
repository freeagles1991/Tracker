//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Дима on 26.07.2024.
//

import Foundation
import UIKit

final class TrackersViewController: UIViewController {
    private let trackerStore = TrackerStore.shared
    private var trackers: [Tracker]?
    private let trackerCategoryStore = TrackerCategoryStore.shared
    private let trackerRecordStore = TrackerRecordStore.shared
    private let chooseTrackerTypeVC =  ChooseTrackerTypeViewController()
    
    private let searchBarPlaceholderString = NSLocalizedString("SearchBar_placeholder", comment: "Поиск")
    
    private var selectedDate: Date?
    
    let notificationName = Notification.Name("NewTrackerCreated")

    private var emptyStateView = UIView()
    private var searchBar = UISearchBar()
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 9
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    //TO DO: добавить переводы
    enum TrackerContextMenu: String {
        case pinTrackerString = "Закрепить"
        case unpinTrackerString = "Открепить"
        case editTrackerString = "Редактировать"
        case deleteTrackerString = "Удалить"
    }
    
    var trackerContextMenuItemStates: [IndexPath: Bool] = [:]
    
    let itemsPerRow: CGFloat = 2
    let sectionInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    let interItemSpacing: CGFloat = 9
    
    private let navBarTitleString = NSLocalizedString("navBarTitleString", comment: "Трекеры")
    private let emptyStateViewString = NSLocalizedString("emptyStateViewString", comment: "Что будем отслеживать?")
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: .main) { [weak self] notification in
            self?.handleNotification(notification)
        }
        
        trackerStore.trackersVC = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setupNavigationBar()
        setupSearchBar()
        setupEmptyStateView()
        setupCollectionView()
        
        selectedDate = Date()
        guard let selectedDate else { return }
        trackers = trackerStore.fetchTrackers(by: selectedDate)
        updateUI()
        collectionView.reloadData()
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewTracker))
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
        
        navigationItem.title = navBarTitleString
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        let datePickerButton = UIBarButtonItem(customView: datePicker)
        
        navigationItem.rightBarButtonItem = datePickerButton
    }
    
    private func setupSearchBar() {
        let searchBar = UISearchBar()
        searchBar.barStyle = .default
        searchBar.placeholder = searchBarPlaceholderString
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
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
        label.text = emptyStateViewString
        label.font = UIFont.systemFont(ofSize: 12)
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
    
    private func updateUI() {
        guard let trackers else { return }
        if trackers.isEmpty {
            emptyStateView.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyStateView.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    private func handleNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let tracker = userInfo["tracker"] as? Tracker,
           let category = userInfo["category"] as? TrackerCategory {
            print("Получены данные: \(tracker), \(category)")
        }
    }
    
    private func editTracker(_ tracker: Tracker) {
       //Переходим на экран редактирования трекера
    }

    
    @objc private func createNewTracker() {
        let navigationController = UINavigationController(rootViewController: chooseTrackerTypeVC)
        navigationController.setNavigationBarHidden(true, animated: false)
         chooseTrackerTypeVC.trackersVC = self
        present( navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        self.selectedDate = sender.date
        guard let selectedDate else {return}
        trackers = trackerStore.fetchTrackers(by: selectedDate)
        updateUI()
        collectionView.reloadData()
    }
    
    func updateCollectionViewWithNewTracker() {
        guard let selectedDate else { return }
        trackers = trackerStore.fetchTrackers(by: selectedDate)
        updateUI()
        collectionView.reloadData()
    }
    
    func getDateFromUIDatePicker() -> Date? {
        guard let selectedDate = selectedDate else { return nil }
        return selectedDate
    }
    
    func setTrackerComplete(for tracker: Tracker, on date: Date) {
        self.addRecord(for: tracker, on: date)
    }
    
    private func addRecord(for tracker: Tracker, on date: Date) {
        guard let trackerEntity = trackerStore.fetchTrackerEntity(tracker.id) else {
            print("Запись трекера \(tracker.title) НЕ выполнена")
            return }
        trackerRecordStore.createTrackerRecord(with: trackerEntity, on: date)
        print("Запись трекера \(tracker.title) выполнена")
    }
    
    func setTrackerIncomplete(for tracker: Tracker, on date: Date) {
        self.removeRecord(for: tracker, on: date)
    }
    
    private func removeRecord(for tracker: Tracker, on date: Date) {
        trackerRecordStore.removeTrackerRecord(with: tracker.id, on: date)
        print("Запись трекера \(tracker.title) удалена")
    }
    
    func addTracker(_ tracker: Tracker, toCategory categoryTitle: String) {
        guard let trackerCategoryEntity = trackerCategoryStore.fetchCategoryEntity(byTitle: categoryTitle) else {
            print("Категория с названием \(categoryTitle) не найдена")
            return
        }
            trackerStore.createTracker(with: tracker, in: trackerCategoryEntity)
        print("Трекер \(tracker.title) добавлен в категорию \(categoryTitle)")
    }

    
    private func removeTracker(_ tracker: Tracker) {
        guard let trackerEntity = trackerStore.fetchTrackerEntity(tracker.id), let category = trackerEntity.category else {
            print("Трекер с названием \(tracker.title) не найден в базе")
            return
        }
        trackerStore.removeTracker(with: tracker.id)
        print("Трекер \(tracker.title) удален из категории \(category)")
    }
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
            let isOn = self.isTrackerPinned(at: indexPath)
            let pinTracker = UIAction(title: isOn ? TrackerContextMenu.unpinTrackerString.rawValue : TrackerContextMenu.pinTrackerString.rawValue, identifier: nil) { _ in
                self.toggleTrackerPin(at: indexPath)
            }
            let editTracker = UIAction(title: TrackerContextMenu.editTrackerString.rawValue, identifier: nil) { _ in
                // Handle action 2
            }
            let deleteTracker = UIAction(title: TrackerContextMenu.deleteTrackerString.rawValue, identifier: nil, attributes: .destructive) { _ in
                let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell
                guard let tracker = cell?.getTracker() else { return }
                self.removeTracker(tracker)
            }
            return UIMenu(title: "", children: [pinTracker, editTracker, deleteTracker])
        }
        return config
    }
    
    func isTrackerPinned(at indexPath: IndexPath) -> Bool {
        return trackerContextMenuItemStates[indexPath] ?? false
    }

    func toggleTrackerPin(at indexPath: IndexPath) {
        let currentState = isTrackerPinned(at: indexPath)
        trackerContextMenuItemStates[indexPath] = !currentState
        // Здесь можно обновить ячейку или другие данные
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



