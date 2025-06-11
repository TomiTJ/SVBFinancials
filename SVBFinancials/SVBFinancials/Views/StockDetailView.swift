//  StockDetailView.swift
//  SVB-App
//
//  Created by Tien Dung Vu on 11/5/2025.
//

import SwiftUI
import SwiftData
import Charts

enum ChartPeriod: CaseIterable, Identifiable {
    case sevenDay, oneMonth, sixMonth, oneYear, fiveYear
    var id: Self { self }
    var title: String {
        switch self {
        case .sevenDay: return "7D"
        case .oneMonth: return "1M"
        case .sixMonth: return "6M"
        case .oneYear: return "1Y"
        case .fiveYear: return "5Y"
        }
    }
    var components: DateComponents {
        switch self {
        case .sevenDay:  return DateComponents(day: -7)
        case .oneMonth:  return DateComponents(month: -1)
        case .sixMonth:  return DateComponents(month: -6)
        case .oneYear:   return DateComponents(year: -1)
        case .fiveYear:  return DateComponents(year: -5)
        }
    }
}

struct StockDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: StockDetailViewModel
    @EnvironmentObject private var favourites: FavouriteViewModel
    @Environment(\.modelContext) private var context
    
    @State private var selectedTab = 0
    @State private var selectedPeriod: ChartPeriod = .oneMonth
    
    init(stock: Stock) {
        _viewModel = StateObject(wrappedValue: StockDetailViewModel(stock: stock))
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(spacing: 8) {
                    Text(viewModel.stock.ticker)
                        .font(.title2).bold()
                        .foregroundColor(.themePrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(viewModel.stock.companyName)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Button {
                    favourites.toggleFavourite(ticker: viewModel.stock.ticker)
                } label: {
                    let isFav = favourites.isFavourite(ticker: viewModel.stock.ticker)
                    Image(systemName: isFav ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundColor(isFav ? .yellow : .themeText)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal)
            
            HStack(spacing: 0) {
                ForEach(0..<3) { idx in
                    let titles = ["Info","News","Alerts"]
                    Button(action: { selectedTab = idx }) {
                        Text(titles[idx])
                            .font(.subheadline).bold()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedTab == idx
                                        ? Color.themePrimary
                                        : Color.themeSecondary)
                            .foregroundColor(selectedTab == idx
                                             ? .white
                                             : .themeText)
                    }
                }
            }
            .background(Color.themeSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding()
            
            Divider()
            
            Group {
                switch selectedTab {
                case 0: infoTab
                case 1: NewsListView(viewModel: viewModel)
                case 2:
                    AlertConfigView(
                        ticker: viewModel.stock.ticker,
                        companyName: viewModel.stock.companyName,
                        currentPrice: viewModel.stock.currentPrice,
                        context: context
                    )
                default: EmptyView()
                }
            }
            .padding()
            .animation(.easeInOut, value: selectedTab)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.themePrimary)
                }
            }
        }
        .task {
            let now = Date()
            let from = Calendar.current.date(byAdding: selectedPeriod.components, to: now) ?? now
            await viewModel.loadNews()
            await viewModel.loadBars(from: from, to: now)
        }
        .onChange(of: selectedPeriod) { _, new in
            let now = Date()
            let from = Calendar.current.date(byAdding: new.components, to: now) ?? now
            Task { await viewModel.loadBars(from: from, to: now) }
        }
    }
    
    var infoTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Current Price:")
                    .font(.headline)
                Spacer()
                if let price = viewModel.stock.currentPrice {
                    Text("$\(price, specifier: "%.2f")")
                        .bold().foregroundColor(.primary)
                } else {
                    Text("N/A").foregroundColor(.themeText)
                }
            }
            HStack {
                Text("Change:")
                    .font(.headline)
                    .foregroundColor(.themeText)
                Spacer()
                if let pct = viewModel.stock.priceChangePercent {
                    let val = pct * 100
                    let sign = val >= 0 ? "+" : "–"
                    let fmt = String(format: "%.2f", abs(val))
                    Text("\(sign)\(fmt)%")
                        .foregroundColor(val >= 0 ? .themeAccent : .red)
                } else {
                    Text("N/A").foregroundColor(.themeText)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ChartPeriod.allCases) { p in
                        Button(p.title) { selectedPeriod = p }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(selectedPeriod == p
                                        ? Color.themePrimary.opacity(0.2)
                                        : .clear)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .foregroundColor(.themePrimary)
            }
            if let bars = viewModel.bars {
                Chart {
                    ForEach(bars) { b in
                        let date = Date(timeIntervalSince1970: b.t/1000)
                        AreaMark(x: .value("Date", date),
                                 y: .value("Close", b.c))
                        .foregroundStyle(Color.themePrimary.opacity(0.2))
                        LineMark(x: .value("Date", date),
                                 y: .value("Close", b.c))
                        .foregroundStyle(Color.themePrimary)
                    }
                }
                .chartXAxis { AxisMarks(values: .automatic) }
                .chartYAxis { AxisMarks(position: .leading) }
                .frame(height: 200)
                .cornerRadius(8)
            } else if viewModel.isLoadingBars {
                ProgressView().frame(height: 200)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Text("Unable to load chart")
                            .font(.caption)
                            .foregroundColor(.themeText)
                            .multilineTextAlignment(.center)
                            .padding()
                    )
                    .cornerRadius(8)
            }
        }
    }
}
