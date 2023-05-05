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
    
    private var frontImageView = UIImageView()
    private var backgroundImageView = UIImageView()
    private var currentIndexLabel = BasePaddingLabel(padding: .init(top: 3.5, left: 7, bottom: 3.5, right: 7))
    private var collectionView: UICollectionView! = nil

    private let adMaxCount: Int = 100
    private var photos = [UnsplashPhoto]()
    private var currentIndex: Int = 60
    private var cancellables = Set<AnyCancellable>()
    
    enum CollectionViewMetric {
        static var itemSpacing: CGFloat = 10
        
        static var deviceWidth: CGFloat {
            return min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        }
        
        static var cellWidth: CGFloat {
            return CollectionViewMetric.deviceWidth - 56
        }
        
        static var contentInset: UIEdgeInsets {
            return .init(top: 0, left: 28, bottom: 0, right: 28)
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
            .sink { [weak self] _ in
                guard let self = self else { return }
                let indexPath = IndexPath(item: 60, section: 0)
                guard self.photos.isEmpty == false,
                      let url = URL(string: self.photos[0].urls.regular)
                else { return }
                
                self.setupImageGradient(self.frontImageView)
                self.setupImageGradient(self.backgroundImageView)
                self.frontImageView.kf.setImage(with: url)
                self.collectionView.scrollToItem(
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
        
        collectionView
            .publisher(for: \.contentOffset)
            .map { $0.x }
            .filter { $0 > 0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] offsetX in
                guard let self = self else { return }
                self.handleImageAlpha(offsetX)
            }
            .store(in: &cancellables)
    }
}

// MARK: handle Ad Images

private extension WebtoonAdView {
    
    func handleImageAlpha(_ offsetX: CGFloat) {
        let insetLeft = CollectionViewMetric.contentInset.left
        let cellWidth = CollectionViewMetric.cellWidth + CollectionViewMetric.itemSpacing
        let value = (offsetX + insetLeft) / cellWidth
        let rounded = floor(value)
        
        if value == rounded {
            guard Int(rounded) != currentIndex else {
                clearImageAlpha()
                return
            }
            currentIndex = Int(value)
            setupCurrentIndexText()
            exchangeImageViewPosition()
            clearImageAlpha()
            
        } else if value > CGFloat(currentIndex) {
            let nextIndex = Int(ceil(value))
            let imageAlpha = 1 - (value - rounded)
            handleImageAnimation(nextIndex, imageAlpha: imageAlpha)
            
        } else {
            let nextIndex = Int(rounded)
            let imageAlpha = value - rounded
            handleImageAnimation(nextIndex, imageAlpha: imageAlpha)

        }
    }
    
    func clearImageAlpha() {
        frontImageView.alpha = 1.0
        backgroundImageView.alpha = 1.0
        backgroundImageView.image = nil
    }
    
    func exchangeImageViewPosition() {
        let back = backgroundImageView
        let front = frontImageView
        frontImageView = back
        backgroundImageView = front
        sendSubviewToBack(backgroundImageView)
    }
    
    func handleImageAnimation(_ nextIndex: Int, imageAlpha: CGFloat) {
        let urlString = photos[nextIndex % 20].urls.regular
        let url = URL(string: urlString)
        self.backgroundImageView.kf.setImage(with: url)
        self.frontImageView.alpha = imageAlpha
    }
    
    func setupImageGradient(_ imageView: UIImageView) {
        let gradient = CAGradientLayer()
        gradient.frame = self.frontImageView.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.75)
        gradient.endPoint = CGPoint(x: 0, y: 1.0)
        imageView.layer.addSublayer(gradient)
    }
    
    func setupCurrentIndexText() {
        currentIndexLabel.text = "\(currentIndex % 20 + 1) / 20"
    }
}

// MARK: Presentable

extension WebtoonAdView {
    
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        
        [frontImageView, backgroundImageView, currentIndexLabel, collectionView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addSubview(frontImageView)
        constraints += [
            frontImageView.topAnchor.constraint(equalTo: topAnchor),
            frontImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            frontImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            frontImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        addSubview(backgroundImageView)
        constraints += [
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        addSubview(currentIndexLabel)
        constraints += [
            currentIndexLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -70),
            currentIndexLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
        ]
        
        addSubview(collectionView)
        constraints += [
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: safeTopAnchor)
        ]
        
        sendSubviewToBack(backgroundImageView)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupStyling() {
        frontImageView.contentMode = .scaleToFill
        backgroundImageView.contentMode = .scaleToFill
        currentIndexLabel.textColor = .white
        currentIndexLabel.clipsToBounds = true
        currentIndexLabel.backgroundColor = .darkGray.withAlphaComponent(0.5)
        currentIndexLabel.layer.cornerRadius = 10
        currentIndexLabel.font = .systemFont(ofSize: 12)
        setupCurrentIndexText()
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: CollectionViewMetric.cellWidth, height: 250)
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
        var index: CGFloat = scrolledOffsetX / cellWidth
        let velocityX = Int(scrollView.panGestureRecognizer.velocity(in: self).x)
        index = velocityX < 0 ? ceil(index) : floor(index)
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
