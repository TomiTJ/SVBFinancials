import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    
    @Published var favouriteStocks: [Stock] = []
    @Published var latestNews: [NewsArticle] = []
    
    @Published var isLoadingFavourites: Bool = false
    @Published var favouritesErrorMessage: String?

    @Published var isLoadingNews: Bool = false
    @Published var newsErrorMessage: String?

    private let stockService = StockService()
    private let newsService = NewsService()

    func fetchFavouriteStockDetails(favouriteTickers: [String]) async {
        guard !favouriteTickers.isEmpty else {
            self.favouriteStocks = []
            return
        }

        isLoadingFavourites = true
        favouritesErrorMessage = nil

        let fetchedStocks = await stockService.fetchDetails(forTickers: favouriteTickers)
        
        self.favouriteStocks = fetchedStocks.filter { stock in
            return stock.companyName != "Name lookup failed" && stock.companyName != "Name not found"
        }.sorted { $0.ticker < $1.ticker }

        if self.favouriteStocks.count < favouriteTickers.count {
            self.favouritesErrorMessage = "Could not load details for all favourite stocks."
        } else if self.favouriteStocks.contains(where: { $0.currentPrice == nil && $0.companyName != "Name lookup failed" && $0.companyName != "Name not found" }) {
            self.favouritesErrorMessage = "Some price data for favourite stocks might be unavailable."
        }
        
        isLoadingFavourites = false
    }
    
    func fetchLatestNews(ticker: String) async {
        isLoadingNews = true
        newsErrorMessage = nil
        latestNews = []

        do {
            let news = try await newsService.fetchNews(for: ticker)
            self.latestNews = news
        } catch let error as URLError where error.code == .cancelled {
            print("News fetching cancelled for ticker: \(ticker)")
        } catch {
            print("Error in fetching news for ticker \(ticker): \(error)")
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    self.newsErrorMessage = "No internet connection. Please check your connection and try again."
                case .timedOut:
                    self.newsErrorMessage = "The request timed out. Please try again."
                case .badServerResponse:
                    self.newsErrorMessage = "Could not fetch news at this time. Please try again later."
                default:
                    self.newsErrorMessage = "An error occurred while fetching news. Please try again."
                }
            } else {
                self.newsErrorMessage = "An unexpected error occurred while fetching news."
            }
        }
        isLoadingNews = false
    }
}
