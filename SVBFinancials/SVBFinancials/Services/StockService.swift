//
//  NetworkManager.swift
//  SVB-App
//
//  Created by Ali bonagdaran on 9/5/2025.
//
// fetches stock data from polygons API
import Foundation

class StockService {
    private let networkManager = NetworkManager.shared
    private let apiKey = Secrets.apiKey
    private let polygonBaseURL = "https://api.polygon.io"
    
    enum ServiceError: Error {
        case urlConstructionFailed
        case noPriceDataFound(ticker: String)
        case underlyingError(Error)
        case apiKeyMissing
    }
    
    // searches for the ticker and previous days price.
    // returns an array of Stock object with price info
    // takes a query as its paramater e.g. apple or APPL
    func searchStocks(query: String) async throws -> [Stock] {
        
        let polygonTickers: [PolygonTicker]
        do {
            polygonTickers = try await fetchMatchingTickers(query: query)
        } catch {
            print("problem finding tickers that match the query: '\(query)': \(error)")
            throw error
        }
        
        guard !polygonTickers.isEmpty else {
            return []
        }
        
        var stocks: [Stock] = []
        
        // concurrently fetch previous days price details for each ticker
        try await withThrowingTaskGroup(of: Stock.self) { group in
            for pt in polygonTickers {
                group.addTask {
                    let prevDayData = await self.fetchPreviousDayDetails(
                        for: pt.ticker
                    )
                    if let data = prevDayData {
                        let currentPrice = data.closePrice
                        let openPrice = data.openPrice
                        let priceChange = currentPrice - openPrice
                        let priceChangePercent =
                        openPrice == 0 ? 0 : (priceChange / openPrice)
                        return Stock(
                            ticker: pt.ticker,
                            companyName: pt.name,
                            currentPrice: currentPrice,
                            priceChange: priceChange,
                            priceChangePercent: priceChangePercent
                        )
                    } else {
                        print("price info not avaliable for \(pt.ticker). basic info shown only")
                        return Stock(ticker: pt.ticker, companyName: pt.name)
                    }
                }
            }
            
            for try await stock in group {
                stocks.append(stock)
            }
        }
        
        return stocks
    }
    
    // fetches a list of tickers and companiy info matching the query string
    func fetchMatchingTickers(query: String) async throws -> [PolygonTicker] {
        let encodedQuery =
        query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        ?? ""
        guard
            let url = URL(
                string:
                    "\(polygonBaseURL)/v3/reference/tickers?search=\(encodedQuery)&active=true&limit=50&apiKey=\(apiKey)"
            )
        else {
            throw ServiceError.urlConstructionFailed
        }
        let response: PolygonTickerSearchResponse =
        try await networkManager.fetchData(from: url)
        return response.results ?? []
    }
    
    // getches the previous days open, high, low and close data for the ticker
    // returns: PolygonPrevDayData or nil if somethings gone wrong
    // takes the ticker symbol as its paramater
    private func fetchPreviousDayDetails(for tickerSymbol: String) async -> PolygonPrevDayData? {
        guard
            let url = URL(
                string:
                    "\(polygonBaseURL)/v2/aggs/ticker/\(tickerSymbol)/prev?apiKey=\(apiKey)"
            )
        else {
            print( "failed to make the url to fetch previous day data for \(tickerSymbol)")
            return nil
        }
        
        do {
            let response: PolygonPrevDayCloseResponse =
            try await networkManager.fetchData(from: url)
            return response.results?.first
        } catch {
            print("something went wrong fetching the previous days data for ticker: \(tickerSymbol): \(error)"
            )
            if let networkError = error as? NetworkManager.NetworkError {
                print("network or api error for \(tickerSymbol): \(networkError)"
                )
            }
            return nil
        }
    }
    
    func fetchDetails(forTickers tickers: [String]) async -> [Stock] {
        guard !tickers.isEmpty else {
            return []
        }
        
        var detailedStocks: [Stock] = []
        
        await withTaskGroup(of: Stock?.self) { group in
            for tickerSymbol in tickers {
                group.addTask {
                    guard
                        let polygonTicker =
                            await self.fetchSingleTickerReference(
                                tickerSymbol: tickerSymbol
                            )
                    else {
                        print("Could not obtain name from API for: \(tickerSymbol).")
                        return Stock(
                            ticker: tickerSymbol,
                            companyName: "[Error] Name lookup failed"
                        )
                    }
                    
                    guard
                        let prevDayData = await self.fetchPreviousDayDetails(
                            for: polygonTicker.ticker
                        )
                    else {
                        print("price info not avaliable for \(polygonTicker.ticker). basic info shown only")
                        return Stock(
                            ticker: polygonTicker.ticker,
                            companyName: polygonTicker.name
                        )
                    }
                    
                    let currentPrice = prevDayData.closePrice
                    let openPrice = prevDayData.openPrice
                    let priceChange = currentPrice - openPrice
                    let priceChangePercent =
                    openPrice == 0 ? 0 : (priceChange / openPrice)
                    
                    return Stock(
                        ticker: polygonTicker.ticker,
                        companyName: polygonTicker.name,
                        currentPrice: currentPrice,
                        priceChange: priceChange,
                        priceChangePercent: priceChangePercent
                    )
                }
            }
            
            for await stockResult in group {
                if let stock = stockResult {
                    detailedStocks.append(stock)
                }
            }
        }
        return detailedStocks
    }
    
    func fetchBars(for ticker: String, from: Date, to: Date) async throws -> [StockBar] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fromStr = formatter.string(from: from)
        let toStr = formatter.string(from: to)
        guard let url = URL(string: "\(polygonBaseURL)/v2/aggs/ticker/\(ticker)/range/1/day/\(fromStr)/\(toStr)?sort=asc&limit=500&apiKey=\(apiKey)") else {
            throw ServiceError.urlConstructionFailed
        }
        let response: AggregateResponse = try await networkManager.fetchData(from: url)
        return response.results ?? []
    }
    
    // Toms code
    func fetchSingleTickerReference(tickerSymbol: String) async -> PolygonTicker? {
        struct SingleTickerLookupResponse: Decodable {
            let results: PolygonTicker?
            let status: String?
        }
        
        guard
            let url = URL(
                string:
                    "\(polygonBaseURL)/v3/reference/tickers/\(tickerSymbol)?apiKey=\(self.apiKey)"
            )
        else {
            print("failed to construct url: \(tickerSymbol)")
            return nil
        }
        
        do {
            let response: SingleTickerLookupResponse =
            try await networkManager.fetchData(from: url)
            if response.status == "OK" {
                return response.results
            } else {
                print("rare error: \(tickerSymbol): \(response.status ?? "Unknown")")
                return nil
            }
        } catch let error as NetworkManager.NetworkError {
            print("Network or API error for: \(tickerSymbol): \(error)")
            return nil
        } catch {
            print("catch all error: \(tickerSymbol): \(error)")
            return nil
        }
    }
}

