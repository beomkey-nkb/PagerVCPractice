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
    
    private var sampleButtonTest = UIButton()
    private lazy var pagedViewControllers: [UIViewController] = {
        let test = RandomImageListViewController(nibName: nil, bundle: nil)
        return [test]
    }()
    
    private lazy var pageViewController: UIPageViewController = {
        return UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
    }()
    
    private var currentIndex: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPageViewController()
        setupLayout()
        setupStyling()
        bind()
    }
    
    func bind() {
        sampleButtonTest
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .compactMap { _ in }
            .sink { [weak self] _ in
                self?.sampleButtonTap()
            }
            .store(in: &cancellables)
    }
}

// MARK: Presentable

extension MainPagerViewController {
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        
        sampleButtonTest.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sampleButtonTest)
        constraints += [
            sampleButtonTest.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            sampleButtonTest.widthAnchor.constraint(equalToConstant: 100),
            sampleButtonTest.heightAnchor.constraint(equalToConstant: 100)
        ]
        
        addChild(pageViewController)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageViewController.view)

        constraints += [
            pageViewController.view.topAnchor.constraint(equalTo: sampleButtonTest.bottomAnchor, constant: 15),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        pageViewController.didMove(toParent: self)
    }
    
    func setupStyling() {
        sampleButtonTest.setTitle("nice", for: .normal)
        sampleButtonTest.setTitleColor(.systemBlue, for: .normal)
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

extension MainPagerViewController {
    @objc func sampleButtonTap() {
        let filteredCurrentIndex = [0, 1, 2].filter { $0 != self.currentIndex }
        guard let randomIndex = filteredCurrentIndex.randomElement(),
              randomIndex != currentIndex
        else { return }
        
        if currentIndex < randomIndex {
            (currentIndex...randomIndex).forEach { index in
                movePageViewController(index: index, direction: .forward)
            }
        } else {
            stride(from: currentIndex, through: randomIndex, by: -1).forEach { index in
                movePageViewController(index: index, direction: .reverse)
            }
        }
        
        currentIndex = randomIndex
    }
    
    func movePageViewController(index: Int, direction: UIPageViewController.NavigationDirection) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.pageViewController.setViewControllers(
                [self.pagedViewControllers[index]],
                direction: direction,
                animated: true
            )
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
