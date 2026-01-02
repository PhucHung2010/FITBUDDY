//
//  NotificationView.swift
//  FitBuddy
//
//  Created by Nguyen Huu Phuc Hung on 4/8/25.
//

import SwiftUI
import UserNotifications

struct NotificationView: View {
    var body: some View {
        Button("🔔 Gửi thông báo đủ dạng") {
            requestPermissionAndSend()
        }
        .padding()
        .background(Color.orange)
        .foregroundColor(.white)
        .clipShape(Capsule())
    }

    func requestPermissionAndSend() {
        let center = UNUserNotificationCenter.current()

        // Yêu cầu quyền đầy đủ
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                sendNotification()
            } else {
                print("⚠️ Không có quyền gửi thông báo")
            }
        }
    }

    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "📣 Thông báo đầy đủ"
        content.body = "Đây là alert + sound + badge!"
        content.sound = .default
        content.badge = NSNumber(value: 1) // Hiện badge "1" trên biểu tượng app

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)

        let request = UNNotificationRequest(identifier: "full_notification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}


import UserNotifications

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("✅ Notification permission granted.")
        } else {
            print("❌ Notification permission denied.")
        }
    }
}

func scheduleNotifications(for plannedDates: [Date?]) {
    let center = UNUserNotificationCenter.current()
    
    // Xoá hết thông báo cũ trước khi lên lịch mới (tuỳ ý)
    center.removeAllPendingNotificationRequests()

    for (index, optionalDate) in plannedDates.enumerated() {
        guard let date = optionalDate else { continue }

        // Tách các thành phần ngày
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = "🏋️‍♀️ Đến giờ tập luyện!"
        content.body = "Hôm nay bạn có một bài tập trong kế hoạch."
        content.sound = .default
        content.badge = NSNumber(value: index + 1) // Mỗi thông báo tăng badge (tuỳ chọn)

        let request = UNNotificationRequest(
            identifier: "WorkoutNotification_\(index)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("❌ Lỗi khi lên lịch: \(error.localizedDescription)")
            } else {
                print("✅ Đã lên lịch thông báo cho: \(date)")
            }
        }
    }
}



struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
            .environmentObject(TabViewController())
            .environmentObject(UserController())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
