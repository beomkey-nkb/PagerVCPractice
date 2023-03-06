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
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, RandomImageCellViewModel>!
    private var cancellables = Set<AnyCancellable>()
    
    enum Section: String {
        case landomImageList = "RandomImageList"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupStyling()
        setupCollectionViewDataSource()
        bind(viewModel: viewModel)
        viewModel.loadRandomDataSource()
    }
    
    private func bind(viewModel: RandomImageListViewModel) {
        viewModel
            .$dataSource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cellViewModel in
                self?.applyDataSource(cellViewModel)
            }
            .store(in: &cancellables)
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
        return CGSize(width: cellWidth, height: 150)
    }
}
