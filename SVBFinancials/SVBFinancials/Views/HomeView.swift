//  HomeView.swift
//  SVB-App
//
//  Created by Tomi Nguyen on 15/5/2025.

import SwiftUI

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @EnvironmentObject private var favouriteViewModel: FavouriteViewModel
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                NavigationLink(destination: SearchView()) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("Search for stocks")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top)
                }
                
                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Favourites")
                                .font(.title2).bold()
                                .foregroundColor(.themePrimary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 5)
                        
                        if homeViewModel.isLoadingFavourites {
                            ProgressView("Loading Favourites...")
                                .padding()
                                .foregroundColor(.themePrimary)
                                .frame(maxWidth: .infinity, minHeight: 100)
                            
                        } else if let errorMessage = homeViewModel.favouritesErrorMessage {
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title)
                                Text(errorMessage)
                                    .foregroundColor(.secondary)
                                    .font(.callout)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                Button("Retry") {
                                    Task {
                                        await homeViewModel.fetchFavouriteStockDetails(favouriteTickers: favouriteViewModel.getFavouriteTickers())
                                    }
                                }
                                .buttonStyle(.bordered)
                                .padding(.top, 5)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 100)
                            
                        } else if homeViewModel.favouriteStocks.isEmpty {
                            Text("No favourites added yet.\nSearch for a stock and tap the star to add it to your watchlist.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 100)
                            
                        } else {
                            VStack(spacing: 0) {
                                ForEach(homeViewModel.favouriteStocks) { stock in
                                    NavigationLink(
                                        destination: StockDetailView(stock: stock)
                                            .environmentObject(favouriteViewModel)
                                    ) {
                                        FavouriteStockRowView(stock: stock)
                                    }
                                    Divider()
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider().padding(.vertical, 10)
                        
                        HStack {
                            Text("Latest News")
                                .font(.title2).bold()
                                .foregroundColor(.themePrimary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                        
                        if homeViewModel.isLoadingNews {
                            ProgressView("Loading News...")
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 100)
                        } else if let errorMessage = homeViewModel.newsErrorMessage {
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title)
                                Text(errorMessage)
                                    .foregroundColor(.secondary)
                                    .font(.callout)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                Button("Retry News") {
                                    Task {
                                        let ticker = homeViewModel.favouriteStocks.first?.ticker ?? "SPY"
                                        await homeViewModel.fetchLatestNews(ticker: ticker)
                                    }
                                }
                                .buttonStyle(.bordered)
                                .padding(.top, 5)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 100)
                        } else if homeViewModel.latestNews.isEmpty {
                            Text("No news available at the moment.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 100)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(homeViewModel.latestNews) { article in
                                    NewsRowView(article: article)
                                    Divider().padding(.horizontal)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                }
                
                Spacer()
                
                HStack {
                    TabBarButton(iconName: "house.fill", text: "Home", isSelect: selectedTab == 0) {
                        selectedTab = 0
                    }
                    Spacer()
                    TabBarButton(iconName: "star.fill", text: "Watchlist", isSelect: selectedTab == 1) {
                        selectedTab = 1
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first?.windows.first?.safeAreaInsets.bottom == 0 ? 10 : 0)
                .padding(.top, 10)
                .background(Color(.systemGray6).edgesIgnoringSafeArea(.bottom))
            }
            .navigationTitle("Home")
            .navigationBarHidden(true)
            .onAppear {
                let favs = favouriteViewModel.getFavouriteTickers()
                Task {
                    await homeViewModel.fetchFavouriteStockDetails(favouriteTickers: favs)
                    let ticker = favs.first ?? "SPY"
                    await homeViewModel.fetchLatestNews(ticker: ticker)
                }
            }
            .onChange(of: favouriteViewModel.favouriteTickers) { old, new in
                Task {
                    await homeViewModel.fetchFavouriteStockDetails(favouriteTickers: Array(new))
                    let ticker = new.first ?? "SPY"
                    await homeViewModel.fetchLatestNews(ticker: ticker)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let favVM = FavouriteViewModel()
        let homeVM = HomeViewModel()
        favVM.toggleFavourite(ticker: "AAPL")
        favVM.toggleFavourite(ticker: "MSFT")
        return HomeView()
            .environmentObject(favVM)
            .environmentObject(homeVM)
            .previewDevice("iPhone 15 Pro")
    }
}
