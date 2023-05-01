//
//  WebtoonDayView.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/04/29.
//

import Foundation
import UIKit
import Combine

final class WebtoonDayView: UIView {
    private let viewModel: WebtoonDayViewModel
    private var collectionView: UICollectionView! = nil
    private var deviderView = UIView()
    private var dataSource: UICollectionViewDiffableDataSource<String, WebtoonDayCellViewModel>!
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: WebtoonDayViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupCollectionView()
        self.setupCollectionViewDataSource()
        self.setupLayout()
        self.setupStyling()
        self.bind(viewModel: viewModel)
    }
    
    func bind(viewModel: WebtoonDayViewModel) {
        viewModel
            .$dataSource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cellViewModel in
                self?.applyDataSource(cellViewModel)
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WebtoonDayView {
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let deviceWidth = UIScreen.main.bounds.width
        layout.itemSize = CGSize(width: deviceWidth / 8, height: 49)
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.isScrollEnabled = true
        collectionView.registerCell(cellType: WebtoonDayCollectionViewCell.self)
    }
    
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        deviderView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(collectionView)
        constraints += [
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: deviderView.topAnchor)
        ]
        
        addSubview(deviderView)
        constraints += [
            deviderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            deviderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            deviderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            deviderView.heightAnchor.constraint(equalToConstant: 1)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupStyling() {
        deviderView.backgroundColor = .lightGray.withAlphaComponent(0.5)
    }
}

extension WebtoonDayView: UICollectionViewDelegate {
    
    private func setupCollectionViewDataSource() {
        dataSource = UICollectionViewDiffableDataSource<String, WebtoonDayCellViewModel>.init(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                let cell: WebtoonDayCollectionViewCell = collectionView.dequeueCell(indexPath: indexPath)
                cell.configure(itemIdentifier)
                return cell
            }
        )
    }
    
    private func applyDataSource(_ cellViewModels: [WebtoonDayCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, WebtoonDayCellViewModel>()
        let section = "days"
        snapshot.appendSections([section])
        snapshot.appendItems(cellViewModels, toSection: section)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.changeFocus(index: indexPath.item)
    }
}
