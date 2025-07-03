//
//  TabView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 02/06/2025.
//

import SwiftUI
import Foundation
import UIKit

class WideViewController: ObservableObject {
    @Published var SHOW_TAB_BAR: Bool = true
}

struct WideTabView: View {
    @StateObject var wideViewController = WideViewController()
    
    @State private var activeTab: Tab = .Fitness
    @State private var beforeChangeThemeTab: Tab = .Home
    @Namespace private var animation
    @State private var tabShapePosition: CGPoint = .zero
    @State var uiTabarController: UITabBarController?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $activeTab) {
                FitnessView()
                    .tag(Tab.Fitness)
                    .background(TabBarAccessor { tabBar in
                        tabBar.isHidden = true
                     })
                    
                    
                HealthInsuranceView()
                    .tag(Tab.HealthInsurace)
                    .background(TabBarAccessor { tabBar in
                        tabBar.isHidden = true
                     })
                
                HomeView()
                    .tag(Tab.Home)
                    .background(TabBarAccessor { tabBar in
                        tabBar.isHidden = true
                     })
                
                RankingView()
                    .tag(Tab.Ranking)
                    .background(TabBarAccessor { tabBar in
                        tabBar.isHidden = true
                     })
                
                AppSettingView()
                    .tag(Tab.Setting)
                    .background(TabBarAccessor { tabBar in
                        tabBar.isHidden = true
                     })
            }
            
            CustomTabBar()
        }
        .environmentObject(wideViewController)
    }
    
    
    @ViewBuilder
    func CustomTabBar() -> some View {
        if wideViewController.SHOW_TAB_BAR {
            HStack(alignment: .bottom, spacing: UIScreen.main.bounds.width / 12) {
                ForEach(Tab.allCases, id: \.rawValue) {
                    TabItem(
                        tint: Color.Orange,
                        activeTint: Color.offWhite,
                        inactiveTint: Color.Orange,
                        tab: $0,
                        animation: animation,
                        activeTab: $activeTab,
                        position: $tabShapePosition
                    )
                }
            }
            .background(content: {
                TabShape(midpoint: tabShapePosition.x - 16)
                    .foregroundColor(.offWhite)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 40)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 2, y: 10)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: -2, y: 10)
            })
            .transition(.move(edge: .bottom))
        }
    }
}
    
    
struct TabItem: View {
    var tint: Color
    var activeTint: Color
    var inactiveTint: Color
    var tab: Tab
    var animation: Namespace.ID
    @Binding var activeTab: Tab
    @Binding var position: CGPoint
    
    @State private var tabPosition: CGPoint = .zero
    
    var body: some View {
        Image(systemName: tab.systemImage)
            .font(.system(size: 25, weight: .medium))
            .foregroundColor(activeTab == tab ? activeTint : inactiveTint)
            .scaleEffect(activeTab == tab ? 1.3 : 1)
            .background {
                if activeTab == tab {
                    Circle()
                        .fill(tint)
                        .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                        .frame(width: 50, height: 50)
                }
            }
            .frame(height: 50)
            .offset(y: activeTab == tab ? -10 : 0)
            .onTapGesture {
                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7)) {
                    position.x = tabPosition.x
                    activeTab = tab
                }
            }
            .viewPosition(completion:  {rect in
                tabPosition.x = rect.midX
                if activeTab == tab {
                    position.x = rect.midX
                }
            })
    }
}

struct TabShape: Shape {
    var midpoint: CGFloat
    var animatableData: CGFloat {
        get {
            midpoint
        } set {
            midpoint = newValue
        }
    }
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.addPath(RoundedRectangle(cornerRadius: 10).path(in: rect))

            
            path.move(to: .init(x: midpoint - 32, y: 0))
            
            let to = CGPoint(x: midpoint, y: -20)
            let control1 = CGPoint(x: midpoint - 25, y: 0)
            let control2 = CGPoint(x: midpoint - 25, y: -19)

            path.addCurve(to: to, control1: control1, control2: control2)
            
            let to1 = CGPoint(x: midpoint + 32, y: 0)
            let control3 = CGPoint(x: midpoint + 25, y: -19)
            let control4 = CGPoint(x: midpoint + 25, y: 0)
            
            path.addCurve(to: to1, control1: control3, control2: control4)
        }
    }
}






struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        WideTabView()
    }
}
    
