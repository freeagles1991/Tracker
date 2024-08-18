//
//  CreateNewHabitViewController.swift
//  Tracker
//
//  Created by Дима on 05.08.2024.
//

import Foundation
import UIKit

final class CreateNewHabitViewController: UIViewController {
    weak var trackersVC: TrackersViewController?
    private let chooseCategoryVC = ChooseCategoryViewController()
    private let scheduleScreenVC = ScheduleScreenViewController()
    weak var delegate: CreateNewTrackerViewController?
    
    let notificationName = Notification.Name("MyCustomNotification")
    
    private var selectedCategory: TrackerCategory?
    private var selectedWeekdays = Set<Weekday>()
    private let defaultEmoji: String = "💪"
    private let defaultColor: String = "#FF5733"
    
    private var screenTitle = UILabel()
    private let screenTitleString: String = "Новая привычка"
    
    private var trackerNameTextField = UITextField()
    private let trackerNameTextFieldString: String = "Введите название трекера"
    
    private var categoryButton = UIButton()
    private let categoryButtonString: String = "Категория"
    
    private var scheduleButton = UIButton()
    private let scheduleButtonString: String = "Расписание"
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var cancelButton = UIButton()
    private let cancelButtonString: String = "Отменить"
    
    private var createButton = UIButton()
    private let createButtonString: String = "Создать"
    
    private var isCategorySelected = false
    private var isScheduleSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addTapGestureToHideKeyboard()
        
        chooseCategoryVC.delegate = self
        scheduleScreenVC.delegate = self
        
        setupScreenTitle()
        setupTextField()
        setupParametresStackView()
        setupScreenControlsStackView()
        updateCreateButtonState()
    }
    
    private func setupScreenTitle() {
        let label = UILabel()
        let font = UIFont.systemFont(ofSize: 16)
        label.text = screenTitleString
        label.textColor = .black
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22).isActive = true
        label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
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
        view.addSubview(textField)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        self.trackerNameTextField = textField
    }
    
    private func setupParametersBaseButton(with text: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor(named: "background")
        button.layer.cornerRadius = 16
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
        
        let stackView = UIStackView(arrangedSubviews: [categoryButton, separator, scheduleButton])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupBaseButton(with text: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
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
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
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
    
    func createNewTracker() {
        guard let trackerName = trackerNameTextField.text, !trackerName.isEmpty else {
            print("Название трекера не может быть пустым.")
            return
        }
        let selectedWeekdaysArray = Array(selectedWeekdays)
        let newTracker = Tracker(title: trackerName, color: defaultColor, emoji: defaultEmoji, schedule: selectedWeekdaysArray)
        guard let selectedCategory = selectedCategory else { return }
        
        // Отправляем уведомление
        let userInfo: [String: Any] = [
            "tracker": newTracker,
            "category": selectedCategory]
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
        
        trackersVC?.addTracker(newTracker, toCategory: selectedCategory.title)
        trackersVC?.updateCollectionViewWithNewTracker()
    }
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        chooseCategoryVC.trackersVC = self.trackersVC
        present(chooseCategoryVC, animated: true)
    }
    
    @objc private func scheduleButtonTapped(_ sender: UIButton) {
        present(scheduleScreenVC, animated: true)
    }
    
    @objc private func createButtonTapped(_ sender: UIButton) {
        createNewTracker()

        self.dismiss(animated: true) { [weak self] in
            guard let delegate = self?.delegate else { return }
            delegate.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        if selectedCategory != nil && !selectedWeekdays.isEmpty && !(trackerNameTextField.text?.isEmpty ?? true) {
            createButton.isEnabled = true
            createButton.alpha = 1.0
        } else {
            createButton.isEnabled = false
            createButton.alpha = 0.5
        }
    }
}


