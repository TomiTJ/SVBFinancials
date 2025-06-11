//  SearchView.swift
//  SVB-App
//
//  Created by Ali bonagdaran on 10/5/2025.

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel

    init(viewModel: SearchViewModel? = nil) {
        let vm = viewModel ?? SearchViewModel()
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading && viewModel.searchResults.isEmpty {
                ProgressView("Searching...")
                    .padding()
                    .foregroundColor(.themePrimary)
                Spacer()
            } else if let errorMessage = viewModel.errorMessage, viewModel.searchResults.isEmpty {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                        .padding(.bottom)
                    Text(errorMessage)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    if errorMessage.contains("API Key") {
                        Text("The API KEY isn't detected, or something else with the API key has gone wrong :(")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Button("Retry") {
                        viewModel.performSearch()
                    }
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                Spacer()
            } else {
                List(viewModel.searchResults) { stock in
                    NavigationLink(destination: StockDetailView(stock: stock)
                                    .environmentObject(viewModel)) {
                        StockSearchRow(stock: stock)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Search stocks")
        .navigationBarBackButtonHidden(false)
        .searchable(
            text: $viewModel.searchText,
            prompt: "Search ticker or company name"
        )
        .onSubmit(of: .search) {
            viewModel.performSearch()
        }
    }
}

struct StockSearchRow: View {
    let stock: Stock
    @EnvironmentObject private var favouriteViewModel: FavouriteViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.ticker)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.themeText)
                Text(stock.companyName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()
            HStack(spacing: 12) {
                if let price = stock.currentPrice, let changePercent = stock.priceChangePercent {
                    VStack(alignment: .trailing) {
                        Text(String(format: "%.2f", price))
                            .font(.headline)
                        Text(String(format: "%@%.2f%%", changePercent >= 0 ? "+" : "", changePercent * 100))
                            .font(.subheadline)
                            .foregroundColor(changePercent >= 0 ? .green : .red)
                    }
                } else {
                    Text("N/A")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.trailing)
                }
                
                Button {
                    favouriteViewModel.toggleFavourite(ticker: stock.ticker)
                } label: {
                    Image(systemName: favouriteViewModel.isFavourite(ticker: stock.ticker) ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        let mockSearchVM = SearchViewModel()
        mockSearchVM.searchResults = [
            Stock(ticker: "AAPL", companyName: "Apple Inc.", currentPrice: 172.65, priceChange: 1.23, priceChangePercent: 0.0072),
            Stock(ticker: "TSLA", companyName: "Tesla Inc.", currentPrice: 245.12, priceChange: -3.87, priceChangePercent: -0.0156)
        ]
      
        let mockFavouriteVM = FavouriteViewModel()
        mockFavouriteVM.toggleFavourite(ticker: "AAPL")

        return SearchView(viewModel: mockSearchVM)
            .environmentObject(mockFavouriteVM)

    }
}
