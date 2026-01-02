//
//  UIChallenge.swift
//  FitBuddy
//
//  Created by Nguyen Huu Phuc Hung on 22/9/25.
//

import SwiftUI
struct UIChallenge: View {
    var body: some View {
        ZStack {
            AppBackground()
            VStack {
                
                HStack(spacing: 5) {
                    Image(systemName: "person.2.circle")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(Color.darkGray)
                    Text("42 người bạn")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color.darkGray)
                }
                .foregroundColor(.white)
                .padding(5)
                .padding(.trailing, 5)
                .background(BlurRoundedBackground(cornerRadius: 30, shadowRadius: 0))
                .frame(maxHeight: .infinity, alignment: .top)
                
                userImage
            }
        }
    }
    
    var userImage: some View {
        ZStack {
            Image("HungVaTu")
                .resizable()
                .scaledToFill()
                .mask(RoundedRectangle(cornerRadius: 50))
                
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
    }
}

struct UIChallenge_Previews: PreviewProvider {
    static var previews: some View {
        UIChallenge()
            .environmentObject(AppThemeController())
    }
}
