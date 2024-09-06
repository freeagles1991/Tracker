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
    
    private let scrollView = UIScrollView()
    
    let tableView = UITableView()
    private let tableContainerView = UIView()
    private var tableContainerViewHeightConstraint = NSLayoutConstraint()
    
    private var addCategoryButton = UIButton()
    private let addCategoryButtonString: String = "Добавить категорию"
    
    private var cellHeight: CGFloat = 75
    private var cellCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        trackersCategoryStore.chooseCategoryVC = self
        
        setupScreenTitle()
        setupAddCategoryButton()
        setupScrollView()
        setupTableView()
        
        loadData()
        
    }

    
    private func setupScreenTitle() {
        let label = UILabel()
        let font = UIFont(name: "SFProText-Medium", size: 16)
        label.text = screenTitleString
        label.textColor = .black
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(label)
        
        label.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 22).isActive = true
        label.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.06).isActive = true
        
        self.screenTitle = label
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = true
        tableContainerView.layer.cornerRadius = 16
        tableContainerView.clipsToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        scrollView.addSubview(tableContainerView)
        tableContainerView.addSubview(tableView)
        tableContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableContainerView)
        
        NSLayoutConstraint.activate([
            tableContainerView.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: 30),
            tableContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            tableContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            //tableContainerView.heightAnchor.constraint(equalToConstant: 100),
            
            tableView.topAnchor.constraint(equalTo: tableContainerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainerView.bottomAnchor),
        ])
        
        tableContainerViewHeightConstraint = tableContainerView.heightAnchor.constraint(equalToConstant: 100)
        tableContainerViewHeightConstraint.isActive = true
    }
    
    func loadData() {

        self.tableView.reloadData()

        adjustTableViewHeight()
    }

    private func adjustTableViewHeight() {
        // Обновляем компоновку таблицы
        tableView.layoutIfNeeded()

        // Рассчитываем высоту таблицы на основе ее содержимого
        let tableHeight = cellHeight * CGFloat(cellCount)
        let maxTableHeight: CGFloat = 500  // Например, максимальная высота для таблицы
        let finalHeight = min(tableHeight, maxTableHeight)

        // Обновляем constraint высоты контейнера
        tableContainerViewHeightConstraint.constant = finalHeight
        
        // Применяем изменения
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
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
        createNewCategoryVC.delegate = self
        present(createNewCategoryVC, animated: true)
    }
}

extension ChooseCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = trackersCategoryStore.numberOfRowsInSection(section)
        cellCount = count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = trackersCategoryStore.object(at: indexPath)?.title
        cell.backgroundColor = UIColor(named: "background")
        cell.accessoryView = nil
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let choosenCategory = trackersCategoryStore.categories[indexPath.row]
        print("Выбрана категория: \(choosenCategory.title)")
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        delegate?.updateCategory(choosenCategory)
        dismiss(animated: true, completion: nil)
    }
    
}

