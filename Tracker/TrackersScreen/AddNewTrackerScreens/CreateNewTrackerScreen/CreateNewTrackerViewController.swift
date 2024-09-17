//
//  CreateNewTrackerViewController.swift
//  Tracker
//
//  Created by Дима on 05.08.2024.
//

import Foundation
import UIKit

class CreateNewTrackerViewController: UIViewController {
    private let trackerStore = TrackerStore.shared
    private let trackerCategoryStore = TrackerCategoryStore.shared
    weak var trackersVC: TrackersViewController?
    
    enum Constants {
        static let emojies: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                                            "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                                            "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
        static let colors: [String] = ["#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4",
                                "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D",
                                
                                "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"]
        static let createScreenTitleString: String = NSLocalizedString("CreateNewTracker_createScreenTitleString", comment: "Новая привычка")
        static let editScreenTitleString: String = NSLocalizedString("CreateNewTracker_editScreenTitleString", comment: "Редактирование привычки")
        static let trackerNameTextFieldString: String = NSLocalizedString("CreateNewTracker_trackerNameTextFieldString", comment: "Введите название трекера")
        static let categoryButtonString: String = NSLocalizedString("CreateNewTracker_categoryButtonString", comment: "Категория")
        static let scheduleButtonString: String = NSLocalizedString("CreateNewTracker_scheduleButtonString", comment: "Расписание")
        static let emojiHeaderString = NSLocalizedString("CreateNewTracker_emojiHeaderString", comment: "Emoji")
        static let colorHeaderString = NSLocalizedString("CreateNewTracker_colorHeaderString", comment: "Цвет")
        static let cancelButtonString: String = NSLocalizedString("CreateNewTracker_cancelButtonString", comment: "Отменить")
        static let createButtonString: String = NSLocalizedString("CreateNewTracker_createButtonString", comment: "Создать")
        static let saveButtonString: String = NSLocalizedString("CreateNewTracker_saveButtonString", comment: "Сохранить")
    }
    
    private let chooseCategoryVC = ChooseCategoryViewController(viewModel: ChooseCategoryViewModel())
    private let scheduleScreenVC = ScheduleScreenViewController(viewModel: ScheduleScreenViewModel())
    
    private var selectedCategory: TrackerCategory?
    private var selectedWeekdays = Set<Weekday>()
    private var selectedEmoji: String?
    private var selectedColor: String?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var screenTitle = UILabel()
    private var durationCounterLabel = UILabel()
    private var durationCountInt = 0
    private var trackerNameTextField = UITextField()
    
    private var categoryButton = UIButton()
    private var scheduleButton = UIButton()
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var parametersStackView = UIStackView()
    
    private let emojiCollectionViewDataSourceDelegate = EmojiCollectionViewDataSourceDelegate()
    private var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsSelection = true
        collectionView.isUserInteractionEnabled = true
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let colorCollectionViewDataSourceDelegate = ColorCollectionViewDataSourceDelegate()
    private var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsSelection = true
        collectionView.isUserInteractionEnabled = true
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private var cancelButton = UIButton()
    private var createButton = UIButton()
    
    private let isRegularEvent: Bool
    private let isEditingTracker: Bool
    private var editableTracker: Tracker
    
    init(isRegularEvent: Bool, isEditingTracker: Bool, editableTracker: Tracker? = nil) {
        self.isRegularEvent = isRegularEvent
        self.isEditingTracker = isEditingTracker
        self.editableTracker = editableTracker ?? Tracker.defaultTracker
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addTapGestureToHideKeyboard()
        closeChooseCategoryScreen()
        
        chooseCategoryVC.delegate = self
        scheduleScreenVC.delegate = self
        
        setupScreenTitle()
        setupDurationCounterLabel()
        setupScrollView()
        setupTextField()
        setupParametresStackView()
        setupEmojiCollectionView()
        setupColorCollectionView()
        setupScreenControlsStackView()
        setupScrollViewBottomAnchor()
        updateCreateButtonState()
        
        if !isRegularEvent {
            guard let weekday = Weekday.fromDate(Date()) else { return }
            selectedWeekdays.insert(weekday)
        }
        
        if isEditingTracker {
            populateFieldsWithTrackerData(editableTracker)
        }
    }
    
