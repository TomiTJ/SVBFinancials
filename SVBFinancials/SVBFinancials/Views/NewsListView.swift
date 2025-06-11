//
//  NewsListView.swift
//  SVB-App
//
//  Created by Tien Dung Vu on 12/5/2025.
//

import SwiftUI

struct NewsListView: View {
    @ObservedObject var viewModel: StockDetailViewModel
    
    var body: some View {
        Group {
            if viewModel.isLoadingNews {
                LoadingView()
            } else if let error = viewModel.newsError {
                ErrorView(
                    message: "Failed to load news: \(error.localizedDescription)",
                    retryAction: {
                        Task {
                            await viewModel.loadNews()
                        }
                    }
                )
            } else if viewModel.news.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.themeBackground)
                    Text("No news found!")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.news) { article in
                        NewsRowView(article: article)
                            .listRowBackground(Color.themeBackground)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.themeBackground)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadNews()
            }
        }
    }
}
