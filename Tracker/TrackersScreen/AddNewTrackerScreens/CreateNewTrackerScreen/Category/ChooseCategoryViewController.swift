//
//  ChooseCategoryViewController.swift
//  Tracker
//
//  Created by Дима on 10.08.2024.
//

import Foundation
import UIKit

final class ChooseCategoryViewController: UIViewController {
    var viewModel: ChooseCategoryViewModel
    
    weak var delegate: CreateNewTrackerViewController?
    
    private var screenTitle = UILabel()
    
    private let screenTitleString = NSLocalizedString("CategoryScreen_screenTitleString", comment: "Категория")
    private let emptyStateString = NSLocalizedString("CategoryScreen_emptyStateString", comment: "Привычки и события можно объединить по смыслу")
    private let addCategoryButtonString = NSLocalizedString("CategoryScreen_addCategoryButtonString", comment: "Добавить категорию")
    
    private lazy var emptyStateView = UIView()
    let tableView = UITableView()
    private let tableContainerView = UIView()
    private var tableContainerViewHeightConstraint = NSLayoutConstraint()
    private var selectedIndexPath: IndexPath?
    
    private var addCategoryButton = UIButton()
    
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
        view.backgroundColor = UIColor(named: "white")
        
        setupScreenTitle()
        setupAddCategoryButton()
        setupTableView()
        setupEmptyStateView()
        
        bindViewModel()
        viewModel.loadCategories()
        
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if let selectedCategory = viewModel.selectedCategory,
           let index = viewModel.categories.firstIndex(where: { $0.title == selectedCategory.title }) {
            let indexPath = IndexPath(row: index, section: 0)
            selectedIndexPath = indexPath
            tableView.reloadData()
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] categories in
            let isCategoryListEmpty = categories.isEmpty
            if isCategoryListEmpty {
                self?.updateUI(isCategoryListEmpty)
            } else {
                self?.updateUI(isCategoryListEmpty)
                self?.cellCount = categories.count
                self?.tableView.reloadData()
                self?.adjustTableViewHeight()
            }
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
    
    private func setupEmptyStateView() {
        let emptyStateView = UIView()
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        
        let imageView = UIImageView(image: UIImage(named: "emptyTrackersIcon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(imageView)
        
        let label = UILabel()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 9

        let attributedString = NSMutableAttributedString(string: emptyStateString)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        label.attributedText = attributedString
        
        label.font = UIFont(name: "SFProText-Medium", size: 12)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(label)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
        
        self.emptyStateView = emptyStateView
    }
    
    private func setupTableView() {
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "categoryCell")
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
        addCategoryButton.setTitleColor(UIColor(named: "white"), for: .normal)
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
    
    private func updateUI(_ isCategoryListEmpty: Bool) {
        tableContainerView.isHidden = isCategoryListEmpty ? true : false
        emptyStateView.isHidden = isCategoryListEmpty ? false : true
    }
}

extension ChooseCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryCell else {
            return CategoryCell()
        }
        let category = viewModel.categories[indexPath.row]
        cell.configure(with: category.title, isSelected: indexPath == selectedIndexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousIndexPath = selectedIndexPath
        viewModel.selectCategory(at: indexPath.row)
        selectedIndexPath = indexPath
        
        var indexPathsToReload: [IndexPath] = [indexPath]
        if let previousIndexPath = previousIndexPath {
            indexPathsToReload.append(previousIndexPath)
        }
        
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

}
