//
//  Parent+Child.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/25.
//

import Foundation
import Combine

/*
 부모 뷰모델이 채택할 protocol
 부모 뷰모텔에서 발생한 이벤트는 transferSubject로 전달
 transferSubject는 자식 뷰모텔로 주입하여 바인딩될 예정
 */

protocol VMParentProtocol: AnyObject {
    associatedtype ParentAction
    var transferSubject: PassthroughSubject<ParentAction, Never> { get }
}

/*
 자식은 부모 뷰모델의 subject를 publisher로 주입받아서 바인딩함.
 listner는 구현체에서 약한참조로 선언해야함.
 
 자식에서 부모로 값을 전달하고 싶을 경우, 부모 뷰모델이 자식의 listner를 상속받고,
 부모 부모델을 listner로 주입하여 전달.
 */

protocol VMChildProtocol: AnyObject {
    associatedtype ParentAction
    associatedtype Listner
    var listner: Listner? { get set }
    func bindParentAction(_ publisher: AnyPublisher<ParentAction, Never>)
}

/*
 필요한 상황에만 override로 재정의해서 사용하기 위해 객체로 만듬.
 실사용 객체에서 상속받아서 상황에 맞게 커스텀하여 사용
 */

class VMParent<ParentAction>: VMParentProtocol {
    typealias ParentAction = ParentAction
    var transferSubject: PassthroughSubject<ParentAction, Never> = .init()
}

class VMChild<ParentAction, Listner>: VMChildProtocol {
    typealias ParentAction = ParentAction
    typealias Listner = Listner
    var listner: Listner?
    
    func bindParentAction(_ publisher: AnyPublisher<ParentAction, Never>) { }
}
