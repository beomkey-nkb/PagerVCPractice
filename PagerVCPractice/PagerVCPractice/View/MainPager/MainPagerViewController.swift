//
//  MainPagerViewController.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/01/28.
//

import Foundation
import UIKit
import Combine

final class MainPagerViewController: UIViewController {
    private let viewModel = MainPagerViewModel()
    private lazy var pagedViewControllers: [UIViewController] = {
        let listViewModel = DayWebtoonListViewModel()
        listViewModel.listner = viewModel
        let test = DayWebtoonListViewController(viewModel: listViewModel)
        return [test]
    }()
    
    private lazy var pageViewController: UIPageViewController = {
        return UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
    }()
    
    private var navigationView = UIView()
    private var webtoonAdView = UIView()
    private var webtoonDayView = UIView()
    
    private var adViewTopConstraint: NSLayoutConstraint?
    private var beganPoint: CGPoint?
    private var currentIndex: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publisher(for: \.view?.safeAreaInsets)
            .compactMap { $0?.top }
            .filter { $0 != 0 }
            .first()
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.setupPageViewController()
                self.setupLayout()
                self.setupStyling()
                self.bind(viewModel: self.viewModel)
            })
            .store(in: &cancellables)
    }
    
    private func bind(viewModel: MainPagerViewModel) {
        viewModel
            .headerTopAreaConstantPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] constant, isAnimated in
                self?.adViewTopConstraint?.constant = constant
                guard isAnimated else { return }
                UIView.animate(withDuration: 0.3) {
                    self?.view.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: Presentable

extension MainPagerViewController {
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        
        [webtoonAdView, webtoonDayView, pageViewController.view].forEach { view in
            view?.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let topSafeAreaInset = view.safeAreaInsets.top
        view.addSubview(webtoonAdView)
        adViewTopConstraint = webtoonAdView.topAnchor.constraint(equalTo: view.topAnchor)
        constraints += [
            adViewTopConstraint!,
            webtoonAdView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            webtoonAdView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            webtoonAdView.heightAnchor.constraint(equalToConstant: topSafeAreaInset + 250)
        ]
        
        view.addSubview(webtoonDayView)
        constraints += [
            webtoonDayView.topAnchor.constraint(equalTo: webtoonAdView.bottomAnchor),
            webtoonDayView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            webtoonDayView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            webtoonDayView.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)

        constraints += [
            pageViewController.view.topAnchor.constraint(equalTo: view.safeTopAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        view.bringSubviewToFront(webtoonAdView)
        view.bringSubviewToFront(webtoonDayView)
        pageViewController.didMove(toParent: self)
    }
    
    func setupStyling() {
        webtoonAdView.backgroundColor = .gray
        webtoonDayView.backgroundColor = .darkGray
    }
    
    func setupPageViewController() {
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        view.backgroundColor = .white
        if let first = pagedViewControllers.first {
            pageViewController.setViewControllers([first], direction: .forward, animated: true)
        }
    }
}

// MARK: PagerViewController Delegate

extension MainPagerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pagedViewControllers.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        if previousIndex < 0 {
            return nil
        }
        currentIndex = previousIndex
        return pagedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pagedViewControllers.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        if nextIndex == pagedViewControllers.count {
            return nil
        }
        currentIndex = nextIndex
        return pagedViewControllers[nextIndex]
    }
}
