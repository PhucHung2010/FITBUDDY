////
////  AppHeading.swift
////  FitBuddy
////
////  Created by Nguyen Huu Phuc Hung on 6/8/25.
////
//import SwiftUI
//
//struct AppHeadingView: View {
//    @State var title: [Character]
//    
//    @State private var animateFlags: [Bool] = []
//    @State private var animationTimer: Timer? = nil
//    @State private var show: Bool = false
//    
//    init(title: String) {
//        _title = State(initialValue: Array(title))
//    }
//    
//    let totalAnimationDuration = 0.3
//
//    
//    var body: some View {
//        HStack(spacing: 7) {
//            ForEach(title.indices, id: \.self) { index in
//                if index < animateFlags.count {
//                    let char = String(title[index])
//                    Text(char)
//                        .font(.system(size: 25, weight: .heavy, design: .rounded))
//                        .foregroundStyle(
//                            LinearGradient(colors: [.Orange, .Orange.opacity(0.8)],
//                                           startPoint: .topLeading,
//                                           endPoint: .bottomTrailing)
//                        )
//                        .background(
//                            RoundedRectangle(cornerRadius: 30)
//                                .frame(height: 10)
//                                .offset(y: 8)
//                                .foregroundColor(.black.opacity(0.1))
//                                .blur(radius: 4)
//                        )
//                        .scaleEffect(animateFlags[index] ? 1.4 : 0.0)
//                        .animation(
//                            .interpolatingSpring(stiffness: 80, damping: 10),
//                            value: animateFlags[index]
//                        )
//                }
//            }
//        }
//        .minimumScaleFactor(0.3)
//        .onAppear {
//            animateFlags = Array(repeating: false, count: title.count)
//            animateFlags = Array(repeating: true, count: title.count)
//        }
//    }
//}
//
//
//
//struct AppHeadingView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppHeadingView(title: "FitBuddy")
//            .environmentObject(TabViewController())
//            .environmentObject(UserController())
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
//
//  AppHeading.swift
//  FitBuddy
//
//  Created by Nguyen Huu Phuc Hung on 6/8/25.
//
import SwiftUI

struct AppHeadingView: View {
    let title: String
    
    @State private var scale: CGFloat = 0.0
    
    var body: some View {
        Text(title)
            .font(.system(size: 35, weight: .heavy, design: .rounded))
            .foregroundStyle(
                LinearGradient(colors: [.Orange, .Orange.opacity(0.8)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .frame(height: 7)
                    .offset(y: 12)
                    .foregroundColor(.black.opacity(0.2))
                    .blur(radius: 6)
            )
            .scaleEffect(scale)
            .onTapGesture {
                withAnimation(.interpolatingSpring(stiffness: 80, damping: 10)) {
                    scale = 1.3
                }
                withAnimation(.interpolatingSpring(stiffness: 80, damping: 10).delay(0.2)) {
                    scale = 1.0
                }
            }
            .onAppear {
                scale = 0.0
                withAnimation(.interpolatingSpring(stiffness: 80, damping: 10)) {
                    scale = 1.3
                }
                withAnimation(.interpolatingSpring(stiffness: 80, damping: 10).delay(0.2)) {
                    scale = 1.0
                }
            }
    }
}

struct AppHeadingView_Previews: PreviewProvider {
    static var previews: some View {
        AppHeadingView(title: "FitBuddy")
            .environmentObject(TabViewController())
            .environmentObject(UserController())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
