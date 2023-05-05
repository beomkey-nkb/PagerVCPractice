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
        return (0..<7).map { value in
            let listViewModel = DayWebtoonListViewModel(currentPage: value + 1)
            listViewModel.listner = viewModel
            listViewModel.bindParentAction(viewModel.transferPublisher)
            return DayWebtoonListViewController(viewModel: listViewModel)
        }
    }()
    
    private lazy var pageViewController: UIPageViewController = {
        return UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
    }()
    
    private var navigationView = UIView()
    private var navigationTitleLabel = UILabel()
    private var webtoonAdView = WebtoonAdView()
    private lazy var webtoonDayView: WebtoonDayView = {
        let dayViewModel = WebtoonDayViewModel(focusIndex: viewModel.currentFocusIndex)
        dayViewModel.listner = viewModel
        dayViewModel.bindParentAction(viewModel.transferPublisher)
        return WebtoonDayView(viewModel: dayViewModel)
    }()
    
    private var adViewTopConstraint: NSLayoutConstraint?
    private var navigationViewTopConstraint: NSLayoutConstraint?
    private var navigationTopInset: CGFloat = 0
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
                self?.setupNavigationTopInset(constant)
                guard isAnimated else { return }
                UIView.animate(withDuration: 0.3) {
                    self?.view.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)
        
        viewModel
            .currentFocus
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                guard let viewController = self?.pagedViewControllers[index]
                else { return }
                self?.pageViewController.setViewControllers(
                    [viewController],
                    direction: .forward,
                    animated: true
                )
            }
            .store(in: &cancellables)
    }
}

// MARK: Presentable

extension MainPagerViewController {
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        
        [navigationView, navigationTitleLabel, webtoonAdView, webtoonDayView, pageViewController.view].forEach { view in
            view?.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let statusHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let navigationHeight = navigationController?.navigationBar.frame.height ?? 0
        navigationTopInset = -(statusHeight + navigationHeight)
        
        view.addSubview(navigationView)
        navigationViewTopConstraint = navigationView.topAnchor.constraint(equalTo: view.topAnchor, constant: navigationTopInset)
        constraints += [
            navigationViewTopConstraint!,
            navigationView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: -navigationTopInset)
        ]
        
        navigationView.addSubview(navigationTitleLabel)
        constraints += [
            navigationTitleLabel.centerXAnchor.constraint(equalTo: navigationView.centerXAnchor),
            navigationTitleLabel.topAnchor.constraint(equalTo: navigationView.topAnchor, constant: statusHeight),
            navigationTitleLabel.bottomAnchor.constraint(equalTo: navigationView.bottomAnchor)
        ]
        
        let topInset = view.safeAreaInsets.top
        view.addSubview(webtoonAdView)
        adViewTopConstraint = webtoonAdView.topAnchor.constraint(equalTo: view.topAnchor)
        constraints += [
            adViewTopConstraint!,
            webtoonAdView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            webtoonAdView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            webtoonAdView.heightAnchor.constraint(equalToConstant: topInset + 250)
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
        view.bringSubviewToFront(navigationView)
        pageViewController.didMove(toParent: self)
    }
    
    func setupStyling() {
        navigationView.backgroundColor = .white
        navigationTitleLabel.text = "webtoon-clone"
        navigationTitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
    }
    
    func setupNavigationTopInset(_ topConstant: CGFloat) {
        let percent = (250 - abs(topConstant)) / 250
        let navTopInset = navigationTopInset * percent
        navigationViewTopConstraint?.constant = navTopInset
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
        return pagedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pagedViewControllers.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        if nextIndex == pagedViewControllers.count {
            return nil
        }
        return pagedViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        viewModel.transferChangeOffset()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first,
              let index = pagedViewControllers.firstIndex(of: currentVC)
        else { return }
        
        viewModel.scrollTo(index)
    }
}
