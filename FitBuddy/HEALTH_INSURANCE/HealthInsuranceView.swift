//
//  healthInsuranceView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 02/06/2025.
//

import SwiftUI

struct HealthInsuranceView: View {
    @EnvironmentObject var theme: AppThemeController
    @State private var dailyGoalProgress: CGFloat = 0.84
    
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Health & Insurance")
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundColor(theme.main.text)
                            Text("Connected Vitality Program")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(theme.main.text.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        NeumorphicIndicatorDots(dotSize: 5, spacing: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Policy Status Hero Card
                    HStack(spacing: 16) {
                        Image(systemName: "shield.checkerboard")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(NeumorphicColors.dotGreen)
                            .frame(width: 56, height: 56)
                            .neumorphicCircle()
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("FitShield Premium Active")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(theme.main.text)
                            Text("Tier 1 Discount: 15% Off Policy")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(NeumorphicColors.dotGreen)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 22))
                            .foregroundColor(NeumorphicColors.dotGreen)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .neumorphicCard(cornerRadius: 24, accentGlow: NeumorphicColors.dotGreen.opacity(0.35))
                    .padding(.horizontal, 20)
                    
                    // Rotary Knob Dial Card for Daily Activity Goal
                    VStack(spacing: 14) {
                        HStack {
                            Text("Daily Activity Score")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(theme.main.text)
                            Spacer()
                            Text("\(Int(dailyGoalProgress * 100))%")
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.25))
                        }
                        
                        NeumorphicKnobView(
                            size: 170,
                            progress: Double(dailyGoalProgress)
                        ) {
                            VStack(spacing: 2) {
                                Text("Goal")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(theme.main.text.opacity(0.5))
                                Text("\(Int(dailyGoalProgress * 100))%")
                                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                                    .foregroundColor(theme.main.text)
                            }
                        }
                        .padding(.vertical, 6)
                        
                        Text("16% remaining to unlock 500 bonus points")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(theme.main.text.opacity(0.5))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .neumorphicCard(cornerRadius: 28)
                    .padding(.horizontal, 20)
                    
                    // 2x2 Metric Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        metricCard(icon: "heart.fill", title: "Heart Rate", value: "72 bpm", color: Color(red: 1.0, green: 0.35, blue: 0.35))
                        metricCard(icon: "flame.fill", title: "Calories", value: "540 kcal", color: Color(red: 1.0, green: 0.55, blue: 0.15))
                        metricCard(icon: "figure.walk", title: "Steps", value: "8,420", color: Color(red: 0.2, green: 0.7, blue: 1.0))
                        metricCard(icon: "bolt.fill", title: "Recovery", value: "94%", color: Color(red: 0.2, green: 0.8, blue: 0.4))
                    }
                    .padding(.horizontal, 20)
                    
                    // Sync / Redeem Action Button
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 16, weight: .bold))
                            Text("Sync Apple Health Data")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            Capsule()
                                .fill(theme.accentGradient)
                                .shadow(color: theme.accentColor.opacity(0.35), radius: 5, y: 2)
                        )
                    }
                    .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 100)
                }
            }
        }
    }
    
    @ViewBuilder
    func metricCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
                    .frame(width: 34, height: 34)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())
                
                Spacer()
                
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.main.text.opacity(0.5))
                Text(value)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(theme.main.text)
            }
        }
        .padding(14)
        .neumorphicCard(cornerRadius: 20)
    }
}
