//
//  PersistenceService.swift
//  SVB-App
//
//  Created by Savya Rai on 10/5/2025.
//

// Provides basic CRUD for Alert objects via SwiftData
import Foundation
import SwiftData

class PersistenceService {
    static func fetchAlerts(for ticker: String, in context: ModelContext) -> [Alert] {
        let descriptor = FetchDescriptor<Alert>(
            predicate: #Predicate { $0.ticker == ticker },
            sortBy: [SortDescriptor(\Alert.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    static func add(alert: Alert, in context: ModelContext) {
        context.insert(alert)
        try? context.save()
    }

    static func delete(alert: Alert, in context: ModelContext) {
        context.delete(alert)
        try? context.save()
    }
}
