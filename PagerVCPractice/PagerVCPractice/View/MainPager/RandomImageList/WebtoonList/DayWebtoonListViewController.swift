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
    case horizontalList
    case dayWebtoonList
}

final class DayWebtoonListViewController: UIViewController {
    private var viewModel: DayWebtoonListViewModel
    
    private var collectionView: UICollectionView! = nil
    private var dataSource: UICollectionViewDiffableDataSource<DayWebtoonListSection, WebtoonImageCellViewModel>!
    private var cancellables = Set<AnyCancellable>()
    
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
            .receive(on: DispatchQueue.main)
            .drop(while: { $0.isEmpty })
            .sink { [weak self] cellViewModel in
                self?.applyDataSource(cellViewModel)
            }
            .store(in: &cancellables)
        
        let finishSetupOffset = collectionView
            .publisher(for: \.contentOffset)
            .map(\.y)
            .removeDuplicates()
            .filter { $0 == -300 }
            .first()
            .map { _ in }
        
        finishSetupOffset
            .combineLatest(viewModel.changeOffsetY)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (_, offsetY) in
                self?.collectionView.contentOffset.y = offsetY
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
            collectionView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupStyling() {
        view.backgroundColor = .white
    }
    
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
        
        (collectionView as UIScrollView).bounces = false
        collectionView.registerCell(cellType: DayWebtoonCollectionViewCell.self)
        collectionView.registerCell(cellType: DayWebtoonHorizontalListCell.self)
        collectionView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
    }
}

// MARK: CollectionView dataSource

extension DayWebtoonListViewController: UICollectionViewDelegate {
    
    func setupCollectionViewDataSource() {
        dataSource = UICollectionViewDiffableDataSource<DayWebtoonListSection, WebtoonImageCellViewModel>.init(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                let section = DayWebtoonListSection(rawValue: indexPath.section)
                
                switch section {
                case .horizontalList:
                    let cell: DayWebtoonHorizontalListCell = collectionView.dequeueCell(indexPath: indexPath)
                    cell.configure(itemIdentifier, index: indexPath.item)
                    return cell
                    
                case .dayWebtoonList:
                    let cell: DayWebtoonCollectionViewCell = collectionView.dequeueCell(indexPath: indexPath)
                    cell.configure(itemIdentifier)
                    return cell
                    
                default:
                    return UICollectionViewCell()
                }
            }
        )
    }
    
    func applyDataSource(_ cellViewModels: [WebtoonImageCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<DayWebtoonListSection, WebtoonImageCellViewModel>()
        let horizontalList = cellViewModels[0..<10].map { $0 }
        let verticalList = cellViewModels[10..<28].map { $0 }
        
        snapshot.appendSections([ .horizontalList, .dayWebtoonList])
        snapshot.appendItems(horizontalList, toSection: .horizontalList)
        snapshot.appendItems(verticalList, toSection: .dayWebtoonList)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: UIScrollViewDelegate

extension DayWebtoonListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging || scrollView.isDecelerating else { return }
        viewModel.deliverCollectionViewOffsetY(scrollView.contentOffset.y)

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
            self.viewModel.deliverCollectionViewOffsetY(-50, isAnimated: true)
            self.collectionView.contentOffset.y = -50
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let velocity = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let scrollsToTop = velocity > 0
        
        guard scrollView.contentOffset.y < 0 && scrollView.contentOffset.y > -300 else { return }
        collectionView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        UIView.animate(withDuration: 0.3) {
            let offsetY: CGFloat = scrollsToTop ? -300 : -50
            self.viewModel.deliverCollectionViewOffsetY(offsetY, isAnimated: true)
            self.collectionView.contentOffset.y = offsetY
        }
    }
}

// MARK: CollectionView layout

private extension DayWebtoonListViewController {
    
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
        case .horizontalList:
            return horizontalWebtoonListLayout()
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 0, trailing: 16)
        return section
    }
    
    func horizontalWebtoonListLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.25),
            heightDimension: .absolute(170)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        return section
    }
}

private extension NSDirectionalEdgeInsets {
    static func spacing(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        return NSDirectionalEdgeInsets(top: value, leading: value, bottom: value, trailing: value)
    }
}
