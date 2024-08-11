//
//  CreateNewTrackerViewController.swift
//  Tracker
//
//  Created by Дима on 04.08.2024.
//

import Foundation
import UIKit

final class CreateNewTrackerViewController: UIViewController {
    private var screenTitle: UILabel?
    private let screenTitleString = "Создание трекера"
    
    private var habitButton: UIButton?
    private let habitButtonText = "Привычка"
    
    private var eventButton: UIButton?
    private let eventButtonText = "Нерегулярное событие"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupScreenTitle()
        setupHabitButton()
        setupEventButton()
        setupStackView()
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
    
    private func setupButton(with text: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        return button
    }
    
    private func setupHabitButton() {
        let habitButton = self.setupButton(with: habitButtonText)
        habitButton.addTarget(self, action: #selector(habitButtonTapped(_:)), for: .touchUpInside)
        
        self.habitButton = habitButton
    }
    
    private func setupEventButton() {
        let eventButton = self.setupButton(with: eventButtonText)
        eventButton.addTarget(self, action: #selector(eventButtonTapped(_:)), for: .touchUpInside)
        
        self.eventButton  = eventButton
    }
    
    private func setupStackView() {
        // Создание StackView для кнопок
        guard let habitButton = habitButton, let eventButton = eventButton else { return }
        let stackView = UIStackView(arrangedSubviews: [habitButton, eventButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        // Добавление StackView на view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Установка constraints для StackView
        NSLayoutConstraint.activate([
            // Центрирование StackView по горизонтали
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // Центрирование StackView по вертикали
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        // Установка constraints для кнопок
        NSLayoutConstraint.activate([
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func habitButtonTapped(_ sender: UIButton) {
        let createNewHabitVC = CreateNewHabitViewController()
        present(createNewHabitVC, animated: true)
    }
    
    @objc private func eventButtonTapped(_ sender: UIButton) {
        
    }
}
