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
    private var viewModel: DayWebtoonListViewModel
    
    private var collectionView: UICollectionView! = nil
    private var dataSource: UICollectionViewDiffableDataSource<Section, WebtoonImageCellViewModel>!
    private var cancellables = Set<AnyCancellable>()
    
    enum Section: String {
        case landomImageList = "RandomImageList"
    }
    
    init(viewModel: DayWebtoonListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

extension DayWebtoonListViewController: UICollectionViewDelegate {
    
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging || scrollView.isDecelerating else { return }
        // viewModel.changeTopOffset - scrollView.contentOffset.y 전달

        if scrollView.contentOffset.y >= 0 {
            guard collectionView.contentInset.top != 0 else { return }
            collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
            
        } else if scrollView.contentOffset.y > -300 {
            guard abs(scrollView.contentOffset.y) != collectionView.contentInset.top else { return }
            collectionView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
            
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false else { return }
        guard scrollView.contentOffset.y < 0 && scrollView.contentOffset.y > -300 else { return }
        collectionView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        UIView.animate(withDuration: 0.3) {
            self.collectionView.contentOffset.y = -50
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let velocity = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let scrollsToTop = velocity > 0
        
        guard scrollView.contentOffset.y < 0 && scrollView.contentOffset.y > -300 else { return }
        collectionView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        UIView.animate(withDuration: 0.3) {
            self.collectionView.contentOffset.y = scrollsToTop ? -300 : -50
        }
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
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.registerCell(cellType: DayWebtoonCollectionViewCell.self)
        collectionView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
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
