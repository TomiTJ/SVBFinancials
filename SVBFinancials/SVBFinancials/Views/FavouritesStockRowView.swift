//
//  FavouritesStockRowView.swift
//  SVB
//
//  Created by Tomi Nguyen on 15/5/2025.
//

import SwiftUI

struct FavouriteStockRowView: View {
    let stock: Stock
    @EnvironmentObject private var favouriteViewModel: FavouriteViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.ticker)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.primary)
                Text(stock.companyName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing) {
                if let price = stock.currentPrice {
                    Text(String(format: "%.2f", price))
                        .font(.headline)
                        .foregroundColor(.primary)
                } else {
                    Text("N/A")
                        .font(.headline)
                        .foregroundColor(.gray)
                }

                if let changePercent = stock.priceChangePercent {
                    Text(String(format: "%@%.2f%%", changePercent >= 0 ? "+" : "", changePercent * 100))
                        .font(.subheadline)
                        .foregroundColor(changePercent >= 0 ? .green : .red)
                } else if let change = stock.priceChange {
                     Text(String(format: "%@%.2f", change >= 0 ? "+" : "", change))
                        .font(.subheadline)
                        .foregroundColor(change >= 0 ? .green : .red)
                }
            }

            Button {
                favouriteViewModel.toggleFavourite(ticker: stock.ticker)
            } label: {
                Image(systemName: favouriteViewModel.isFavourite(ticker: stock.ticker) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .padding(.leading, 8)
            }
        }
        .padding(.vertical, 6)
    }
}

struct FavouriteStockRowView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleStock1 = Stock(ticker: "AAPL", companyName: "Apple Inc.", currentPrice: 175.30, priceChange: 1.20, priceChangePercent: 0.0069)
        let sampleStock2 = Stock(ticker: "MSFT", companyName: "Microsoft Corporation", currentPrice: 420.80, priceChange: -2.50, priceChangePercent: -0.0059)
        let sampleStock3 = Stock(ticker: "GOOG", companyName: "Alphabet Inc. Class C", currentPrice: 170.00)
        let sampleStock4 = Stock(ticker: "TSLA", companyName: "Tesla, Inc.")
        
        let mockFavouriteVM = FavouriteViewModel()
        mockFavouriteVM.toggleFavourite(ticker: "AAPL")
        mockFavouriteVM.toggleFavourite(ticker: "GOOG")

        return List {
            FavouriteStockRowView(stock: sampleStock1)
            FavouriteStockRowView(stock: sampleStock2)
            FavouriteStockRowView(stock: sampleStock3)
            FavouriteStockRowView(stock: sampleStock4)
        }
        .environmentObject(mockFavouriteVM)
        .previewLayout(.sizeThatFits)
    }
}
