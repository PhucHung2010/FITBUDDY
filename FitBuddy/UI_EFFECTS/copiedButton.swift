//
//  copiedButton.swift
//  FitBuddy
//
//  Created by Nguyen Huu Phuc Hung on 18/8/25.
//
import SwiftUI

struct CopiedButton: View {
    @State private var isTapping: Bool = false
    var body: some View {
        ZStack {
            Color.darkGray.ignoresSafeArea()
            HStack(spacing: 15) {
                firstButton
                firstButton
            }
        }
    }
    
    
    var firstButton: some View {
        RoundedRectangle(cornerRadius: 30)
            .foregroundColor(Color.gray)
            .shadow(color: .black, radius: 0.5, y: isTapping ? 1.5 : 6)
            .shadow(color: .black, radius: 0.5, x: 1.5, y: 0)
            .shadow(color: .black, radius: 0.5, x: -1.5, y: 0)
            .shadow(color: .black, radius: 0.5, y: -1.5)
            .overlay {
                VStack(spacing: 0) {
                    Image(.happyIMG)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140)
                        .shadow(radius: 1)
                    
                    Text("Widgets")
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .bottomLeading)
                        .foregroundStyle(Color.white)
                        .padding(.bottom, 15)
                        .padding(.leading, 15)
                        .shadow(radius: 0.5)
                }
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.3)) {
                    isTapping = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                            isTapping = false
                        }
                    }
                }
            }
            .onLongPressGesture(minimumDuration: 1.5, pressing: { isPressing in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                    isTapping = isPressing
                }
            } ,perform: {
            })
            .offset(y: isTapping ? 7.5 : 0)
            .frame(width: UIScreen.main.bounds.width / 2.4, height: UIScreen.main.bounds.width / 2.3)
    }
}

struct CopiedButton_Previews: PreviewProvider {
    static var previews: some View {
        CopiedButton()
            .environmentObject(TabViewController())
            .environmentObject(UserController())
            .environmentObject(AppThemeController())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
