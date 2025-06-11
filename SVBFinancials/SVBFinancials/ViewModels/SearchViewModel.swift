//
//  SearchViewModel.swift
//  SVB-App
//
//  Created by Ali bonagdaran on 10/5/2025.
//
// manages the state and logic for the stock search feature.
import Foundation
import Combine
@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [Stock] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let stockService: StockService
    private var cancellables = Set<AnyCancellable>()

    init(stockService: StockService = StockService()) {
        self.stockService = stockService
        setupDebouncer()
    }

    func performSearch() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            self.searchResults = []
            self.errorMessage = nil
            return
        }

        self.isLoading = true
        self.errorMessage = nil
        self.searchResults = []
        
        Task {
            do {
                let stocks = try await stockService.searchStocks(query: query)

                self.searchResults = stocks
                if stocks.isEmpty {
                    self.errorMessage = "No results found for \"\(query)\""
                }
                self.isLoading = false
            } catch let networkError as NetworkManager.NetworkError {
                switch networkError {
                case .apiError(let message):
                    self.errorMessage = message
                case .invalidURL:
                    self.errorMessage = "A problem has occured when attempting to communicate with the API. (Request URL is malformed)"
                case .requestFailed:
                    self.errorMessage = "Network error. Check your internet connection."
                case .invalidResponse:
                    self.errorMessage = "The response received from the API is invalid. The API could be down, try again later."
                case .decodingError:
                    self.errorMessage = "A problem occured displaying the search results. (Decoding error)"
                }
                self.isLoading = false
            } catch let serviceError as StockService.ServiceError {
                 switch serviceError {
                    case .urlConstructionFailed:
                        self.errorMessage = "A problem occured constructing the API request"
                    case .noPriceDataFound(let ticker):
                        self.errorMessage = "Pricing data is not availiable for: \(ticker)."
                    case .underlyingError(let error):
                        self.errorMessage = "A really bad error has occured; \(error.localizedDescription)"
                    case .apiKeyMissing:
                        self.errorMessage = "The API key cound not be found. (For the group: do you have a secrets.swift file in ur xcode project? make sure u have APIKEY=insertkeyhere in the first line. if u do, something has gone terribly wrong"
                 }
                self.isLoading = false
            }
            catch {
                self.errorMessage = "A rare and unexpected error occurred: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    private func setupDebouncer() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] newTextQuery in
                self?.performSearch()
            }
            .store(in: &cancellables)
    }
}
