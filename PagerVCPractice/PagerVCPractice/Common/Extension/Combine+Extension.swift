//
//  Combine+Extension.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/02/18.
//

import Foundation
import Combine
import UIKit

extension UIControl {
    
    class InteractionSubscription<S: Subscriber>: Subscription where S.Input == Void {
        
        private let subscriber: S?
        private let control: UIControl
        private let event: UIControl.Event
        
        init(subscriber: S, control: UIControl, event: UIControl.Event) {
            self.subscriber = subscriber
            self.control = control
            self.event = event
            
            self.control.addTarget(self, action: #selector(handleEvent), for: event)
        }
        
        @objc func handleEvent(_ sender: UIControl) {
            _ = self.subscriber?.receive(())
        }
        
        func request(_ demand: Subscribers.Demand) {
            
        }
        
        func cancel() {
            
        }
    }
    
    struct InteractionPublisher: Publisher {
        
        typealias Output = Void
        typealias Failure = Never
        
        private let control: UIControl
        private let event: UIControl.Event
        
        init(control: UIControl, event: UIControl.Event) {
            self.control = control
            self.event = event
        }
        
        func receive<S: Subscriber>(subscriber: S) where Never == S.Failure, Void == S.Input {
            
            let subscription = InteractionSubscription(
                subscriber: subscriber,
                control: control,
                event: event
            )
            
            subscriber.receive(subscription: subscription)
        }
    }
    
    func publisher(for event: UIControl.Event) -> UIControl.InteractionPublisher {
        return InteractionPublisher(control: self, event: event)
    }
}

extension AnyPublisher {
    
    static func empty() -> AnyPublisher<Output, Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
}
