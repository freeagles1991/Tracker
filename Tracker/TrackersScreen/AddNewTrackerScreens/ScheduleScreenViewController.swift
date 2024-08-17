//
//  ScheduleScreenViewController.swift
//  Tracker
//
//  Created by Дима on 05.08.2024.
//

import Foundation
import UIKit

final class ScheduleScreenViewController: UIViewController {
    weak var delegate: CreateNewHabitViewController?
    
    private var screenTitle = UILabel()
    private let screenTitleString: String = "Новая привычка"
    
    private let tableView = UITableView()
    private let tableContainerView = UIView()
    private let daysOfWeek = Weekday.allCases
    private var selectedWeekdays = Set<Weekday>()
    private var switchStates = [Bool](repeating: false, count: 7)
    
    private let doneButton = UIButton()
    private var doneButtonString = "Готово"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupScreenTitle()
        setupDoneButton()
        setupTableView()
    }
    
    private func setupScreenTitle() {
        let label = UILabel()
        let font = UIFont.systemFont(ofSize: 16)
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
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 8
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
    
    @objc func switchChanged(_ sender: UISwitch) {
        let weekday = daysOfWeek[sender.tag]
        
        if sender.isOn {
            selectedWeekdays.insert(weekday)
        } else {
            selectedWeekdays.remove(weekday)
        }
    }
    
    @objc func doneButtonTapped(_ sender: UIButton) {
        delegate?.updateSelectedWeekdays(selectedWeekdays)
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
        cell.textLabel?.text = weekday.rawValue
        cell.backgroundColor = UIColor(named: "lightGrey")
        
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(switchStates[indexPath.row], animated: true)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

