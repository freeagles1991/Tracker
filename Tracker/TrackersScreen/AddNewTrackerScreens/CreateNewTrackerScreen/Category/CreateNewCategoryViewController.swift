//
//  AddNewCategoryViewController.swift
//  Tracker
//
//  Created by Дима on 10.08.2024.
//
import Foundation
import UIKit

final class CreateNewCategoryViewController: UIViewController {
    private var viewModel: CreateNewCategoryViewModel
    
    weak var delegate: ChooseCategoryViewModel?
    
    private var screenTitle = UILabel()
    private let screenTitleString: String = "Новая категория"
    
    private var categoryNameTextField = UITextField()
    private let categoryNamePlaceholderString: String = "Введите название категории"
    
    private var doneButton = UIButton()
    private let doneButtonString: String = "Готово"
    
    init(viewModel: CreateNewCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addTapGestureToHideKeyboard()
        
        setupScreenTitle()
        setupCategoryNameTextField()
        setupDoneButton()
        
        bindViewModel()
        viewModel.updateDoneButtonState()
    }
    
    private func bindViewModel() {
        viewModel.onCategoryNameChanged = { [weak self] text in
            self?.categoryNameTextField.text = text
        }
        
        viewModel.onDoneButtonStateChanged = { [weak self] isEnabled in
            guard let self else { return }
            self.doneButton.isEnabled = isEnabled
            self.doneButton.alpha = isEnabled ? 1.0 : 0.5
        }
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
    
    @objc private func textFieldDidChange() {
        viewModel.categoryName = categoryNameTextField.text ?? ""
        viewModel.updateDoneButtonState()
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        viewModel.createNewCategory()
        
        if let delegate {
            delegate.loadCategories()
        }
        
        dismiss(animated: true, completion: nil)
    }
}

