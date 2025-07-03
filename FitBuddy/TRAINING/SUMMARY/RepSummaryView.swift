//
//  RepSummaryView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 30/06/2025.
//

import SwiftUI

struct RepSummaryView: View {
    let screenWidth: CGFloat
    var totalCorrect: CGFloat
    var totalIncorrect: CGFloat
    var targetCount: Int?
    var accuracy: Int
    
    var totalCount: CGFloat
    var divider: CGFloat
    
    @State var showDetail: Bool = true
    
    init(screenWidth: CGFloat,
         totalCorrect: CGFloat,
         totalIncorrect: CGFloat,
         targetCount: Int?) {
        self.screenWidth = screenWidth
        self.totalCorrect = totalCorrect
        self.totalIncorrect = totalIncorrect
        self.targetCount = targetCount
        self.totalCount = totalCorrect + totalIncorrect
        self.accuracy = totalCount != 0 ? Int((totalCorrect / totalCount) * 100) : 0
        if let targetCount = targetCount {
            self.divider = (CGFloat(targetCount) >= totalCount) ? CGFloat(targetCount) : totalCount
        } else {
            self.divider = totalCount
        }
    }
    
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    showDetail.toggle()
                }
            }) {
                chartSummary
            }
            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
            
            if showDetail {
                detailRepSummary
            }
        }
        .padding(5)
        .background(
            BlurView(style: .systemUltraThinMaterialLight)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(radius: 2)
        )
    }
    
    
    var detailRepSummary: some View {
        VStack {
            if let target = targetCount {
                HStack {
                    Text("Target")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.yellow.opacity(0.9)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .shadow(radius: 1)
                    Text("\(Int(target))")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.trailing, 10)
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)
                }
                .frame(width: 170)
                .background(
                    BlurView(style: .systemUltraThinMaterialLight)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 2)
                )
            }
            
            HStack {
                Text("Correct")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.9)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(radius: 1)
                Text("\(Int(totalCorrect))")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.trailing, 10)
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
            }
            .frame(width: 170)
            .background(
                BlurView(style: .systemUltraThinMaterialLight)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            )
            
            HStack {
                Text("Incorrect")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.9)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(radius: 1)
                Text("\(Int(totalIncorrect))")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.trailing, 10)
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
            }
            .frame(width: 170)
            .background(
                BlurView(style: .systemUltraThinMaterialLight)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            )
        }
        .transition(.offset(y: -150).combined(with: .scale).combined(with: .opacity))
    }
    
    var chartSummary: some View {
        ZStack(alignment: .leading) {
            Group {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.darkGray)
                    .frame(width: screenWidth, height: 40)
                
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.green.opacity(0.97))
                        .frame(width: Double(totalCorrect / divider * screenWidth), height: 40)
                    
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.red.opacity(0.97))
                        .frame(width: Double(totalIncorrect / divider * screenWidth), height: 40)
                }
                .shadow(radius: 6)
            }
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(radius: 4)
            
            if let targetCount = targetCount {
                RoundedRectangle(cornerRadius: 0)
                    .fill(.clear)
                    .frame(width: (CGFloat(targetCount) / divider) * screenWidth, height: 40)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "flag.checkered")
                            .font(.system(size: 30, weight: .bold))
                            .offset(x: 20, y: -35)
                            .foregroundColor(totalCorrect >= CGFloat(targetCount) ? .yellow : .darkGray)
                    }
            }
        }
        .frame(width: screenWidth)
    }
}

struct RepSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        RepSummaryView(screenWidth: UIScreen.main.bounds.width - 40,
                       totalCorrect: 10,
                       totalIncorrect: 2,
                       targetCount: 11)
    }
}