    //MARK: Верстка
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
    }
    
    private func setupScreenTitle() {
        let label = UILabel()
        let font = UIFont(name: "SFProText-Medium", size: 16)
        label.text = isEditingTracker ? Constants.editScreenTitleString : Constants.createScreenTitleString
        label.textColor = .black
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22).isActive = true
        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        self.screenTitle = label
    }
    
    private func setupDurationCounterLabel() {
        if isEditingTracker {
            let label = UILabel()
            let font = UIFont(name: "SFProText-Bold", size: 32)
            label.text = String.localizedStringWithFormat(
                NSLocalizedString("daysCount", comment: "Количество дней"), durationCountInt)
            label.textColor = .black
            label.font = font
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
            
            label.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: 38).isActive = true
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            
            self.durationCounterLabel = label
        } else {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
            
            label.topAnchor.constraint(equalTo: screenTitle.topAnchor, constant: 0).isActive = true
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            
            self.durationCounterLabel = label
        }
    }
    
    private func setupTextField() {
        let textField = UITextField()
        textField.placeholder = Constants.trackerNameTextFieldString
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = .none
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.backgroundColor = UIColor(named: "background")
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: durationCounterLabel.bottomAnchor, constant: 40),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        self.trackerNameTextField = textField
    }
    
    private func setupParametersBaseButton(with text: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor(named: "background")
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 40)
        
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .gray
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            arrowImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            
            button.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        return button
    }
    
    private func setupCategoryButton() {
        let categoryButton = setupParametersBaseButton(with: Constants.categoryButtonString)
        categoryButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        
        self.categoryButton = categoryButton
    }
    
    private func updateCategoryButton(with categoryTitle: String) {
        let attributedString = NSMutableAttributedString(string: Constants.categoryButtonString, attributes: [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.black
        ])
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        
        let additionalText = "\n\(categoryTitle)"
        print(categoryTitle)
        let additionalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.darkGray,
            .paragraphStyle: paragraphStyle
        ]
        
        attributedString.append(NSAttributedString(string: additionalText, attributes: additionalAttributes))
        
        categoryButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    private func setupScheduleButton() {
        let scheduleButton = setupParametersBaseButton(with: Constants.scheduleButtonString)
        scheduleButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped(_:)), for: .touchUpInside)
        
        self.scheduleButton = scheduleButton
    }
    
    private func updateSheduleButton(with selectedWeekdaysString: String) {
        let attributedString = NSMutableAttributedString(string: Constants.scheduleButtonString, attributes: [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.black
        ])
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        
        let additionalText = "\n\(selectedWeekdaysString)"
        print(selectedWeekdaysString)
        let additionalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.darkGray,
            .paragraphStyle: paragraphStyle
        ]
        
        attributedString.append(NSAttributedString(string: additionalText, attributes: additionalAttributes))
        
        scheduleButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    private func setupParametresStackView() {
        setupCategoryButton()
        setupScheduleButton()
        
        var arrangedSubviews = [categoryButton, separator, scheduleButton]
        
        if !isRegularEvent {
            arrangedSubviews = [categoryButton]
        }
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.layer.cornerRadius = 16
        stackView.layer.masksToBounds = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        self.parametersStackView = stackView
    }
    
    private func setupEmojiCollectionView() {
        emojiCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        emojiCollectionView.register(EmojiHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "EmojiHeader")
        
        emojiCollectionViewDataSourceDelegate.createNewTrackerVC = self
        emojiCollectionView.dataSource = emojiCollectionViewDataSourceDelegate
        emojiCollectionView.delegate = emojiCollectionViewDataSourceDelegate
    
        contentView.addSubview(emojiCollectionView)
        
        NSLayoutConstraint.activate([
            emojiCollectionView.topAnchor.constraint(equalTo: parametersStackView.bottomAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 250)
        ])

    }
    
    private func setupColorCollectionView() {
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        colorCollectionView.register(ColorHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ColorHeader")
        
        colorCollectionViewDataSourceDelegate.createNewTrackerVC = self
        colorCollectionView.dataSource = colorCollectionViewDataSourceDelegate
        colorCollectionView.delegate = colorCollectionViewDataSourceDelegate
    
        contentView.addSubview(colorCollectionView)
        
        NSLayoutConstraint.activate([
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    private func setupBaseButton(with text: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16)
        button.backgroundColor = .black
        button.contentHorizontalAlignment = .center
        button.layer.cornerRadius = 16
        
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return button
    }
    
    private func setupCreateButton() {
        let buttonTitle = isEditingTracker ? Constants.saveButtonString : Constants.createButtonString
        let createButton = setupBaseButton(with: buttonTitle)
        if isEditingTracker {
            createButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
        } else {
            createButton.addTarget(self, action: #selector(createButtonTapped(_:)), for: .touchUpInside)
        }
        
        self.createButton = createButton
    }
    
    private func setupCancelButton() {
        let cancelButton = setupBaseButton(with: Constants.cancelButtonString)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        cancelButton.backgroundColor = .white
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        
        self.cancelButton = cancelButton
    }
    
    private func setupScreenControlsStackView() {
        setupCreateButton()
        setupCancelButton()
        
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupScrollViewBottomAnchor() {
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: createButton.bottomAnchor, constant: 20)
        bottomConstraint.isActive = true
    }
    
    //MARK: Логика
    
    private func convertWeekdaysToString(_ selectedWeekdays: Set<Weekday>) -> String {
        return selectedWeekdays.toString()
    }
    
    func updateCategory(_ category: TrackerCategory) {
        self.selectedCategory = category
        updateCategoryButton(with: category.title)
        updateCreateButtonState()
    }
    
    func updateSelectedWeekdays(_ selectedWeekdays: Set<Weekday>) {
        self.selectedWeekdays = selectedWeekdays
        print("Выбранные дни - \(selectedWeekdays) - сохранены")
        let selectedWeekdaysString = self.convertWeekdaysToString(selectedWeekdays)
        updateSheduleButton(with: selectedWeekdaysString)
        updateCreateButtonState()
    }
    
    func updateSelectedEmoji(with emoji: String) {
        self.selectedEmoji = emoji
        print("Выбранный емоджи сохранен")
    }
    
    func updateSelectedColor(with color: String) {
        self.selectedColor = color
        print("Выбранный емоджи сохранен")
    }
    
    private func createNewTracker() -> Tracker? {
        guard let trackerName = trackerNameTextField.text, !trackerName.isEmpty else {
            print("Название трекера не может быть пустым.")
            return nil
        }
        guard let selectedEmoji = selectedEmoji else {
            print("Выбранный emoji отсутствует")
            return nil
        }
        guard let selectedColor = selectedColor else {
            print("Выбранный color отсутствует")
            return nil
        }
        let selectedWeekdaysArray = Array(selectedWeekdays)
        let newTracker = Tracker(title: trackerName, color: selectedColor, emoji: selectedEmoji, schedule: selectedWeekdaysArray)
        return newTracker
    }
    
    private func addNewTracker() {
        guard let selectedCategory,
              let trackersVC,
              let newTracker = createNewTracker()
        else { return }
        trackersVC.addTracker(newTracker, toCategory: selectedCategory.title)
    }
    
    private func updateTracker(with tracker: Tracker) -> Tracker? {
        let updatedTracker = Tracker(id: editableTracker.id, title: tracker.title, color: tracker.color, emoji: tracker.emoji, schedule: tracker.schedule)
        return updatedTracker
    }
    
    //MARK: EditTracker
    func populateFieldsWithTrackerData(_ tracker: Tracker) {
        // Заполнение полей данными трекера для редактирования
        self.trackerNameTextField.text = tracker.title
        self.selectedEmoji = tracker.emoji
        if let selectedEmoji {
            selectEmojiCell(with: selectedEmoji)
        }
        self.selectedColor = tracker.color
        if let selectedColor {
            selectColorCell(with: selectedColor)
        }
        self.selectedWeekdays = Set(tracker.schedule)
        
        if let trackerEntity = trackerStore.fetchTrackerEntity(tracker.id), let categoryTitle = trackerEntity.category?.title {
            let trackerCategory = TrackerCategory(title: categoryTitle, trackers: [])
            self.selectedCategory = trackerCategory
            updateCategoryButton(with: trackerCategory.title)
        }
        
        updateSheduleButton(with: convertWeekdaysToString(selectedWeekdays))
        updateCreateButtonState()
    }
    
    func selectEmojiCell(with emoji: String) {
        guard let emojiIndex = Constants.emojies.firstIndex(of: emoji) else { return }
        
        let indexPath = IndexPath(item: emojiIndex, section: 0)
        
        // Выделяем ячейку
        emojiCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        
        // Обновляем вид ячейки для визуального выделения
        if let cell = emojiCollectionView.cellForItem(at: indexPath) as? EmojiCell {
            cell.isSelected = true
        }
    }
    
    func selectColorCell(with color: String) {
        guard let colorIndex = Constants.colors.firstIndex(of: color) else { return }
        
        let indexPath = IndexPath(item: colorIndex, section: 0)
        
        // Выделяем ячейку
        colorCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        
        // Обновляем вид ячейки для визуального выделения
        if let cell = colorCollectionView.cellForItem(at: indexPath) as? ColorCell {
            cell.isSelected = true
        }
    }

    //MARK: Кнопки
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        present(chooseCategoryVC, animated: true)
    }
    
    @objc private func scheduleButtonTapped(_ sender: UIButton) {
        present(scheduleScreenVC, animated: true)
    }
    
    @objc private func createButtonTapped(_ sender: UIButton) {
        addNewTracker()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped(_ sender: UIButton) {
        guard let newTracker = createNewTracker(),
              let updatedTracker = updateTracker(with: newTracker),
              let trackersVC
        else { return }
        trackerStore.updateTracker(for: updatedTracker)
        trackersVC.updateCollectionView()
        print("Обновили трекер")
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    private func closeChooseCategoryScreen() {
        if let navigationController = self.navigationController {
            var viewControllers = navigationController.viewControllers

            if viewControllers.count > 1 {
                viewControllers.remove(at: viewControllers.count - 2)
                navigationController.viewControllers = viewControllers
            }
        }
    }
    
    private func updateCreateButtonState() {
        let isAllParametresSelected: Bool = {
            return selectedCategory != nil &&
            !(trackerNameTextField.text?.isEmpty ?? true) &&
            !(selectedEmoji?.isEmpty ?? true) &&
            !(selectedColor?.isEmpty ?? true)
        }()
        
        if isRegularEvent {
            if isAllParametresSelected && !selectedWeekdays.isEmpty {
                createButton.isEnabled = true
                createButton.alpha = 1.0
            } else {
                createButton.isEnabled = false
                createButton.alpha = 0.5
            }
        } else {
            if isAllParametresSelected {
                createButton.isEnabled = true
                createButton.alpha = 1.0
            } else {
                createButton.isEnabled = false
                createButton.alpha = 0.5
            }
            
        }
    }
}

