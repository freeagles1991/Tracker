//
//  CreateNewHabitViewController.swift
//  Tracker
//
//  Created by Дима on 05.08.2024.
//

import Foundation
import UIKit

final class CreateNewHabitViewController: UIViewController {
    private var screenTitle: UILabel?
    private let screenTitleString: String = "Новая привычка"
    
    private var textField: UITextField?
    private let textFieldString: String = "Введите название трекера"
    
    private var categoryButton: UIButton?
    private let categoryButtonString: String = "Категория"
    
    private var scheduleButton: UIButton?
    private let scheduleButtonString: String = "Расписание"
    
    private var cancelButton: UIButton?
    private let cancelButtonString: String = "Отменить"
    
    private var createButton: UIButton?
    private let createButtonString: String = "Создать"
    
}
