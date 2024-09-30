//
//  AddNewCategoryViewController.swift
//  Tracker
//
//  Created by Дима on 10.08.2024.
//
import Foundation
import UIKit

final class CreateNewCategoryViewController: UIViewController {
    var viewModel: CreateNewCategoryViewModel
    
    weak var delegate: ChooseCategoryViewModel?
    
    private var screenTitle = UILabel()
    private let screenTitleString: String = NSLocalizedString("CreateNewCategory_screenTitleString", comment: "Новая категория")
    
    private var categoryNameTextField = UITextField()
    private let categoryNamePlaceholderString: String = NSLocalizedString("CreateNewCategory_categoryNamePlaceholderString", comment: "Введите название категории")
    
    private var doneButton = UIButton()
    private let doneButtonString: String = NSLocalizedString("CreateNewCategory_doneButtonString", comment: "Готово")
    
    init(viewModel: CreateNewCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "white")
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
        
        self.categoryNameTextField = textField
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
    
    private func setupDoneButton(){
        doneButton.setTitle(doneButtonString, for: .normal)
        doneButton.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16)
        doneButton.backgroundColor = .black
        doneButton.setTitleColor(UIColor(named: "white"), for: .normal)
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

