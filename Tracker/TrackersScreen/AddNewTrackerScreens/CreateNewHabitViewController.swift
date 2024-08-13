//
//  CreateNewHabitViewController.swift
//  Tracker
//
//  Created by Дима on 05.08.2024.
//

import Foundation
import UIKit

final class CreateNewHabitViewController: UIViewController {
    private let chooseCategoryVC = ChooseCategoryViewController()
    private let scheduleScreenVC = ScheduleScreenViewController()
    private var category: TrackerCategory?
    private var newTracker: Tracker?
    private var selectedWeekdays = Set<Weekday>()
    
    private var screenTitle = UILabel()
    private let screenTitleString: String = "Новая привычка"
    
    private var textField = UITextField()
    private let textFieldString: String = "Введите название трекера"
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        chooseCategoryVC.delegate = self
        scheduleScreenVC.delegate = self
        
        setupScreenTitle()
        setupTextField()
        setupParametresStackView()
        setupScreenControlsStackView()
    }
    
    private func setupScreenTitle() {
        let label = UILabel()
        let font = UIFont(name: "SF Pro", size: 16)
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
        textField.font = UIFont(name: "SF Pro", size: 16)
        textField.borderStyle = .none
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.backgroundColor = UIColor(white: 0.95, alpha: 1)
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        // Отступы слева и справа
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        self.textField = textField
    }
    
    private func setupParametersBaseButton(with text: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "SF Pro", size: 17)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor(named: "lightGrey")
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 40) // Увеличиваем правый отступ для изображения
        
        // Настройка для многострочного текста
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
        paragraphStyle.lineSpacing = 2 // Задаем нужный межстрочный интервал
        
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
        paragraphStyle.lineSpacing = 2 // Задаем нужный межстрочный интервал
        
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
            stackView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupBaseButton(with text: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "SF Pro", size: 16)
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
        self.category = category
        updateCategoryButton(with: category.title)
    }
    
    func updateSelectedWeekdays(_ selectedWeekdays: Set<Weekday>) {
        self.selectedWeekdays = selectedWeekdays
        print("Выбранные дни - \(selectedWeekdays) - сохранены")
        let selectedWeekdaysString = self.convertWeekdaysToString(selectedWeekdays)
        updateSheduleButton(with: selectedWeekdaysString)
    }
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        present(chooseCategoryVC, animated: true)
    }
    
    @objc private func scheduleButtonTapped(_ sender: UIButton) {
        present(scheduleScreenVC, animated: true)
    }
    
    @objc private func createButtonTapped(_ sender: UIButton) {
        //Создание трекера с выбранными параметрами
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}


