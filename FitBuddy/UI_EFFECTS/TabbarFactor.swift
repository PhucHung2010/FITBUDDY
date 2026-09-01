import Foundation
import UIKit
import SwiftUI


enum Tab: String, CaseIterable {
    case Fitness
    case Search
    case Home
    case Contest
    case Messages
    case Setting
    
    var systemImage: String {
        switch self {
        case .Fitness:
            return "dumbbell.fill"
        case .Search:
            return "magnifyingglass"
        case .Home:
            return "house"
        case .Contest:
            return "trophy.fill"
        case .Messages:
            return "bubble.left.and.bubble.right.fill"
        case .Setting:
            return "slider.horizontal.3"
        }
    }
    
    var index: Int {
        return Tab.allCases.firstIndex(of: self) ?? 0
    }
}


struct TabBarAccessor: UIViewControllerRepresentable {
    var callback: (UITabBar) -> Void
    private let proxyController = ViewController()

    func makeUIViewController(context: UIViewControllerRepresentableContext<TabBarAccessor>) ->
                              UIViewController {
        proxyController.callback = callback
        return proxyController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<TabBarAccessor>) {
    }
    
    typealias UIViewControllerType = UIViewController

    private class ViewController: UIViewController {
        var callback: (UITabBar) -> Void = { _ in }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let tabBar = self.tabBarController {
                self.callback(tabBar.tabBar)
                // Hide the "More" navigation controller's nav bar that UIKit creates
                // when there are more than 5 tabs
                tabBar.moreNavigationController.navigationBar.isHidden = true
            }
        }
    }
}
