//
//  DatabaseProtocol.swift
//  GameDB
//
//  Created by Yuting Yu on 3/5/21.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case favoriteGame
    case wishList
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onFavorite(change: DatabaseChange, games: [GameData])
    func onWishListChange(change: DatabaseChange, games: [GameData])
}

protocol DatabaseProtocol: AnyObject {
        
    func setUpAccount()->Bool
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addFavoriteGame(game:GameData) -> GameData
    func addWishListGame(game:GameData)-> GameData
    func deleteFavoriteGame(game:GameData)
    func deleteWishlistGame(game:GameData)
}
