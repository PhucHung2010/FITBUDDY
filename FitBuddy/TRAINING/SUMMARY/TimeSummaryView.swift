//
//  TimeSummaryView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 30/06/2025.
//

import SwiftUI

struct TimeSummaryView: View {
    @EnvironmentObject var theme: AppThemeController
    var minimizeBarChart: Bool
    
    let screenWidth: CGFloat
    var totalTime: CGFloat
    var targetTime: Int?
    var divider: CGFloat
    @State var showDetail: Bool = true
    
    init(minimizeBarChart: Bool = false,
         screenWidth: CGFloat,
         totalTime: CGFloat,
         targetTime: Int?) {
        self.minimizeBarChart = minimizeBarChart
        self.screenWidth = screenWidth
        self.totalTime = totalTime
        self.targetTime = targetTime
        if let targetTime = targetTime {
            self.divider = (CGFloat(targetTime) >= totalTime) ? CGFloat(targetTime) : totalTime
        } else {
            self.divider = totalTime
        }
        
        _showDetail = State(initialValue: minimizeBarChart ? false : true)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                    showDetail.toggle()
                }
            }) {
                chartSummary
            }
            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
            
            if showDetail {
                if minimizeBarChart {
                    explicationRepSummary
                } else {
                    detailRepSummary
                }
            }
        }
        .background (BlurRoundedBackground(cornerRadius: 20, shadowRadius: 2, style: .systemUltraThinMaterialLight))
    }
    
    
    var explicationRepSummary: some View {
        HStack {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 3)
                    .foregroundColor(.mint.opacity(0.97))
                Text("Total time")
                    .font(.system(size: 12, weight: .semibold))
            }
            if let target = targetTime {
                if target != -1 {
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 3)
                            .foregroundColor(.red.opacity(0.97))
                        Text("Limit time")
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
            }
        }
        .frame(width: screenWidth - 20)
        .transition(.offset(y: -100).combined(with: .scale).combined(with: .opacity))
    }
    
    
    var detailRepSummary: some View {
        VStack(spacing: 7) {
            HStack {
                Text("Total time")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(theme.main.text)
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.mint)
                            .frame(height: 30)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(Int(totalTime) / 60):\(String(format: "%02d", Int(totalTime) % 60))")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(theme.main.text)
                    .padding(.trailing, 10)
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
            }
            .frame(width: 160, height: 30)
            .background(
                BlurView(style: theme.main.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            )
            
            if let target = targetTime {
                if target != -1 {
                    HStack {
                        Text("Limit time")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(theme.main.text)
                            .padding(5)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.red)
                                    .frame(height: 30)
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(Int(target) / 60):\(String(format: "%02d", Int(target) % 60))")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(theme.main.text)
                            .padding(.trailing, 10)
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                    }
                    .frame(width: 160, height: 30)
                    .background(
                        BlurView(style: theme.main.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 2)
                    )
                }
            }
        }
        .padding(.bottom, 5)
        .transition(.offset(y: -100).combined(with: .scale).combined(with: .opacity))
    }

    
    var chartSummary: some View {
        ZStack(alignment: .leading) {
            Group {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.darkGray)
                    .frame(width: screenWidth, height: 35)
                
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.mint.opacity(0.97))
                        .frame(width:
                                min(Double(totalTime
                                           / CGFloat((targetTime == -1) ? 1 : targetTime ?? 1)), 1) * screenWidth,
                               height: 35)
                        .overlay {
                            if minimizeBarChart {
                                Text("\(Int(totalTime))")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                }
                .shadow(radius: 6)
            }
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(radius: 4)
            
            if let targetTime = targetTime {
                if targetTime != -1 {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(.clear)
                        .frame(width: CGFloat(targetTime) / divider * screenWidth, height: 35)
                        .overlay(alignment: .trailing) {
                            Image(systemName: "flag.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.red.opacity(0.9))
                                .overlay {
                                    if minimizeBarChart {
                                        Text("\(Int(targetTime))")
                                            .font(.system(size: 15, weight: .bold))
                                            .offset(y: -3)
                                            .foregroundColor(.black)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                    }
                                }
                                .offset(x: 20, y: -32)
                        }
                }
            }
        }
        .frame(width: screenWidth)
    }
}

struct TimeSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSummaryView(screenWidth: UIScreen.main.bounds.width - 40,
                        totalTime: 674,
                        targetTime: 30)
        .environmentObject(AppThemeController())
    }
}
