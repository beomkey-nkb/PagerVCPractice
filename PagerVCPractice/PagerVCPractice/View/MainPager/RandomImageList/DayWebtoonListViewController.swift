//
//  RandomImageListViewController.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/05.
//

import Foundation
import UIKit
import Combine

final class DayWebtoonListViewController: UIViewController {
    private var viewModel = DayWebtoonListViewModel()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, WebtoonImageCellViewModel>!
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
    }
    
    private func bind(viewModel: DayWebtoonListViewModel) {
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

extension DayWebtoonListViewController {
    
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        constraints += [
            collectionView.topAnchor.constraint(equalTo: view.safeTopAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupStyling() {
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.registerCell(cellType: DayWebtoonCollectionViewCell.self)
    }
}

// MARK: CollectionView setup

extension DayWebtoonListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func setupCollectionViewDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, WebtoonImageCellViewModel>.init(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                let cell: DayWebtoonCollectionViewCell = collectionView.dequeueCell(indexPath: indexPath)
                cell.configure(itemIdentifier)
                return cell
            }
        )
    }
    
    func applyDataSource(_ cellViewModels: [WebtoonImageCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, WebtoonImageCellViewModel>()
        snapshot.appendSections([.landomImageList])
        snapshot.appendItems(cellViewModels, toSection: .landomImageList)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let paddingX = 32
        let spacing = 16
        let cellWidth = (Int(screenWidth) - paddingX - spacing) / 3 - 2
        return CGSize(width: cellWidth, height: 200)
    }
}
