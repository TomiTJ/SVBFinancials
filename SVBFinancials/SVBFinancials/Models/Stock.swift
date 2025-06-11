//
//  Stock.swift
//
// represent a stock, properties populated from polygons API
import Foundation

struct Stock: Identifiable, Decodable {
    let id: String // the stocks ticker will be the ID
    let ticker: String
    let companyName: String
    var currentPrice: Double?     // will be the previous days close price
    var priceChange: Double?      // change from previous days open to its close
    var priceChangePercent: Double? // percentage change from previous day's open to its close
    var isFavorite: Bool = false

    //for when data is combined from multiple API calls
    init(id: String? = nil, ticker: String, companyName: String, currentPrice: Double? = nil, priceChange: Double? = nil, priceChangePercent: Double? = nil, isFavorite: Bool = false) {
        self.id = id ?? ticker
        self.ticker = ticker
        self.companyName = companyName
        self.currentPrice = currentPrice
        self.priceChange = priceChange
        self.priceChangePercent = priceChangePercent
        self.isFavorite = isFavorite
    }
    
    enum CodingKeys: String, CodingKey {
        case ticker
        case companyName = "name"
    }
    
     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ticker = try container.decode(String.self, forKey: .ticker)
        companyName = try container.decode(String.self, forKey: .companyName)
        id = ticker // assign ticker to id as a default

        // these will be nil or defaultas they are not in the primary decoding path for this init
        currentPrice = nil
        priceChange = nil
        priceChangePercent = nil
        isFavorite = false
    }
}


// for ticker Search/v3/reference/tickers
struct PolygonTickerSearchResponse: Decodable {
    let results: [PolygonTicker]?
    let status: String?
    let requestId: String?
    let count:   Int?

    enum CodingKeys: String, CodingKey {
        case results, status
        case requestId = "request_id"
        case count
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        results = try container.decodeIfPresent([PolygonTicker].self, forKey: .results)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        requestId = try container.decodeIfPresent(String.self, forKey: .requestId)
        count = try container.decodeIfPresent(Int.self, forKey: .count)
    }
}

struct PolygonTicker: Decodable, Identifiable {
    // this acts as a disting uuid for our app, distinct from the stocks actual ticker
    let id = UUID()
    let ticker: String
    let name: String
    let market: String?
    let locale: String?
    let primaryExchange: String?
    let type: String?
    let active: Bool?
    let currencyName: String?
    // let cik: String?
    // let compositeFigi: String?
    // let shareClassFigi: String?
    let lastUpdatedUTC: String?

    enum CodingKeys: String, CodingKey {
        case ticker, name, market, locale, type, active
        case primaryExchange = "primary_exchange"
        case currencyName = "currency_name"
        // case cik
        // case compositeFigi = "composite_figi"
        // case shareClassFigi = "share_class_figi"
        case lastUpdatedUTC = "last_updated_utc"
    }
}

// for prev day close /v2/aggs/ticker/{stocksTicker}/prev
struct PolygonPrevDayCloseResponse: Decodable {
    let ticker: String?
    let status: String?
    // let queryCount: Int?
    let resultsCount: Int?
    // let adjusted: Bool?
    let results: [PolygonPrevDayData]?
}

struct PolygonPrevDayData: Decodable {
    let openPrice: Double         // o
    let highPrice: Double         // h
    let lowPrice: Double          // l
    let closePrice: Double        // c
    let volume: Double?           // v
    let volumeWeightedAveragePrice: Double? // vw, not actually sure what this is lol
    // let transactions: Int?     // n, number of transactions
    // let timestamp: Int?       // t

    enum CodingKeys: String, CodingKey {
        case openPrice = "o"
        case highPrice = "h"
        case lowPrice = "l"
        case closePrice = "c"
        case volume = "v"
        case volumeWeightedAveragePrice = "vw"
        // case timestamp = "t"
        // case transactions = "n"
    }
}

struct StockBar: Identifiable, Decodable {
    let id = UUID()
    let o: Double // open
    let h: Double // high
    let l: Double // low
    let c: Double // close
    let t: TimeInterval // timestamp

    enum CodingKeys: String, CodingKey {
        case o, h, l, c, t
    }
}

struct AggregateResponse: Decodable {
    let results: [StockBar]?
}
