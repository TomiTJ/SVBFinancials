//
//  NewsArticle.swift
//
// NewsArticle.swift

import Foundation

struct NewsArticle: Identifiable, Decodable {
    let id = UUID() // local ID
    let title: String
    let author: String?
    let publishedUTC: String
    let articleURL: String
    let imageURL: String?
    let summary: String?

    enum CodingKeys: String, CodingKey {
        case title
        case author
        case publishedUTC = "published_utc"
        case articleURL = "article_url"
        case imageURL = "image_url"
        case summary
    }
}
