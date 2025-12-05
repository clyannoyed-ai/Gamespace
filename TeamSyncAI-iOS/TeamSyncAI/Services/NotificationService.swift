import Foundation
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    /// Request user permission for notifications
    func requestAuthorizationIfNeeded() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    /// Schedule a local notification for an event reminder
    func scheduleEventReminder(event: Event, minutesBefore: Int = 60) {
        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body = "Your practice starts in \(minutesBefore) minutes"
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        // Add custom data
        content.userInfo = [
            "eventId": event.id,
            "teamId": event.teamId,
            "type": "eventReminder"
        ]
        
        // Calculate trigger time
        let triggerTime = event.startTime.addingTimeInterval(TimeInterval(-minutesBefore * 60))
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerTime), repeats: false)
        
        let request = UNNotificationRequest(identifier: "event-\(event.id)-\(minutesBefore)m", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling event reminder: \(error)")
            } else {
                print("Event reminder scheduled for \(event.title)")
            }
        }
    }
    
    /// Send a local notification for a new message
    func notifyNewMessage(message: Message, senderName: String) {
        let content = UNMutableNotificationContent()
        content.title = senderName
        content.body = message.content
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        content.userInfo = [
            "messageId": message.id,
            "teamId": message.teamId,
            "type": "message"
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "message-\(message.id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling message notification: \(error)")
            }
        }
    }
    
    /// Send a local notification for an announcement
    func notifyNewAnnouncement(announcement: Announcement) {
        let content = UNMutableNotificationContent()
        content.title = announcement.title
        content.body = announcement.content
        
        // Set priority-based sound
        switch announcement.priority {
        case .urgent, .high:
            content.sound = .default
        default:
            content.sound = nil
        }
        
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        content.userInfo = [
            "announcementId": announcement.id,
            "teamId": announcement.teamId,
            "type": "announcement",
            "priority": announcement.priority.rawValue
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "announcement-\(announcement.id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling announcement notification: \(error)")
            }
        }
    }
    
    /// Send a local notification for attendance request
    func notifyAttendanceRequest(event: Event) {
        let content = UNMutableNotificationContent()
        content.title = "Attendance Needed"
        content.body = "Please confirm your attendance for \(event.title)"
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        content.userInfo = [
            "eventId": event.id,
            "teamId": event.teamId,
            "type": "attendanceRequest"
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "attendance-\(event.id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling attendance notification: \(error)")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        
        // Handle different notification types
        if let type = userInfo["type"] as? String {
            switch type {
            case "eventReminder":
                print("Event reminder received while app is active")
            case "message":
                print("Message notification received while app is active")
            case "announcement":
                print("Announcement received while app is active")
            default:
                break
            }
        }
        
        // Show notification even when app is in foreground
        return [.banner, .sound, .badge]
    }
    
    /// Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String {
            switch type {
            case "eventReminder":
                if let eventId = userInfo["eventId"] as? String {
                    print("Navigate to event: \(eventId)")
                    // Post notification for app to handle navigation
                    NotificationCenter.default.post(name: NSNotification.Name("navigateToEvent"), object: nil, userInfo: ["eventId": eventId])
                }
            case "message":
                if let teamId = userInfo["teamId"] as? String {
                    print("Navigate to messages for team: \(teamId)")
                    NotificationCenter.default.post(name: NSNotification.Name("navigateToMessages"), object: nil, userInfo: ["teamId": teamId])
                }
            case "announcement":
                if let announcementId = userInfo["announcementId"] as? String {
                    print("Navigate to announcement: \(announcementId)")
                    NotificationCenter.default.post(name: NSNotification.Name("navigateToAnnouncement"), object: nil, userInfo: ["announcementId": announcementId])
                }
            default:
                break
            }
        }
    }
    
    /// Clear all notifications
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    /// Get pending notifications count
    func getPendingNotificationsCount() async -> Int {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests.count
    }
}
