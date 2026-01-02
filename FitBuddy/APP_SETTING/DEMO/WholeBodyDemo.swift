//
//  WholeBodyDemo.swift
//  FitBuddy
//
//  Created by Nguyen Huu Phuc Hung on 31/7/25.
//

import SwiftUI

struct WholeBodyDemoView: View {
//    @EnvironmentObject var theme: AppThemeController
    var body: some View {
        Button(action: {}) {
//            HStack {
//                Image(systemName: "hand.raised.fill")
//                Text("Hand raised")
//            }
//            .font(.system(size: 25, weight: .heavy))
//            .foregroundColor(Color.Orange)
//            .shadow(radius: 3)
//            .frame(width: UIScreen.main.bounds.width - 40, height: 40)
//            .background {
//                BlurView(style: theme.main.ultraThinMaterial)
//                    .clipShape(RoundedRectangle(cornerRadius: 30))
//                    .shadow(radius: 6)
//            }
        }
    }
}


struct WholeBodyDemoView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            AppSettingView()
                .environmentObject(UserController(user: UserModel(id: "no",
                                                                  name: "Hưng Nguyễn",
                                                                  email: "nhphung2468@gmail.com",
                                                                  imageURL: "https://lh3.googleusercontent.com/a/ACg8ocL1E5Imyb3wQUfxEZ8GIvyXOjgtU776TXxIxfk2U1b3AtK3h7I=s1000")))
                .environmentObject(AppThemeController())
        }
    }
}
