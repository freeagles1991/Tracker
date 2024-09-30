//
//  CategoryCell.swift
//  Tracker
//
//  Created by Дима on 12.09.2024.
//

import Foundation
import UIKit

final class CategoryCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = UIColor(named: "background")
        textLabel?.font = UIFont.systemFont(ofSize: 17)
    }
    
    func configure(with title: String, isSelected: Bool) {
        textLabel?.text = title
        accessoryType = isSelected ? .checkmark : .none
    }
}
