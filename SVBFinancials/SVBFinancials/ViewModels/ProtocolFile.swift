//
//  ProtocolFile.swift
//  SVB-App
//
//  Created by Tomi Nguyen on 12/5/2025.
//

import Foundation
import Combine

protocol FavouriteProviding {
    func getFavouriteTickers() -> [String]
}

protocol FavouriteActionHandling: AnyObject {
    func toggleFavourite(ticker:String)
    
}
