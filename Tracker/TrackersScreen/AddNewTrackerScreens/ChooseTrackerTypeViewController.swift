//
//   ChooseTrackerTypeViewController.swift
//  Tracker
//
//  Created by Дима on 04.08.2024.
//

import Foundation
import UIKit

final class  ChooseTrackerTypeViewController: UIViewController {
    weak var trackersVC: TrackersViewController?
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setupScreenTitle() {
        let label = UILabel()
        let font = UIFont(name: "SFProText-Medium", size: 16)
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
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16)
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
        guard let habitButton = habitButton, let eventButton = eventButton else { return }
        let stackView = UIStackView(arrangedSubviews: [habitButton, eventButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        NSLayoutConstraint.activate([
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func habitButtonTapped(_ sender: UIButton) {
        if let navigationController = self.navigationController {
            let createNewHabitVC = CreateNewTrackerViewController()
            createNewHabitVC.delegate = self
            createNewHabitVC.trackersVC = self.trackersVC
            createNewHabitVC.configureTrackerType(isRegularEvent: true)
            
            navigationController.pushViewController(createNewHabitVC, animated: true)
        }
    }
    
    @objc private func eventButtonTapped(_ sender: UIButton) {
        if let navigationController = self.navigationController {
            let createNewEventVC = CreateNewTrackerViewController()
            createNewEventVC.delegate = self
            createNewEventVC.trackersVC = self.trackersVC
            createNewEventVC.configureTrackerType(isRegularEvent: false)
            
            navigationController.pushViewController(createNewEventVC, animated: true)
        }
    }
}
