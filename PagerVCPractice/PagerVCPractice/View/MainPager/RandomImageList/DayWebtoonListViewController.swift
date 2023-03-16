//
//  RandomImageListViewController.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/05.
//

import Foundation
import UIKit
import Combine

enum DayWebtoonListSection: Int {
    case dayWebtoonList
}

final class DayWebtoonListViewController: UIViewController {
    private var viewModel = DayWebtoonListViewModel()
    
    private var collectionView: UICollectionView! = nil
    private var dataSource: UICollectionViewDiffableDataSource<Section, WebtoonImageCellViewModel>!
    private var cancellables = Set<AnyCancellable>()
    
    enum Section: String {
        case landomImageList = "RandomImageList"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupLayout()
        setupStyling()
        setupCollectionViewDataSource()
        bind(viewModel: viewModel)
    }
    
    private func bind(viewModel: DayWebtoonListViewModel) {
        viewModel
            .$dataSource
            .receive(on: RunLoop.main)
            .sink { [weak self] cellViewModel in
                self?.applyDataSource(cellViewModel)
            }
            .store(in: &cancellables)
        
        collectionView
            .scrollBottomHit
            .sink(receiveValue: viewModel.nextImagePage)
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
        view.backgroundColor = .white
    }
}

// MARK: CollectionView dataSource

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
}

// MARK: CollectionView layout

private extension DayWebtoonListViewController {
    
    func setupCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCollectionViewCompositionalLayout()
        )
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.registerCell(cellType: DayWebtoonCollectionViewCell.self)
    }
    
    func createCollectionViewCompositionalLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let section = DayWebtoonListSection(rawValue: sectionIndex) else { return nil }
            return self?.createCollectionLayout(with: section)
        }
        
        layout.configuration = config
        return layout
    }
    
    func createCollectionLayout(with section: DayWebtoonListSection) -> NSCollectionLayoutSection {
        switch section {
        case .dayWebtoonList:
            return createDayWebtoonListLayout()
        }
    }
    
    func createDayWebtoonListLayout() -> NSCollectionLayoutSection {
        let webtoonContainerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.3),
            heightDimension: .absolute(200)
        )
        
        let webtoonItem = NSCollectionLayoutItem(layoutSize: webtoonContainerSize)
        webtoonItem.contentInsets = .spacing(5)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: webtoonItem,
            count: 3
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
        return section
    }
}

private extension NSDirectionalEdgeInsets {
    static func spacing(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        return NSDirectionalEdgeInsets(top: value, leading: value, bottom: value, trailing: value)
    }
}
