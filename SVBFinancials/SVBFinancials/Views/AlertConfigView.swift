//
//  AlertConfigView.swift
//  SVB-App
//
//  Created by Savya Rai on 10/5/2025.
//

import SwiftUI
import SwiftData

struct AlertConfigView: View {
    let ticker: String
    let companyName: String?
    let currentPrice: Double?
    @StateObject private var viewModel: AlertViewModel

    init(
        ticker: String,
        companyName: String?,
        currentPrice: Double?,
        context: ModelContext
    ) {
        self.ticker = ticker
        self.companyName = companyName
        self.currentPrice = currentPrice
        _viewModel = StateObject(
            wrappedValue: AlertViewModel(ticker: ticker, context: context)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Set Target Price for \(ticker)")
                .font(.headline)
                .foregroundColor(.themeText)
                .padding(.horizontal)

            HStack(spacing: 12) {
                TextField("Enter price", text: $viewModel.targetPriceString)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    viewModel.addAlert()
                }) {
                    Text("Confirm")
                        .font(.subheadline).bold()
                        .frame(width: 80, height: 44)
                        .background(Color.themePrimary)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)

            if viewModel.alerts.isEmpty {
                VStack {
                    Text("No alerts set yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 32)
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.alerts) { alert in
                            let op = currentPrice.map { alert.targetPrice < $0 ? "≤" : "≥" } ?? "≥"
                            let priceText = String(format: "%.2f", alert.targetPrice)

                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Alert when price \(op) $\(priceText)")
                                        .font(.body).bold()
                                        .foregroundColor(.themeText)
                                }
                                Spacer()
                                Button(role: .destructive) {
                                    viewModel.deleteAlert(alert)
                                } label: {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.themeSecondary, lineWidth: 1)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.themeBackground))
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .padding(.vertical)
        .background(Color.white)
    }
}
