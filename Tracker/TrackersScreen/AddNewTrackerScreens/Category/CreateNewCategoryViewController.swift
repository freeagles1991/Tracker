//
//  AddNewCategoryViewController.swift
//  Tracker
//
//  Created by Дима on 10.08.2024.
//
import Foundation
import UIKit

final class CreateNewCategoryViewController: UIViewController {
    private let trackersCategoryStore = TrackerCategoryStore.shared
    weak var delegate: ChooseCategoryViewController?
    
    private var screenTitle = UILabel()
    private let screenTitleString: String = "Новая категория"
    
    private var categoryNameTextField = UITextField()
    private let categoryNamePlaceholderString: String = "Введите название категории"
    
    private var doneButton = UIButton()
    private let doneButtonString: String = "Готово"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addTapGestureToHideKeyboard()
        
        setupScreenTitle()
        setupCategoryNameTextField()
        setupDoneButton()
        updateDoneButtonState()
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
    
    private func setupCategoryNameTextField() {
        let textField = UITextField()
        textField.placeholder = categoryNamePlaceholderString
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        self.categoryNameTextField = textField
    }
    
    private func setupDoneButton(){
        doneButton.setTitle(doneButtonString, for: .normal)
        doneButton.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16)
        doneButton.backgroundColor = .black
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 16
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
    }
    
    private func updateDoneButtonState() {
        let textIsEmpty = categoryNameTextField.text?.isEmpty ?? true
        doneButton.isEnabled = !textIsEmpty
        doneButton.alpha = textIsEmpty ? 0.5 : 1.0
    }
    
    @objc private func textFieldDidChange() {
        updateDoneButtonState()
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        guard let categoryName = categoryNameTextField.text, !categoryName.isEmpty else {
            print("Название категории не может быть пустым.")
            return
        }
        
        let newCategory = TrackerCategory(title: categoryName, trackers: [])
        
        trackersCategoryStore.createCategory(with: newCategory)
        delegate?.updateTableView()
        
        dismiss(animated: true, completion: nil)
    }
}

