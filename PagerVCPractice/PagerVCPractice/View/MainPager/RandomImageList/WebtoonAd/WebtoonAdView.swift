//
//  WebtoonAdView.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/04/15.
//

import Foundation
import UIKit
import Combine
import Kingfisher

final class WebtoonAdView: UIView {
    private var viewModel: WebtoonAdViewModel
    
    private var imageView1 = UIImageView()
    private var imageView2 = UIImageView()
    private var collectionView: UICollectionView! = nil
    
    private var frontImageView: UIImageView? = nil
    private var backgroundImageView: UIImageView? = nil
    private let adMaxCount: Int = 100
    private var photos = [UnsplashPhoto]()
    private var cancellables = Set<AnyCancellable>()
    
    enum CollectionViewMetric {
        static var itemSpacing: CGFloat = 10
        
        static var cellWidth: CGFloat {
            return UIScreen.main.bounds.width - 56
        }
        
        static var contentInset: UIEdgeInsets {
            let cellWidth = CollectionViewMetric.cellWidth
            let insetX = (UIScreen.main.bounds.width - cellWidth) / 2.0
            return .init(top: 0, left: insetX, bottom: 0, right: insetX)
        }
    }
    
    init() {
        self.viewModel = WebtoonAdViewModel()
        super.init(frame: .zero)
        self.setupCollectionView()
        self.setupLayout()
        self.setupStyling()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        collectionView
            .publisher(for: \.bounds)
            .filter { $0.height != 0 }
            .map { _ in }
            .receive(on: DispatchQueue.main)
            .first()
            .sink { [weak self] _ in
                let indexPath = IndexPath(item: 60, section: 0)
                self?.collectionView.scrollToItem(
                    at: indexPath,
                    at: .centeredHorizontally,
                    animated: false
                )
            }
            .store(in: &cancellables)
        
        viewModel
            .$dataSource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dataSource in
                self?.photos = dataSource
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: Presentable

extension WebtoonAdView {
    
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        
        [imageView1, imageView2, collectionView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addSubview(imageView1)
        constraints += [
            imageView1.topAnchor.constraint(equalTo: topAnchor),
            imageView1.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView1.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView1.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50)
        ]
        
        addSubview(imageView2)
        constraints += [
            imageView2.topAnchor.constraint(equalTo: topAnchor),
            imageView2.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView2.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView2.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50)
        ]
        
        addSubview(collectionView)
        constraints += [
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            collectionView.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        frontImageView = imageView1
        backgroundImageView = imageView2
        bringSubviewToFront(imageView1)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupStyling() {
        imageView1.contentMode = .scaleAspectFill
        imageView2.contentMode = .scaleAspectFill
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: CollectionViewMetric.cellWidth, height: 50)
        layout.minimumInteritemSpacing = CollectionViewMetric.itemSpacing
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerCell(cellType: WebtoonAdCollectionViewCell.self)
        collectionView.contentInset = CollectionViewMetric.contentInset
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
    }
}

// MARK: CollectionView delegate, dataSource

extension WebtoonAdView: UICollectionViewDelegate, UICollectionViewDataSource {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrolledOffsetX = targetContentOffset.pointee.x + scrollView.contentInset.left
        let cellWidth = CollectionViewMetric.cellWidth + CollectionViewMetric.itemSpacing
        let index = round(scrolledOffsetX / cellWidth)
        targetContentOffset.pointee = CGPoint(x: index * cellWidth - scrollView.contentInset.left, y: scrollView.contentInset.top)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adMaxCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: WebtoonAdCollectionViewCell = collectionView.dequeueCell(indexPath: indexPath)
        if self.photos.isEmpty == false {
            cell.configure(self.photos[indexPath.item % 20])
        }
        
        return cell
    }
}
