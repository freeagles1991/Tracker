//
//  StatisticsCell.swift
//  Tracker
//
//  Created by Дима on 23.09.2024.
//

import Foundation
import UIKit

final class SatisticsCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFProText-Bold", size: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFProText-Medium", size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    private let gradientLayer = CAGradientLayer()
    let shapeLayer = CAShapeLayer()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupGradientFill()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
        setupGradientFill()
    }
    
    private func setupLayout() {
        containerView.addSubview(numberLabel)
        containerView.addSubview(descriptionLabel)
        contentView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            numberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            numberLabel.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 12),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: numberLabel.leadingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }

    func setupGradientFill() {
        layoutIfNeeded()
        gradientLayer.colors = [
            UIColor.red.cgColor,
            UIColor.green.cgColor,
            UIColor.blue.cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        if gradientLayer.superlayer == nil {
            containerView.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        gradientLayer.frame = containerView.bounds
        gradientLayer.cornerRadius = containerView.layer.cornerRadius
        
        shapeLayer.path = UIBezierPath(roundedRect: containerView.bounds.insetBy(dx: 1.5, dy: 1.5), cornerRadius: 16).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 1

        gradientLayer.mask = shapeLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = containerView.bounds
        gradientLayer.cornerRadius = containerView.layer.cornerRadius
    }

    func configure(with number: String, description: String) {
        numberLabel.text = number
        descriptionLabel.text = description
        selectionStyle = .none
    }
}






