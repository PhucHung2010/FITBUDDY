//
//  LoginView.swift
//  FitBuddy
//
//  UI for Login Page – Sign In with Google only
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: SupabaseAuthManager

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [Color(hex: "#1a1a2e"), Color(hex: "#16213e"), Color(hex: "#0f3460")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Logo
                VStack(spacing: 8) {
                    Image(systemName: "figure.run.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#e94560"), Color(hex: "#f5a623")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(hex: "#e94560").opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    Text("FitBuddy")
                        .font(.system(size: 42, weight: .black))
                        .foregroundColor(.white)
                    
                    Text("Your personal fitness companion")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                // Sign In Card
                VStack(spacing: 20) {
                    Text("Get Started")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                    
                    // Error Message
                    if let error = authManager.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(Color(hex: "#e94560"))
                            Text(error)
                                .font(.caption)
                                .foregroundColor(Color(hex: "#e94560"))
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Loading indicator
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(8)
                    }
                    
                    // Sign In with Google Button
                    Button(action: {
                        authManager.signInWithGoogle()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "g.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color(hex: "#4285F4"))
                            
                            Text("Sign in with Google")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: Color.white.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .disabled(authManager.isLoading)
                }
                .padding(28)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white.opacity(0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                
                Spacer()
                    .frame(height: 20)

                Text("By continuing, you agree to our Terms & Privacy Policy")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.35))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Color Helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(SupabaseAuthManager())
    }
}
