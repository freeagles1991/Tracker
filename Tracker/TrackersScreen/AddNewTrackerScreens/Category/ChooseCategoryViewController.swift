//
//  ChooseCategoryViewController.swift
//  Tracker
//
//  Created by Дима on 10.08.2024.
//

import Foundation
import UIKit

final class ChooseCategoryViewController: UIViewController {
    private var category: [TrackerCategory] = []
    
    private var screenTitle = UILabel()
    private let screenTitleString: String = "Категория"
    
    private var addCategoryButton = UIButton()
    private let addCategoryButtonString: String = "Добавить категорию"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupScreenTitle()
        setupAddCategoryButton()
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
    
    private func setupAddCategoryButton(){
        addCategoryButton.setTitle(addCategoryButtonString, for: .normal)
        addCategoryButton.backgroundColor = .black
        addCategoryButton.setTitleColor(.white, for: .normal)
        addCategoryButton.layer.cornerRadius = 8
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func addCategoryButtonTapped(_ sender: UIButton) {
        let createNewCategoryVC = CreateNewCategoryViewController()
        present(createNewCategoryVC, animated: true)
    }
}
