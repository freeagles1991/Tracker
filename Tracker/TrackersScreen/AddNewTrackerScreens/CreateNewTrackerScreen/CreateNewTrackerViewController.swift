//
//  CreateNewTrackerViewController.swift
//  Tracker
//
//  Created by Дима on 05.08.2024.
//

import Foundation
import UIKit

final class CreateNewTrackerViewController: UIViewController {
    private let trackerStore = TrackerStore.shared
    private let trackerCategoryStore = TrackerCategoryStore.shared
    weak var trackersVC: TrackersViewController?
    weak var delegate: ChooseTrackerTypeViewController?
    
    private let chooseCategoryVC = ChooseCategoryViewController(viewModel: ChooseCategoryViewModel())
    private let scheduleScreenVC = ScheduleScreenViewController(viewModel: ScheduleScreenViewModel())
    
    private var selectedCategory: TrackerCategory?
    private var selectedWeekdays = Set<Weekday>()
    
    let emojies: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                           "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                           "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private var selectedEmoji: String?
    
    let colors: [String] = ["#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4",
                            "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D",
                            
                            "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"]
    private var selectedColor: String?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var screenTitle = UILabel()
    private let screenTitleString: String = NSLocalizedString("CreateNewTracker_screenTitleString", comment: "Новая привычка")
    
    private var trackerNameTextField = UITextField()
    private let trackerNameTextFieldString: String = NSLocalizedString("CreateNewTracker_trackerNameTextFieldString", comment: "Введите название трекера")
    
    private var categoryButton = UIButton()
    private let categoryButtonString: String = NSLocalizedString("CreateNewTracker_categoryButtonString", comment: "Категория")
    
    private var scheduleButton = UIButton()
    private let scheduleButtonString: String = NSLocalizedString("CreateNewTracker_scheduleButtonString", comment: "Расписание")
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var parametersStackView = UIStackView()
    
    private let emojiCollectionViewDataSourceDelegate = EmojiCollectionViewDataSourceDelegate()
    let emojiHeaderString = NSLocalizedString("CreateNewTracker_emojiHeaderString", comment: "Emoji")
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
    let colorHeaderString = NSLocalizedString("CreateNewTracker_colorHeaderString", comment: "Цвет")
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
    private let cancelButtonString: String = "Отменить"
    
    private var createButton = UIButton()
    private let createButtonString: String = "Создать"
    
    private var isRegularEvent = true
    
    let notificationName = Notification.Name("MyCustomNotification")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addTapGestureToHideKeyboard()
        closeChooseCategoryScreen()
        
        chooseCategoryVC.delegate = self
        scheduleScreenVC.delegate = self
        
        setupScreenTitle()
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
        label.text = screenTitleString
        label.textColor = .black
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22).isActive = true
        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        self.screenTitle = label
    }
    
    private func setupTextField() {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
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
            textField.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: 38),
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
        let categoryButton = setupParametersBaseButton(with: categoryButtonString)
        categoryButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        
        self.categoryButton = categoryButton
    }
    
    private func updateCategoryButton(with categoryTitle: String) {
        let attributedString = NSMutableAttributedString(string: categoryButtonString, attributes: [
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
        let scheduleButton = setupParametersBaseButton(with: scheduleButtonString)
        scheduleButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped(_:)), for: .touchUpInside)
        
        self.scheduleButton = scheduleButton
    }
    
    private func updateSheduleButton(with selectedWeekdaysString: String) {
        let attributedString = NSMutableAttributedString(string: scheduleButtonString, attributes: [
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
        let createButton = setupBaseButton(with: createButtonString)
        createButton.addTarget(self, action: #selector(createButtonTapped(_:)), for: .touchUpInside)
        
        self.createButton = createButton
    }
    
    private func setupCancelButton() {
        let cancelButton = setupBaseButton(with: cancelButtonString)
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
    
    private func resetScreenFields() {
        
    }
    
    private func convertWeekdaysToString(_ selectedWeekdays: Set<Weekday>) -> String {
        let abbreviations: [Weekday: String] = [
            .monday: "Пн",
            .tuesday: "Вт",
            .wednesday: "Ср",
            .thursday: "Чт",
            .friday: "Пт",
            .saturday: "Сб",
            .sunday: "Вс"
        ]
        let abbreviationsArray = selectedWeekdays.compactMap { abbreviations[$0] }
        return abbreviationsArray.joined(separator: ", ")
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
    
    func createNewTracker() {
        guard let trackerName = trackerNameTextField.text, !trackerName.isEmpty else {
            print("Название трекера не может быть пустым.")
            return
        }
        guard let selectedEmoji = selectedEmoji else {
            print("Выбранный emoji отсутствует")
            return
        }
        guard let selectedColor = selectedColor else {
            print("Выбранный color отсутствует")
            return
        }
        let selectedWeekdaysArray = Array(selectedWeekdays)
        let newTracker = Tracker(title: trackerName, color: selectedColor, emoji: selectedEmoji, schedule: selectedWeekdaysArray)
        guard let selectedCategory = selectedCategory else { return }
        
        let userInfo: [String: Any] = [
            "tracker": newTracker,
            "category": selectedCategory]
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
        
        guard let trackersVC else { return }
        trackersVC.addTracker(newTracker, toCategory: selectedCategory.title)
        trackersVC.updateCollectionViewWithNewTracker()
    }
    
    func configureTrackerType(isRegularEvent: Bool) {
        self.isRegularEvent = isRegularEvent
    }
    
    //MARK: Кнопки
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        present(chooseCategoryVC, animated: true)
    }
    
    @objc private func scheduleButtonTapped(_ sender: UIButton) {
        present(scheduleScreenVC, animated: true)
    }
    
    @objc private func createButtonTapped(_ sender: UIButton) {
        createNewTracker()
        
        self.navigationController?.dismiss(animated: true, completion: nil)
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

