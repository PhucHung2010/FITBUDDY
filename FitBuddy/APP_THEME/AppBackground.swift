import SwiftUI

struct AppBackground: View {
    @EnvironmentObject var theme: AppThemeController
    var body: some View {
        ZStack {
            if theme.appTheme == .light {
                LinearGradient(colors: [.darkOffWhite, .darkOffWhite2], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            } else {
                LinearGradient(colors: [.darkStart, .darkEnd], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            }
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
    static let lightOffWhite = Color(red: 235 / 255, green: 235 / 255, blue: 255 / 255)
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
    static let darkOffWhite = Color(red: 205 / 255, green: 205 / 255, blue: 215 / 255)
    static let darkOffWhite2 = Color(red: 185 / 255, green: 185 / 255, blue: 195 / 255)
    
    static let darkStart = Color(red: 60 / 255, green: 70 / 255, blue: 75 / 255)
    static let darkEnd = Color(red: 25 / 255, green: 25 / 255, blue: 30 / 255)
    static let darkStart2 = Color(red: 70 / 255, green: 80 / 255, blue: 85 / 255)
    static let darkEnd2 = Color(red: 35 / 255, green: 35 / 255, blue: 40 / 255)
    static let darkMiddle = Color(red: 40 / 255, green: 45 / 255, blue: 50 / 255)
    static let darkMiddle2 = Color(red: 30 / 255, green: 35 / 255, blue: 40 / 255)
    
    static let darkGray05 = Color(red: 117 / 255, green: 117 / 255, blue: 117 / 255)
    static let darkGray07 = Color(red: 100 / 255, green: 100 / 255, blue: 100 / 255)
    static let darkGray = Color(red: 90 / 255, green: 90 / 255, blue: 90 / 255)
    static let darkGray2 = Color(red: 80 / 255, green: 80 / 255, blue: 80 / 255)
    static let darkGray3 = Color(red: 60 / 255, green: 60 / 255, blue: 60 / 255)
    
    static let darkTeal = Color(red: 0 / 255, green: 56 / 255, blue: 56 / 255)
    static let lightOrange = Color(red: 255 / 255, green: 159 / 255, blue: 12 / 255)
    static let lightGray = Color(red: 190 / 255, green: 190 / 255, blue: 190 / 255)
    static let lightGrayMore =  Color(red: 220 / 255, green: 220 / 255, blue: 220 / 255)
    
    static let darkBlue = Color(red: 55 / 255, green: 91 / 255, blue: 128 / 255)
    static let Blue = Color(red: 94 / 255, green: 138 / 255, blue: 174 / 255)
    static let lightBlue = Color(red: 145 / 255, green: 189 / 255, blue: 225 / 255)
    static let lightBlue2 = Color(red: 187 / 255, green: 219 / 255, blue: 240 / 255)
    
    static let lowBlack = Color(red: 33 / 255, green: 33 / 255, blue: 33 / 255)
    
    static let Orange = Color(red: 236 / 255, green: 94 / 255, blue: 43 / 255)
}

struct CurvedBackground_Previews: PreviewProvider {
    static var previews: some View {
        AppBackground()
            .environmentObject(AppThemeController())
    }
}
