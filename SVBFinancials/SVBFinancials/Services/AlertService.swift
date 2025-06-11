//
//  AlertService.swift
//  SVB-App
//
//  Created by Savya Rai on 10/5/2025.
//

// Schedules and cancels local notifications for price alerts
import Foundation
import UserNotifications

class AlertService {
    static let shared = AlertService()
    private init() {}

    func schedulePriceAlert(ticker: String, price: Double) {
        let content = UNMutableNotificationContent()
        content.title = "\(ticker) Price Alert"
        // format the price first, then interpolate
        let formatted = String(format: "%.2f", price)
        content.body = "Target price of \(formatted) reached."
        content.sound = .default

        let identifier = "alert_\(ticker)_\(formatted)"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func removeAlertNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
