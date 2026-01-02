//
//  TabShape.swift
//  FitBuddy
//
//  Created by tai nguyen huu on 7/7/25.
//
import SwiftUI
import Foundation

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
//            path.addPath(RoundedRectangle(cornerRadius: 20).path(in: rect))
            path.addPath(RoundedRectangle(cornerRadius: 20).path(in: rect))

            
            path.move(to: .init(x: midpoint - 30, y: 0))
            
            let to = CGPoint(x: midpoint, y: -18.5)
            let control1 = CGPoint(x: midpoint - 24, y: 2)
            let control2 = CGPoint(x: midpoint - 24, y: -17.5)

            path.addCurve(to: to, control1: control1, control2: control2)
            
            let to1 = CGPoint(x: midpoint + 30, y: 0)
            let control3 = CGPoint(x: midpoint + 24, y: -17.5)
            let control4 = CGPoint(x: midpoint + 24, y: 2)
            
            path.addCurve(to: to1, control1: control3, control2: control4)
        }
    }
}


struct TabShape_Previews: PreviewProvider {
    static var previews: some View {
        WideTabView()
            .environmentObject(TabViewController())
            .environmentObject(UserController())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

