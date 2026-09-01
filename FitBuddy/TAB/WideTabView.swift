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
    @EnvironmentObject var tabViewController: TabViewController
    @EnvironmentObject var theme: AppThemeController
    @EnvironmentObject var userController: UserController
    
    @Namespace private var animation
    @State private var tabShapePosition: CGPoint = .zero
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $tabViewController.activeTab) {
                FitnessView()
                    .tag(Tab.Fitness)
                    .background(TabBarAccessor { tabBar in
                        tabBar.isHidden = true
                     })
                
                SearchPageView()
                    .tag(Tab.Search)
                    .background(TabBarAccessor { tabBar in
                        tabBar.isHidden = true
                     })
                    
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
                     
                MessageListView()
                    .navigationBarHidden(true)
                    .tag(Tab.Messages)
                    .background(TabBarAccessor { tabBar in
                        tabBar.isHidden = true
                     })
                
                AppSettingView()
                    .navigationBarHidden(true)
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
            HStack(spacing: max(4, (UIScreen.main.bounds.width - 330) / CGFloat(Tab.allCases.count - 1))) {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    TabItem(
                        tint: theme.main.text,
                        activeTint: .white,
                        inactiveTint: theme.main.text.opacity(0.45),
                        tab: tab,
                        animation: animation,
                        activeTab: $tabViewController.activeTab,
                        position: $tabShapePosition
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(theme.appTheme == .light ? NeumorphicColors.lightSurface : NeumorphicColors.darkSurface)
                    .neumorphicCard(cornerRadius: 32, shadowRadius: 10, shadowDistance: 6)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
    
    
struct TabItem: View {
    @EnvironmentObject var theme: AppThemeController
    var tint: Color
    var activeTint: Color
    var inactiveTint: Color
    var tab: Tab
    var animation: Namespace.ID
    @Binding var activeTab: Tab
    @Binding var position: CGPoint
    
    @State private var tabPosition: CGPoint = .zero
    
    var body: some View {
        Button(action: {
            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.75)) {
                position.x = tabPosition.x
                activeTab = tab
            }
        }) {
            VStack(spacing: 0) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 17, weight: activeTab == tab ? .bold : .medium))
                    .foregroundColor(activeTab == tab ? activeTint : inactiveTint)
                    .frame(width: 40, height: 40)
                    .background {
                        if activeTab == tab {
                            Circle()
                                .fill(theme.accentGradient)
                                .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                                .shadow(color: theme.accentColor.opacity(0.4), radius: 6, y: 3)
                        }
                    }
            }
        }
        .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.9))
        .viewPosition(completion: { rect in
            tabPosition.x = rect.midX
            if activeTab == tab {
                position.x = rect.midX
            }
        })
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
