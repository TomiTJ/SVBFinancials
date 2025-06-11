//
//  AlertViewModel.swift
//  SVB-App
//
//  Created by Savya Rai on 10/5/2025.
//

// Manages alert creation, deletion, and fetching for a given ticker
import Foundation
import SwiftData
import Combine

@MainActor
class AlertViewModel: ObservableObject {
    @Published var targetPriceString: String = ""
    @Published var alerts: [Alert] = []

    private let ticker: String
    private let context: ModelContext

    init(ticker: String, context: ModelContext) {
        self.ticker = ticker
        self.context = context
        fetchAlerts()
    }

    func fetchAlerts() {
        let tickerToFilter = self.ticker

        let descriptor = FetchDescriptor<Alert>(
            predicate: #Predicate { $0.ticker == tickerToFilter },
            sortBy: [SortDescriptor(\Alert.createdAt, order: .reverse)]
        )
        do {
            let fetched = try context.fetch(descriptor)
            self.alerts = fetched
        } catch {
            print("Failed to fetch alerts: \(error.localizedDescription)")
            self.alerts = []
        }
    }

    func addAlert() {
        guard let price = Double(targetPriceString) else {
            print("Invalid target price string: \(targetPriceString)")
            return
        }
        // Create the new Alert object using its defined initializer
        let alert = Alert(ticker: self.ticker, targetPrice: price)
        context.insert(alert)
        do {
            try context.save()
            targetPriceString = "" // Clear only on successful save
            fetchAlerts() // Refresh the list
            // Schedule notification using AlertService
            AlertService.shared.schedulePriceAlert(ticker: self.ticker, price: price)
        } catch {
            print("Failed to save new alert: \(error.localizedDescription)")
        }
    }

    func deleteAlert(_ alert: Alert) {
        context.delete(alert)
        do {
            try context.save()
            fetchAlerts() // Refresh the list

            // Cancel notification
            let formattedPrice = String(format: "%.2f", alert.targetPrice)
            let identifier = "alert_\(alert.ticker)_\(formattedPrice)"
            AlertService.shared.removeAlertNotification(identifier: identifier)
        } catch {
            print("Failed to delete alert: \(error.localizedDescription)")
        }
    }
}
