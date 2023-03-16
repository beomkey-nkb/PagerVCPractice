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
    private lazy var pagedViewControllers: [UIViewController] = {
        let test = DayWebtoonListViewController(nibName: nil, bundle: nil)
        return [test]
    }()
    
    private lazy var pageViewController: UIPageViewController = {
        return UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
    }()
    
    private var webtoonAdView = UIView()
    private var webtoonDayView = UIView()
    
    private var currentIndex: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPageViewController()
        setupLayout()
        setupStyling()
    }
}

// MARK: Presentable

extension MainPagerViewController {
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        
        [webtoonAdView, webtoonDayView, pageViewController.view].forEach { view in
            view?.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(webtoonAdView)
        let topSafeAreaInset = view.safeAreaInsets.top
        constraints += [
            webtoonAdView.topAnchor.constraint(equalTo: view.topAnchor),
            webtoonAdView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webtoonAdView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webtoonAdView.heightAnchor.constraint(equalToConstant: topSafeAreaInset + 250)
        ]
        
        view.addSubview(webtoonDayView)
        constraints += [
            webtoonDayView.topAnchor.constraint(equalTo: webtoonAdView.bottomAnchor),
            webtoonDayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webtoonDayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webtoonDayView.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)

        constraints += [
            pageViewController.view.topAnchor.constraint(equalTo: webtoonDayView.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
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
