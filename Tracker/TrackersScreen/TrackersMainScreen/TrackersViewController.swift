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
    private let trackerCategoryStore = TrackerCategoryStore.shared
    private let trackerRecordStore = TrackerRecordStore.shared
    private let chooseTrackerTypeVC =  ChooseTrackerTypeViewController()
    
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
    let sectionInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
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
        collectionView.register(TrackersHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
    
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
    
    private func updateUI() {
        guard let selectedDate = selectedDate else { return }
        if trackerCategoryStore.filterCategories(for: selectedDate).isEmpty {
            emptyStateView.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyStateView.isHidden = true
            collectionView.isHidden = false
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
    
    private func handleNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let tracker = userInfo["tracker"] as? Tracker,
           let category = userInfo["category"] as? TrackerCategory {
            print("Получены данные: \(tracker), \(category)")
        }
    }

    
    @objc private func createNewTracker() {
        let navigationController = UINavigationController(rootViewController: chooseTrackerTypeVC)
        navigationController.setNavigationBarHidden(true, animated: false)
         chooseTrackerTypeVC.trackersVC = self
        present( navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        self.selectedDate = sender.date
        updateUI()
        collectionView.reloadData()
    }
    
    func updateCollectionViewWithNewTracker() {
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
        trackerRecordStore.createTrackerRecord(with: tracker, on: date)
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

    
    private func removeTracker(_ tracker: Tracker, from categoryTitle: String) {
        //TO DO: реализовать удаление трекера
    }
}


extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDataSource
    
    ///Количество секций
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let selectedDate = selectedDate else { return 0}
        return trackerCategoryStore.filterCategories(for: selectedDate).count
    }
    /// Количество элементов в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let selectedDate = selectedDate else { return 0 }
        return trackerCategoryStore.filterCategories(for: selectedDate)[section].trackers.count
    }
    
    /// Настраиваем ячейку
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else { return TrackerCell() }
        guard let selectedDate = selectedDate else { return cell}
        let tracker = trackerCategoryStore.filterCategories(for: selectedDate)[indexPath.section].trackers[indexPath.item]
        cell.configure(with: tracker, on: selectedDate)
        cell.trackersVC = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as? TrackersHeaderView else { return TrackersHeaderView() }
        headerView.label.text = trackerCategoryStore.categories[indexPath.section].title
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
}



