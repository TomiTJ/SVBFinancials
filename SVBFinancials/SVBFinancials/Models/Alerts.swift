//
//  Alets.swift
//  

// Defines the Alert entity for SwiftData persistence
import Foundation
import SwiftData

@Model
class Alert: Identifiable {
    @Attribute(.unique) var id: UUID
    var ticker: String
    var targetPrice: Double
    var createdAt: Date

    init(ticker: String, targetPrice: Double) {
        self.id = UUID()
        self.ticker = ticker
        self.targetPrice = targetPrice
        self.createdAt = Date()
    }
}
