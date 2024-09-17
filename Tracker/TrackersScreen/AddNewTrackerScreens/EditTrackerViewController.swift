//
//  EditTrackerViewController.swift
//  Tracker
//
//  Created by Дима on 16.09.2024.
//

import Foundation
import UIKit

final class EditTrackerViewController: CreateNewTrackerViewController {
    private let screenTitleString: String = NSLocalizedString("CreateNewTracker_screenTitleString", comment: "Новая привычка")
    private let editButtonString: String = NSLocalizedString("CreateNewTracker_screenTitleString", comment: "Новая привычка")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.setScreenTitle(screenTitleString)
        super.setCreateButtonTitle(editButtonString)
    }
}
