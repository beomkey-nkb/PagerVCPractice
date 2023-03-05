//
//  RandomImageListViewController.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/05.
//

import Foundation
import UIKit
import Combine

final class RandomImageListViewController: UIViewController {
    private var viewModel = RandomImageListViewModel()
    private var collectionView = UICollectionView()
    private var dataSource: UICollectionViewDiffableDataSource<Section, RandomImageCellViewModel>!
    
    enum Section: String {
        case landomImageList = "RandomImageList"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupStyling()
        setupCollectionViewDataSource()
    }
}

// MARK: Presentable

extension RandomImageListViewController {
    
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        constraints += [
            collectionView.topAnchor.constraint(equalTo: view.safeTopAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupStyling() {
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = true
        collectionView.delegate = self
        collectionView.registerCell(cellType: RandomImageCollectionViewCell.self)
    }
}

// MARK: CollectionView setup

extension RandomImageListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func setupCollectionViewDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, RandomImageCellViewModel>.init(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                let cell: RandomImageCollectionViewCell = collectionView.dequeueCell(indexPath: indexPath)
                cell.configure(itemIdentifier)
                cell.contentView.backgroundColor = .yellow
                return cell
            }
        )
    }
    
    func applyDataSource(_ cellViewModels: [RandomImageCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, RandomImageCellViewModel>()
        snapshot.appendSections([.landomImageList])
        snapshot.appendItems(cellViewModels, toSection: .landomImageList)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let paddingX = 64
        let spacing = 32
        let cellWidth = (Int(screenWidth) - paddingX - spacing) / 3
        return CGSize(width: cellWidth, height: 96)
    }
}
