//
//  TabView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 02/06/2025.
//

import SwiftUI
import Foundation
import UIKit

class TabViewController: ObservableObject {
    @Published var showTabBar: Bool = true
    @Published var activeTab: Tab = .Fitness
}

struct WideTabView: View {
    @StateObject var tabViewController = TabViewController()
    @StateObject var theme = AppThemeController()
    @EnvironmentObject var userController: UserController
    
    @Namespace private var animation
    @State private var tabShapePosition: CGPoint = .zero
    @State var uiTabarController: UITabBarController?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $tabViewController.activeTab) {
                FitnessView()
                    .tag(Tab.Fitness)
                    .background(TabBarAccessor { tabBar in
                        tabBar.isHidden = true
                     })
                    
//                HealthInsuranceView()
//                    .tag(Tab.HealthInsurace)
//                    .background(TabBarAccessor { tabBar in
//                        tabBar.isHidden = true
//                     })
                
                HomeView()
                    .tag(Tab.Home)
                    .background(TabBarAccessor { tabBar in
                        tabBar.isHidden = true
                     })
                
                ContestView()
                    .tag(Tab.Contest)
                    .background(TabBarAccessor { tabBar in
                        tabBar.isHidden = true
                    })
                
//                RankingView()
//                    .tag(Tab.Ranking)
//                    .background(TabBarAccessor { tabBar in
//                        tabBar.isHidden = true
//                     })
                
                AppSettingView()
                    .tag(Tab.Setting)
                    .background(TabBarAccessor { tabBar in
                        tabBar.isHidden = true
                     })
            }
            CustomTabBar()
        }
        .environmentObject(tabViewController)
        .environmentObject(theme)
    }
    
    
    @ViewBuilder
    func CustomTabBar() -> some View {
        if tabViewController.showTabBar {
            HStack(alignment: .bottom, spacing: (UIScreen.main.bounds.width) / 12.5) {
                ForEach(Tab.allCases, id: \.rawValue) {
                    TabItem(
                        tint: Color.Orange,
                        activeTint: theme.main.tabbar,
                        inactiveTint: Color.Orange,
                        tab: $0,
                        animation: animation,
                        activeTab: $tabViewController.activeTab,
                        position: $tabShapePosition
                    )
                }
            }
            .background(content: {
                TabShape(midpoint: tabShapePosition.x - 75)
                    .foregroundColor(theme.main.tabbar)
                    .frame(width: UIScreen.main.bounds.width - 150, height: 40)
                    .frame(height: 40)
                    .shadow(color: Color.black.opacity(0.06), radius: 3, x: 2, y: 12)
                    .shadow(color: Color.black.opacity(0.06), radius: 3, x: -2, y: 12)
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
        VStack(spacing: 0) {
            Image(systemName: tab.systemImage)
                .font(.system(size: 25, weight: .medium))
                .foregroundColor(activeTab == tab ? activeTint : inactiveTint)
                .scaleEffect(activeTab == tab ? 1.25 : 1)
                .shadow(radius: 1)
                .background {
                    if activeTab == tab {
                        Circle()
                            .fill(tint)
                            .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                            .frame(width: 48, height: 48)
                            .shadow(radius: 3)
                    }
                }
                .frame(height: 48)
                .offset(y: activeTab == tab ? -10 : 0)
                .onTapGesture {
                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 1)) {
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
            
//            Text(tab.rawValue)
        }
    }
}

struct WideTabView_Previews: PreviewProvider {
    static var previews: some View {
        WideTabView()
            .environmentObject(AppThemeController())
            .environmentObject(TabViewController())
            .environmentObject(UserController())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
