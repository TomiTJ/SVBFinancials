//
//  StockDetailViewModel.swift
//  SVB-App
//
//  Created by Tien Dung Vu on 11/5/2025.
//

import Foundation

@MainActor
class StockDetailViewModel: ObservableObject {
    let stock: Stock

    @Published var news: [NewsArticle] = []
    @Published var isLoadingNews = false
    @Published var newsError: Error?
    @Published var bars: [StockBar]? = nil
    @Published var isLoadingBars = false
    @Published var barsError: Error?

    private let newsService = NewsService()
    private let stockService = StockService()

    init(stock: Stock) {
        self.stock = stock
    }

    func loadNews() async {
        isLoadingNews = true
        newsError = nil
        do {
            let fetched = try await newsService.fetchNews(for: stock.ticker)
            news = fetched
        } catch {
            newsError = error
        }
        isLoadingNews = false
    }

    func loadBars(from: Date, to: Date) async {
        isLoadingBars = true
        barsError = nil
        do {
            let fetched = try await stockService.fetchBars(for: stock.ticker, from: from, to: to)
            bars = fetched
        } catch {
            barsError = error
        }
        isLoadingBars = false
    }
}
