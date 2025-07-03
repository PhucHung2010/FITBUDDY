//
//  TimeSummaryView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 30/06/2025.
//

import SwiftUI

struct TimeSummaryView: View {
    let screenWidth: CGFloat
    var totalTime: CGFloat
    var targetTime: Int?
    var divider: CGFloat
    @State var showDetail: Bool = true
    init(screenWidth: CGFloat, totalTime: CGFloat, targetTime: Int?) {
        self.screenWidth = screenWidth
        self.totalTime = totalTime
        self.targetTime = targetTime
        if let targetTime = targetTime {
            self.divider = (CGFloat(targetTime) >= totalTime) ? CGFloat(targetTime) : totalTime
        } else {
            self.divider = totalTime
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
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
            HStack {
                Text("Total")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.mint.opacity(0.9)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(radius: 1)
                Text("\(Int(totalTime))")
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
            
            if let target = targetTime {
                HStack {
                    Text("Target")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.9)))
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
                        .fill(Color.mint.opacity(0.97))
                        .frame(width: min(Double(totalTime / CGFloat(targetTime ?? 1)), 1) * screenWidth, height: 40)
                }
                .shadow(radius: 6)
            }
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(radius: 4)
            
            if let targetTime = targetTime {
                RoundedRectangle(cornerRadius: 0)
                    .fill(.clear)
                    .frame(width: CGFloat(targetTime) / divider * screenWidth, height: 40)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 30, weight: .bold))
                            .offset(x: 20, y: -35)
                            .foregroundColor(totalTime > CGFloat(targetTime) ? .red : .mint)
                    }
            }
        }
        .frame(width: screenWidth)
    }
}

struct TimeSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSummaryView(screenWidth: UIScreen.main.bounds.width - 40,
                        totalTime: 10,
                        targetTime: 12)
    }
}
