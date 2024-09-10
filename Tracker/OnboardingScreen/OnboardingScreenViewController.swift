//
//  OnboardingScreenViewController.swift
//  Tracker
//
//  Created by Дима on 09.09.2024.
//

import Foundation
import UIKit

final class  OnboardingScreenViewController: UIViewController {
    private let backgroundImageString: String?
    
    private let screenTextString: String?
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "black")
        label.font = UIFont(name: "SFProText-Bold", size: 32)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    init(backgroundImageString: String?, screenTextString: String?) {
        self.backgroundImageString = backgroundImageString
        self.screenTextString = screenTextString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundView()
        setupLabel()
    }
    
    
    private func setupBackgroundView() {
        guard let backgroundImageString, let image = UIImage(named: backgroundImageString) else { return }
        view.setBackgroundImage(image)
    }
    
    private func setupLabel() {
        label.text = screenTextString
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 60),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
}
