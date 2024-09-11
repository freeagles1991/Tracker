//
//  ChooseCategoryViewController.swift
//  Tracker
//
//  Created by Дима on 10.08.2024.
//

import Foundation
import UIKit

final class ChooseCategoryViewController: UIViewController {
    private var viewModel: ChooseCategoryViewModel
    
    weak var delegate: CreateNewTrackerViewController?
    
    private var screenTitle = UILabel()
    private let screenTitleString: String = "Категория"
    
    let tableView = UITableView()
    private let tableContainerView = UIView()
    private var tableContainerViewHeightConstraint = NSLayoutConstraint()
    private var selectedIndexPath: IndexPath?
    
    private var addCategoryButton = UIButton()
    private let addCategoryButtonString: String = "Добавить категорию"
    
    private var cellHeight: CGFloat = 75
    private var cellCount: Int = 0
    private let maxTableHeight: CGFloat = 580
    
    init(viewModel: ChooseCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupScreenTitle()
        setupAddCategoryButton()
        setupTableView()
        
        bindViewModel()
        viewModel.loadCategories()
    }

    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] categories in
            self?.cellCount = categories.count
            self?.tableView.reloadData()
            self?.adjustTableViewHeight()
        }
        
        viewModel.onCategorySelected = { [weak self] selectedCategory in
            guard let self, let delegate = self.delegate, let selectedCategory else { return }
            delegate.updateCategory(selectedCategory)
            self.dismiss(animated: true, completion: nil)
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
        
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 22).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.06).isActive = true
        
        self.screenTitle = label
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = true
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        tableContainerView.addSubview(tableView)
        tableContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableContainerView)
        
        NSLayoutConstraint.activate([
            tableContainerView.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: 30),
            tableContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: tableContainerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainerView.bottomAnchor),
        ])
        
        tableContainerViewHeightConstraint = tableContainerView.heightAnchor.constraint(equalToConstant: 75)
        tableContainerViewHeightConstraint.isActive = true
    }
    
    private func setupAddCategoryButton() {
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
        let createNewCategoryVC = CreateNewCategoryViewController(viewModel: CreateNewCategoryViewModel())
        createNewCategoryVC.delegate = viewModel
        present(createNewCategoryVC, animated: true)
    }
    
    private func adjustTableViewHeight() {
        tableView.layoutIfNeeded()

        let tableHeight = cellHeight * CGFloat(cellCount)
        let finalHeight = min(tableHeight, maxTableHeight)

        tableContainerViewHeightConstraint.constant = finalHeight
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }

}

extension ChooseCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        let category = viewModel.categories[indexPath.row]
        cell.textLabel?.text = category.title
        cell.backgroundColor = UIColor(named: "background")
        cell.accessoryType = (indexPath == selectedIndexPath) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        selectedIndexPath = indexPath
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

}
