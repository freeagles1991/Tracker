//
//  ColorCollectionViewDataSourceDelegate.swift
//  Tracker
//
//  Created by Дима on 22.08.2024.
//

import Foundation
import UIKit

final class ColorCollectionViewDataSourceDelegate: NSObject, UICollectionViewDataSource,
                                                   UICollectionViewDelegateFlowLayout,
                                                   UICollectionViewDelegate {
    var createNewTrackerVC: CreateNewTrackerViewController?
    
    let itemsPerRow: CGFloat = 6
    let sectionInsets = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 19)
    let interItemSpacing: CGFloat = 5
    
    // MARK: - UICollectionViewDataSource
    ///Количество секций
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    /// Количество элементов в секци
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = CreateNewTrackerViewController.Constants.colors.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell else { return ColorCell() }
        let colorHex = CreateNewTrackerViewController.Constants.colors[indexPath.row]
        cell.configure(with: UIColor(hexString: colorHex) ?? .black)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ColorHeader", for: indexPath) as? ColorHeaderView else { return ColorCell() }
        headerView.label.text = CreateNewTrackerViewController.Constants.colorHeaderString
        return headerView
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else { return }
        if let colorHex = cell.color?.toHexString {
            createNewTrackerVC?.updateSelectedColor(with: colorHex)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let screenWidth = createNewTrackerVC?.view.frame.width else {return CGSize()}
        let paddingSpace = sectionInsets.left + sectionInsets.right + interItemSpacing * (itemsPerRow - 1)
        let availableWidth = screenWidth - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        let heightPerItem = widthPerItem
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    ///Настраиваем размер layout для заголовка секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    // Отступы для секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // Горизонтальное расстояние между ячейками
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    
    // Вертикальные отступы между строками ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

