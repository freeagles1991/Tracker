//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Дима on 26.07.2024.
//

import Foundation
import UIKit

final class TrackersViewController: UIViewController {
    private let createNewTrackerVC = CreateNewTrackerViewController()
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    private var filteredCategories: [TrackerCategory] = []
    private var selectedDate: Date?
    
    let notificationName = Notification.Name("NewTrackerCreated")

    private var emptyStateView = UIView()
    private var searchBar = UISearchBar()
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 9
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let itemsPerRow: CGFloat = 2
    let sectionInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    let interItemSpacing: CGFloat = 9
    
    private let emptyStateViewString = "Что будем отслеживать?"
    private let navBarTitleString = "Трекеры"
    
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
        
        selectedDate = Date()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setupNavigationBar()
        setupSearchBar()
        setupEmptyStateView()
        setupCollectionView()
        
        updateUI()
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
        searchBar.placeholder = "Поиск"
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
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
    
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
    
    private func updateUI() {
        if filteredCategories.isEmpty {
            emptyStateView.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyStateView.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    private func getWeekday(from date: Date) -> Weekday? {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        
        switch weekdayNumber {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return nil
        }
    }
    
    private func filterTrackers(for weekday: Weekday, from categories: [TrackerCategory]) -> [TrackerCategory] {
        var filteredCategories: [TrackerCategory] = []
        
        for category in categories {
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.schedule.contains(weekday)
            }
            
            if !filteredTrackers.isEmpty {
                let filteredCategory = TrackerCategory(title: category.title, trackers: filteredTrackers)
                filteredCategories.append(filteredCategory)
            }
        }
        
        return filteredCategories
    }
    
    private func updateTrackers(for date: Date) {
        if let selectedWeekday = getWeekday(from: date) {
            filteredCategories = filterTrackers(for: selectedWeekday, from: self.categories)
            updateUI()
            collectionView.reloadData()
        }
    }
    
    private func handleNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let tracker = userInfo["tracker"] as? Tracker,
           let category = userInfo["category"] as? TrackerCategory {
            print("Получены данные: \(tracker), \(category)")
        }
    }

    
    @objc private func createNewTracker() {
        createNewTrackerVC.trackersVC = self
        present(createNewTrackerVC, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        self.selectedDate = sender.date
        guard let selectedDate = selectedDate else { return }
        updateTrackers(for: selectedDate)
    }
    
    func updateCollectionViewWithNewTracker() {
        guard let selectedDate = selectedDate else { return }
        updateTrackers(for: selectedDate)
    }
    
    func getDateFromUIDatePicker() -> Date? {
        guard let selectedDate = selectedDate else { return nil }
        return selectedDate
    }
    
    func setTrackerComplete(for tracker: Tracker, on date: Date) {
        self.addRecord(for: tracker, on: date)
    }
    
    private func addRecord(for tracker: Tracker, on date: Date) {
        var updatedRecords = completedTrackers
        let newRecord = TrackerRecord(trackerID: tracker.id, date: date)
        updatedRecords.append(newRecord)
        completedTrackers = updatedRecords
        print("Запись трекера \(tracker.title) выполнена")
    }
    
    func setTrackerIncomplete(for tracker: Tracker, on date: Date) {
        self.removeRecord(for: tracker, on: date)
    }
    
    private func removeRecord(for tracker: Tracker, on date: Date) {
        var updatedRecords = completedTrackers
        updatedRecords.removeAll { $0.trackerID == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date) }
        completedTrackers = updatedRecords
        print("Запись трекера \(tracker.title) удалена")
    }
    
    func addTracker(_ tracker: Tracker, toCategory categoryTitle: String) {
        var updatedCategories = categories
        if let index = updatedCategories.firstIndex(where: { $0.title == categoryTitle }) {
            // Создаём новую категорию с добавленным трекером
            let updatedTrackers = updatedCategories[index].trackers + [tracker]
            let updatedCategory = TrackerCategory(title: categoryTitle, trackers: updatedTrackers)
            updatedCategories[index] = updatedCategory
        } else {
            // Создаём новую категорию
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            updatedCategories.append(newCategory)
        }
        categories = updatedCategories
    }
    
    private func removeTracker(_ tracker: Tracker, from categoryTitle: String) {
        var updatedCategories = categories
        if let index = updatedCategories.firstIndex(where: { $0.title == categoryTitle }) {
            // Фильтруем трекеры, исключая удаляемый трекер
            let updatedTrackers = updatedCategories[index].trackers.filter { $0 != tracker }
            
            // Создаём новую категорию с обновлённым списком трекеров
            let updatedCategory = TrackerCategory(title: categoryTitle, trackers: updatedTrackers)
            updatedCategories[index] = updatedCategory
        }
        categories = updatedCategories
    }
    
    func isTrackerCompleted(_ tracker: Tracker) -> Bool {
        return completedTrackers.contains { $0.trackerID == tracker.id }
    }
    
    func numberOfRecords(for tracker: Tracker) -> Int {
        return completedTrackers.filter { $0.trackerID == tracker.id }.count
    }
}


extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDataSource
    
    ///Количество секций
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    /// Количество элементов в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    /// Настраиваем ячейку
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        //guard let selectedDate = selectedDate else { return cell }
        cell.configure(with: tracker, on: selectedDate ?? Date())
        cell.trackersVC = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        headerView.label.text = self.categories[indexPath.section].title
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
        return 10
    }
}



