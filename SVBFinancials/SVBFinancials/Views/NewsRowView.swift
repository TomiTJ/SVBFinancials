//
//  NewsRowView.swift
//  SVB-App
//
//  Created by Tien Dung Vu on 11/5/2025.
//

import SwiftUI

struct NewsRowView: View {
    let article: NewsArticle
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .center, spacing: 8) {

            if let imageUrl = article.imageURL, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    Color.themeBackground.frame(height: 150)
                }
            }

            // Article title
            Text(article.title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)

            // Summary of the article
            if let summary = article.summary {
                Text(summary)
                    .font(.subheadline)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            // Published date
            Text("Published: \(article.publishedUTC)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 8)
        .onTapGesture {
            if let url = URL(string: article.articleURL) {
                openURL(url)
            }
        }
    }
}
