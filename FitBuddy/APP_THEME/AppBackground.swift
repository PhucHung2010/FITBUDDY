import SwiftUI

struct AppBackground: View {
    @EnvironmentObject var theme: AppThemeController
    var body: some View {
        ZStack {
            LinearGradient(colors: backgroundColors, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
    }
    
    private var backgroundColors: [Color] {
        switch theme.appTheme {
        case .light:
            return [.darkOffWhite, .darkOffWhite2]
        case .dark:
            return [.darkStart, .darkEnd]
        case .cosmic:
            return [Color(red: 35 / 255, green: 15 / 255, blue: 60 / 255), Color(red: 10 / 255, green: 5 / 255, blue: 25 / 255)]
        case .sunset:
            return [Color(red: 65 / 255, green: 10 / 255, blue: 25 / 255), Color(red: 20 / 255, green: 5 / 255, blue: 10 / 255)]
        }
    }
}

struct WaveShape1: Shape {
    var yOffset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width

        path.move(to: CGPoint(x: 0, y: yOffset))
        path.addCurve(to: CGPoint(x: width, y: yOffset),
                      control1: CGPoint(x: width * 0.85, y: yOffset + 160),
                      control2: CGPoint(x: width * 1, y: yOffset - 60))
        path.addLine(to: CGPoint(x: width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}

struct WaveShape2: Shape {
    var yOffset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width

        path.move(to: CGPoint(x: 0, y: yOffset))
        path.addCurve(to: CGPoint(x: width, y: yOffset),
                      control1: CGPoint(x: width * 0.25, y: yOffset + 10),
                      control2: CGPoint(x: width * 0.25, y: yOffset - 90))
        path.addLine(to: CGPoint(x: width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}

struct WaveShape3: Shape {
    var yOffset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width

        path.move(to: CGPoint(x: 0, y: yOffset))
        path.addCurve(to: CGPoint(x: width, y: yOffset),
                      control1: CGPoint(x: width * 0.35, y: yOffset + 60),
                      control2: CGPoint(x: width * 0.75, y: yOffset - 60))
        path.addLine(to: CGPoint(x: width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}


//struct CurvedShape: Shape {
//    let type: Int
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//
//        // Bắt đầu từ góc trên bên trái
////        path.move(to: CGPoint(x: 0, y: 9000000))
//        path.move(to: CGPoint(x: 0, y: type == 1 ? 1000000 : -1000000))
//
//        // Di chuyển xuống dưới
////        path.addLine(to: CGPoint(x: 0, y: rect.height))
//        path.addLine(to: CGPoint(x: 0, y: rect.height))
//
//        // Tạo đường cong sang bên phải
//        path.addCurve(to: CGPoint(x: rect.width, y: -100),
//                      control1: CGPoint(x: rect.width * 1.7, y: rect.height * 0),
//                      control2: CGPoint(x: rect.width * 0, y: rect.height * 0))
//
//        // Đóng khung phía trên
//        path.addLine(to: CGPoint(x: rect.width, y: 0))
//        path.closeSubpath()
//
//        return path
//    }
//}




extension Color {
    // --- Cosmic Light Mode ---
    static let lightOffWhite = Color(red: 230 / 255, green: 232 / 255, blue: 245 / 255)   // Lavender mist
    static let offWhite = Color(red: 215 / 255, green: 218 / 255, blue: 235 / 255)         // Soft nebula silver
    static let darkOffWhite = Color(red: 190 / 255, green: 195 / 255, blue: 220 / 255)     // Cool twilight
    static let darkOffWhite2 = Color(red: 165 / 255, green: 170 / 255, blue: 200 / 255)    // Deep twilight
    
    // --- Cosmic Dark Mode ---
    static let darkStart = Color(red: 15 / 255, green: 12 / 255, blue: 35 / 255)           // Deep space
    static let darkEnd = Color(red: 5 / 255, green: 5 / 255, blue: 15 / 255)               // Void black
    static let darkStart2 = Color(red: 25 / 255, green: 20 / 255, blue: 50 / 255)          // Nebula purple
    static let darkEnd2 = Color(red: 12 / 255, green: 10 / 255, blue: 28 / 255)            // Dark nebula
    static let darkMiddle = Color(red: 18 / 255, green: 15 / 255, blue: 40 / 255)          // Mid space
    static let darkMiddle2 = Color(red: 12 / 255, green: 10 / 255, blue: 30 / 255)         // Deep mid space
    
    // --- Neutral Grays (slightly blue-tinted for cosmic feel) ---
    static let darkGray05 = Color(red: 110 / 255, green: 115 / 255, blue: 130 / 255)
    static let darkGray07 = Color(red: 90 / 255, green: 95 / 255, blue: 110 / 255)
    static let darkGray = Color(red: 75 / 255, green: 80 / 255, blue: 95 / 255)
    static let darkGray2 = Color(red: 60 / 255, green: 65 / 255, blue: 80 / 255)
    static let darkGray3 = Color(red: 40 / 255, green: 42 / 255, blue: 58 / 255)
    
    // --- Cosmic Accent Colors ---
    static let darkTeal = Color(red: 0 / 255, green: 80 / 255, blue: 120 / 255)            // Deep ocean
    static let lightOrange = Color(red: 100 / 255, green: 220 / 255, blue: 255 / 255)      // Electric cyan glow
    static let lightGray = Color(red: 160 / 255, green: 165 / 255, blue: 185 / 255)
    static let lightGrayMore = Color(red: 200 / 255, green: 205 / 255, blue: 220 / 255)
    
    // --- Blues → Cosmic purples ---
    static let darkBlue = Color(red: 60 / 255, green: 50 / 255, blue: 120 / 255)           // Deep purple
    static let Blue = Color(red: 100 / 255, green: 80 / 255, blue: 180 / 255)              // Nebula purple
    static let lightBlue = Color(red: 140 / 255, green: 130 / 255, blue: 220 / 255)        // Soft purple
    static let lightBlue2 = Color(red: 180 / 255, green: 170 / 255, blue: 240 / 255)       // Light nebula
    
    static let lowBlack = Color(red: 15 / 255, green: 15 / 255, blue: 25 / 255)            // Space black
    
    // --- Main Accent: Electric Cyan (replaces Orange) ---
    static let Orange = Color(red: 0 / 255, green: 200 / 255, blue: 255 / 255)             // ⚡ Electric Cyan
}

struct CurvedBackground_Previews: PreviewProvider {
    static var previews: some View {
        AppBackground()
            .environmentObject(AppThemeController())
    }
}
