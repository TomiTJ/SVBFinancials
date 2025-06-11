//
//  NewsService.swift
//  SVB-App
//
//  Created by Tien Dung Vu on 11/5/2025.
//

import Foundation

class NewsService {
    func fetchNews(for ticker: String) async throws -> [NewsArticle] {
        let urlString = "https://api.polygon.io/v2/reference/news?ticker=\(ticker)&apiKey=\(Secrets.apiKey)"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            let decodedResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
            return decodedResponse.results
        } catch {
            throw error
        }
    }
}

struct NewsResponse: Decodable {
    let results: [NewsArticle]
}
