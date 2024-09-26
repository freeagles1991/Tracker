//
//  ScheduleScreenViewController.swift
//  Tracker
//
//  Created by Дима on 05.08.2024.
//

import Foundation
import UIKit

final class ScheduleScreenViewController: UIViewController {
    var viewModel: ScheduleScreenViewModel
    
    weak var delegate: CreateNewTrackerViewController?
    
    private var screenTitle = UILabel()
    private let screenTitleString: String = NSLocalizedString("ScheduleScreen_screenTitleString", comment: "Расписание")
    
    private let tableView = UITableView()
    private let tableContainerView = UIView()
    private let daysOfWeek = Weekday.allCases
    
    private let doneButton = UIButton()
    private var doneButtonString = NSLocalizedString("ScheduleScreen_doneButtonString", comment: "Готово")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "white")
        setupScreenTitle()
        setupDoneButton()
        setupTableView()
        
        bindViewModel()
        viewModel.updateDoneButtonState()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if !viewModel.selectedWeekdays.isEmpty {
            viewModel.initialSelectedWeekdays(viewModel.selectedWeekdays)
        }
    }
    
    init(viewModel: ScheduleScreenViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindViewModel() {
        viewModel.onSwitchStateChenged = { [weak self] _ in
            self?.tableView.performBatchUpdates(nil)
            self?.viewModel.updateDoneButtonState()
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
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
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
            tableContainerView.bottomAnchor.constraint(equalTo: doneButton.topAnchor,constant: -77),
            
            tableView.topAnchor.constraint(equalTo: tableContainerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainerView.bottomAnchor),
        ])
    }
    
    private func setupDoneButton(){
        doneButton.setTitle(doneButtonString, for: .normal)
        doneButton.backgroundColor = .black
        doneButton.setTitleColor(UIColor(named: "white"), for: .normal)
        doneButton.layer.cornerRadius = 16
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc func doneButtonTapped(_ sender: UIButton) {
        guard let delegate else { return }
        delegate.updateSelectedWeekdays(viewModel.selectedWeekdays)
        dismiss(animated: true, completion: nil)
    }
}

extension ScheduleScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let weekday = daysOfWeek[indexPath.row]
        cell.textLabel?.text = weekday.localized
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.backgroundColor = UIColor(named: "background")
        
        let switchView = UISwitch(frame: .zero)
        switchView.onTintColor = UIColor(named: "blue")
        switchView.setOn(viewModel.switchStates[indexPath.row], animated: true)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        viewModel.toggleWeekday(at: sender.tag, isOn: sender.isOn)
    }
}

