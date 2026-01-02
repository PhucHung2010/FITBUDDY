//
//  RepSummaryView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 30/06/2025.
//

import SwiftUI

struct RepSummaryView: View {
    @EnvironmentObject var theme: AppThemeController
    var minimizeBarChart: Bool
    
    let screenWidth: CGFloat
    var totalCorrect: CGFloat
    var totalIncorrect: CGFloat
    var targetCount: Int?
    var accuracy: Int
    
    var totalCount: CGFloat
    var divider: CGFloat
    
    @State var showDetail: Bool = true
    
    init(minimizeBarChart: Bool = false,
         screenWidth: CGFloat,
         totalCorrect: CGFloat,
         totalIncorrect: CGFloat,
         targetCount: Int?) {
        self.minimizeBarChart = minimizeBarChart
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
                    .foregroundColor(.green.opacity(0.97))
                Text("Correct")
                    .font(.system(size: 12, weight: .semibold))
            }
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 3)
                    .foregroundColor(.red.opacity(0.97))
                Text("Incorrect")
                    .font(.system(size: 12, weight: .semibold))
            }
            if let target = targetCount {
                if target != -1 {
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 3)
                            .foregroundColor(.yellow.opacity(0.97))
                        Text("Target")
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
            if let target = targetCount {
                if target != -1 {
                    HStack {
                        Text("Target")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(theme.main.text)
                            .padding(5)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.yellow.opacity(0.9))
                                    .frame(height: 30)
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(Int(target))")
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
            
            HStack {
                Text("Correct")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(theme.main.text)
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.green.opacity(0.9))
                            .frame(height: 30)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(Int(totalCorrect))")
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
            
            HStack {
                Text("Incorrect")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(theme.main.text)
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.red.opacity(0.9))
                            .frame(height: 30)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(Int(totalIncorrect))")
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
        .padding(.bottom, 5)
        .transition(.offset(y: -150).combined(with: .scale).combined(with: .opacity))
    }
    
    var chartSummary: some View {
        ZStack(alignment: .leading) {
            Group {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.darkGray)
                    .frame(width: screenWidth, height: 35)
                
                HStack(spacing: 0) {
                    if totalCorrect != 0 {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.green.opacity(0.97))
                            .frame(width: Double(totalCorrect / divider * screenWidth), height: 35)
                            .overlay {
                                if minimizeBarChart {
                                    Text("\(Int(totalCorrect))")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                }
                            }
                    }
                    if totalIncorrect != 0 {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.red.opacity(0.97))
                            .frame(width: Double(totalIncorrect / divider * screenWidth), height: 35)
                            .overlay {
                                if minimizeBarChart {
                                    Text("\(Int(totalIncorrect))")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                }
                            }
                    }
                }
                .shadow(radius: 6)
            }
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(radius: 4)
            
            if let targetCount = targetCount {
                if targetCount != -1 {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(.clear)
                        .frame(width: (CGFloat(targetCount) / divider) * screenWidth, height: 35)
                        .overlay(alignment: .trailing) {
                            Image(systemName: "flag.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.yellow)
                                .overlay {
                                    if minimizeBarChart {
                                        Text("\(Int(targetCount))")
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

struct RepSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        RepSummaryView(screenWidth: UIScreen.main.bounds.width - 40,
                       totalCorrect: 0,
                       totalIncorrect: 0,
                       targetCount: 104234234234234)
        .environmentObject(AppThemeController())
    }
}
