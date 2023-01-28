//
//  MainPagerViewController.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/01/28.
//

import Foundation
import UIKit

final class MainPagerViewController: UIViewController {
    
    private var sampleButtonTest = UIButton()
    
    lazy var pagedViewControllers: [UIViewController] = {
        let first = UIViewController()
        first.view.backgroundColor = .blue
        let second = UIViewController()
        second.view.backgroundColor = .red
        let third = UIViewController()
        third.view.backgroundColor = .yellow
        return [first, second, third]
    }()
    
    lazy var pageViewController: UIPageViewController = {
        return UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
    }()
    
    private var currentIndex: Int = 0
    
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
        sampleButtonTest.addTarget(self, action: #selector(sampleButtonTap), for: .touchUpInside)
    }
    
    @objc func sampleButtonTap() {
        
        if let randomIndex = [0, 1, 2].randomElement() {
            guard randomIndex != currentIndex else { return }
            
            if currentIndex < randomIndex {
                for i in currentIndex...randomIndex {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.pageViewController.setViewControllers([self.pagedViewControllers[i]], direction: .forward, animated: true)
                    }
                }
            } else {
                for i in stride(from: currentIndex, through: randomIndex, by: -1) {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.pageViewController.setViewControllers([self.pagedViewControllers[i]], direction: .reverse, animated: true)
                    }
                }
            }
            
            currentIndex = randomIndex
        }
    }
    
    func setupPageViewController() {
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        if let first = pagedViewControllers.first {
            pageViewController.setViewControllers([first], direction: .forward, animated: true)
        }
    }
}

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
