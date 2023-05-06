# 네이버웹툰 iOS 클론 후기

## 기술 스택 및 아키텍처

- UIKit + Combine을 사용하여 구현
- 외부 라이브러리는 Kingfisher만 사용 (이미지 캐싱 용도)
- Clean Architecture 베이스

## 기술 스택 선택의 이유

Combine이 Rx 보다 가볍고 빠르다는 얘기를 들어서 개인적으로 학습은 했지만 사용하는 것에 익숙해지고 싶어서 쓰게되었음. UIKit을 사용한 이유는 SwiftUI는 아직 익숙하지 않아서 시간이 더 많이 걸릴 듯하여 UIKit으로 구현하게 되었음. Clean Architecture 또한 익숙하기 때문에 시간절약을 이유로 사용하게 됨.

## 네이버웹툰을 클론 대상으로 선택한 이유

최근 사용한 앱 중에 한 화면 기준으로 가장 다양한 인터렉션과 뷰들이 밀집되어 있었기 때문에 연습용으로 좋은 경험이 될 것이라고 생각했다. 에니메이션도 흔하게 볼 수 있는 에니메이션이 아니여서 도전 의식을 자극했다.

## 부모와 자식간의 통신

참고 링크: [https://github.com/beomkey-nkb/PagerVCPractice/blob/master/PagerVCPractice/PagerVCPractice/ViewModel/Base/Parent%2BChild.swift](https://github.com/beomkey-nkb/PagerVCPractice/blob/master/PagerVCPractice/PagerVCPractice/ViewModel/Base/Parent%2BChild.swift)

일부러 한 화면에 복잡한 뷰들이 밀집 되어있는 화면을 선택한 만큼 역할 분리도 중요했다. 한 화면이어도 작은 단위로 쪼개서 부모와 자식의 관계를 형성하도록 구현함. 

서로 영향을 줄 수 있는 뷰들이었고, 부모와 자식 사이에 통신이 필요했음. 1대 N 관계 였기 때문에 delegate 패턴과 publisher 주입을 통해 서로 양방향 통신이 가능하도록 구현. 자세한 내용은 링크를 참고.

## 후기

커밋 기록 상, 대략 3달 조금 넘게 소요된 듯 한데 실제로 코딩한 시간은 하루 8시간 기준으로 한다면 10일정도 되는 듯 하다. Rx를 썼다면, 5~7일정도면 끝났을 것 같은데 Combine 숙련도가 많이 낮다는 걸 느꼈다. 그래도 이번 클론 프로젝트를 통해 Combine 숙련도가 많이 늘었다. 

개인적으로 가장 시간을 많이 썼던 부분은 에니메이션 부분이었다. 지금까지 일을 하면서도 느끼는 거지만, 복잡한 에니메이션을 버그없이 완벽하게 만드는 게 정말 어렵다고 생각한다. 최대한 유지보수를 염두한 코딩을 하려고 노력했다. 그런데도 아직 부족한 부분들이 존재하는 듯 하다.

아직 짜잘한 버그들이 좀 있긴 한데.. 출시를 목표로한 프로젝트는 아니기 때문에 유지보수는 하지 않은 계획이다.
