//
//  Gesture+Extension.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/16.
//

import Foundation
import Combine
import UIKit

enum GestureType {
    case tap(UITapGestureRecognizer = .init())
    case swipe(UISwipeGestureRecognizer = .init())
    case longPress(UILongPressGestureRecognizer = .init())
    case pan(UIPanGestureRecognizer = .init())
    case pinch(UIPinchGestureRecognizer = .init())
    case edge(UIScreenEdgePanGestureRecognizer = .init())
    
    func get() -> UIGestureRecognizer {
        switch self {
        case .tap(let gestureRecognizer):
            return gestureRecognizer
        case .swipe(let gestureRecognizer):
            return gestureRecognizer
        case .longPress(let gestureRecognizer):
            return gestureRecognizer
        case .pan(let gestureRecognizer):
            return gestureRecognizer
        case .pinch(let gestureRecognizer):
            return gestureRecognizer
        case .edge(let gestureRecognizer):
            return gestureRecognizer
        }
    }
}

struct GesturePublisher: Publisher {
    typealias Output = GestureType
    typealias Failure = Never
    
    private let view: UIView
    private let gestureType: GestureType
    
    init(view: UIView, gestureType: GestureType) {
        self.view = view
        self.gestureType = gestureType
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, GestureType == S.Input {
        let subscription = GestureSubscription(
            subscriber: subscriber,
            view: view,
            gestureType: gestureType
        )
        
        subscriber.receive(subscription: subscription)
    }
}

class GestureSubscription<S: Subscriber>: Subscription where S.Input == GestureType, S.Failure == Never {
    private var subscriber: S?
    private var gestureType: GestureType
    private var view: UIView
    
    init(subscriber: S, view: UIView, gestureType: GestureType) {
        self.subscriber = subscriber
        self.view = view
        self.gestureType = gestureType
        
    }
    
    func request(_ demand: Subscribers.Demand) {
        
    }
    
    func cancel() {
        subscriber = nil
    }
    
    private func configureGesture(_ gestureType: GestureType) {
        let gesture = gestureType.get()
        gesture.addTarget(self, action: #selector(gestureHandler))
    }
    
    @objc
    private func gestureHandler() {
        _ = subscriber?.receive(gestureType)
    }
}

extension UIView {
    
    func gesture(_ gestureType: GestureType) -> GesturePublisher {
        return GesturePublisher.init(view: self, gestureType: gestureType)
    }
}
