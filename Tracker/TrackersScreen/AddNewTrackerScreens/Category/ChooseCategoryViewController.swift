//
//  ChooseCategoryViewController.swift
//  Tracker
//
//  Created by Дима on 10.08.2024.
//

import Foundation
import UIKit

final class ChooseCategoryViewController: UIViewController {
    private let trackersCategoryStore = TrackerCategoryStore.shared
    
    weak var delegate: CreateNewTrackerViewController?
    
    private var screenTitle = UILabel()
    private let screenTitleString: String = "Категория"
    
    var tableView = UITableView()
    
    private var addCategoryButton = UIButton()
    private let addCategoryButtonString: String = "Добавить категорию"
    
    private var isSelectedArray = [Bool](repeating: false, count: 7)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        trackersCategoryStore.chooseCategoryVC = self
        
        setupScreenTitle()
        setupTableView()
        setupAddCategoryButton()
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
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupAddCategoryButton(){
        addCategoryButton.setTitle(addCategoryButtonString, for: .normal)
        addCategoryButton.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16)
        addCategoryButton.backgroundColor = .black
        addCategoryButton.setTitleColor(.white, for: .normal)
        addCategoryButton.layer.cornerRadius = 16
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

extension ChooseCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = trackersCategoryStore.numberOfRowsInSection(section)
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = trackersCategoryStore.object(at: indexPath)?.title
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        cell.backgroundColor = UIColor(named: "background")
        
        if isSelectedArray[indexPath.row] {
            cell.accessoryView = UIImageView(image: UIImage(systemName: "checkmark"))
        } else {
            cell.accessoryView = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let choosenCategory = trackersCategoryStore.categories[indexPath.row]
        print("Выбрана категория: \(choosenCategory.title)")
        
        isSelectedArray[indexPath.row].toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        delegate?.updateCategory(choosenCategory)
        dismiss(animated: true, completion: nil)
    }
}
