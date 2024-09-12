//
//  ScheduleScreenViewModel.swift
//  Tracker
//
//  Created by Дима on 11.09.2024.
//

import Foundation

final class ScheduleScreenViewModel {
    private(set) var selectedWeekdays = Set<Weekday>()
    var switchStates = [Bool](repeating: false, count: Weekday.allCases.count)
    
    var isDoneButtonEnabled: Bool {
        print(!selectedWeekdays.isEmpty)
        return !selectedWeekdays.isEmpty
    }
    
    var onScheduleChanged: Binding<Set<Weekday>>?
    var onSwitchStateChenged: Binding<[Bool]>?
    var onDoneButtonStateChanged: Binding<Bool>?
    
    func toggleWeekday(at index: Int, isOn: Bool ) {
        let weekday = Weekday.allCases[index]
        
        if isOn {
            selectedWeekdays.insert(weekday)
        } else {
            selectedWeekdays.remove(weekday)
        }
        
        switchStates[index] = isOn
        
        onScheduleChanged?(selectedWeekdays)
        onSwitchStateChenged?(switchStates)
    }
    
    func updateDoneButtonState() {
        onDoneButtonStateChanged?(isDoneButtonEnabled)
    }
    
    func initialSelectedWeekdays(_ weekdays: Set<Weekday>) {
        selectedWeekdays = weekdays
        updateSwitchStates()
    }
    
    private func updateSwitchStates() {
        for (index, weekday) in Weekday.allCases.enumerated() {
            switchStates[index] = selectedWeekdays.contains(weekday)
        }
        onSwitchStateChenged?(switchStates)
    }
}
