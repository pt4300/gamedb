//
//  FirebaseController.swift
//  GameDB
//
//  Created by Yuting Yu on 3/5/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject {
    var listeners = MulticastDelegate<DatabaseListener>()
    var favoriteGameList:[GameData]
    var wishlist:[GameData]
    var database:Firestore
    var favoritesGameRef:CollectionReference?
    var wishlistRef:CollectionReference?
    var userID:String?
    var authController:Auth
    var userReference:CollectionReference
    
    // this two array is used to check duplicates. because firebase checking after the button is pressed, this two list can be saved in user defaults so it can be checked in prior.
    var wishlistID:[Int] = []
    var favoritesID:[Int] = []
    override init(){
        FirebaseApp.configure()
        database = Firestore.firestore()
        userReference = database.collection("users")
        favoriteGameList = [GameData]()
        wishlist = [GameData]()
        authController = Auth.auth()
        super.init()

        Database.database().isPersistenceEnabled = true
        if let currentUser = authController.currentUser{

            self.userID = currentUser.uid
            // the account needs to be setup at beginning, the setup for wishlist/favorite game also part of it
            self.setUpAccount()
        }
        

    }
    

    
    func setUpFavoritesGameListener(){
        // the setup function for favorites game listener
        favoritesGameRef = self.userReference.document("\(userID!)").collection("favoriteGames")
        favoritesGameRef?.addSnapshotListener(){ (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else{
                print("failed to fetch documents with error \(String(describing: error))")
                return
            }
            self.parseFavoriteGamesSnapshot(snapshot: querySnapshot)
            // To save the id of wishlist/favorite games in here for duplicate prevention check
            for item in self.favoriteGameList{
                // id is exist in any game that with a name. So all game inside favorite/wish list must have id, force unwrap here wont raise crash
                self.favoritesID.append(item.id!)
            }
            //reference thanks to hacking with swift, https://www.hackingwithswift.com/example-code/system/how-to-save-user-settings-using-userdefaults
            // the saved id is used to prevent duplicate, its more efficent compare to do check in firebase.
            let defaults = UserDefaults.standard
            defaults.set(self.favoritesID,forKey:"favoritesID")
            
            
        }
        
    }
    func setUpWishlistListener(){
        

        wishlistRef = self.userReference.document("\(userID!)").collection("wishList")
        wishlistRef?.addSnapshotListener(){ (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else{
                print("failed to fetch documents with error \(String(describing: error))")
                return
            }
            self.parseWishlistSnapshot(snapshot: querySnapshot)

            // To save the id of wishlist/favorite games in here for duplicate prevention check
            for item in self.wishlist{
                // id is exist in any game that with a name. So all game inside favorite/wish list must have id, force unwrap here wont raise crash
                self.wishlistID.append(item.id!)
            }
            //reference thanks to hacking with swift, https://www.hackingwithswift.com/example-code/system/how-to-save-user-settings-using-userdefaults
            // the saved id is used to prevent duplicate, its more efficent compare to do check in firebase.
            let defaults = UserDefaults.standard
            defaults.set(self.wishlistID,forKey:"wishlistID")


            
            
        }
        
    }
    
    
    func parseWishlistSnapshot(snapshot:QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            var parsedGame:GameData?
            do{
                parsedGame = try change.document.data(as: GameData.self)
            }catch{
                print("unabled to decode game. is the game malformed???")
                return
            }
            guard let game = parsedGame else{
                print("document doesn't exist")
                return
            }
            if change.type == .added{
                wishlist.insert(game, at: Int(change.newIndex))
                // if game exits, id always exist, however some game is blank return so it wont able to be added in wishlist
                wishlistID.insert(game.id!, at: Int(change.newIndex))
                
            }
            else if change.type == .modified{
                // this is leaved for future implmentation, not using at current build
                wishlist[Int(change.oldIndex)] = game
            }
            else if change.type == .removed{
                wishlist.remove(at: Int(change.oldIndex))
                wishlistID.remove(at: Int(change.oldIndex))

            }
            
            listeners.invoke { (listener) in
                if listener.listenerType == .wishList || listener.listenerType == .all
                {
                    listener.onWishListChange(change: .update, games: wishlist)
                }
            }
        }
        
    }
    func parseFavoriteGamesSnapshot(snapshot:QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            var parsedGame:GameData?
            do{
                parsedGame = try change.document.data(as: GameData.self)
            }catch{
                print("unabled to decode game. is the game malformed???")
                return
            }
            guard let game = parsedGame else{
                print("document doesn't exist")
                return
            }
            if change.type == .added{
                print(game.fireStoreId)
                favoriteGameList.insert(game, at: Int(change.newIndex))
                // if game exits, id always exist, however some game is blank return so it wont able to be added in wishlist
                favoritesID.insert(game.id!, at: Int(change.newIndex))

                
            }
            else if change.type == .modified{
                favoriteGameList[Int(change.oldIndex)] = game
            }
            else if change.type == .removed{
                favoriteGameList.remove(at: Int(change.oldIndex))
                favoritesID.remove(at: Int(change.oldIndex))
            }
            
            listeners.invoke { (listener) in
                if listener.listenerType == .favoriteGame || listener.listenerType == .all
                {
                    listener.onFavorite(change: .update, games: favoriteGameList)
                }
            }
        }
    }
    
    
}

extension FirebaseController:DatabaseProtocol{
    func addWishListGame(game: GameData) -> GameData {
        let input = game
            do{
                if let wishRef = try wishlistRef?.addDocument(from: input){
                    wishRef.updateData(["firestoreId" : "\(wishRef.documentID)"])
                }
                
                
            }catch{
                print("failed to serialize favorite game")
            }
        
        

        return input
    }
    
    func addFavoriteGame(game:GameData) -> GameData {
        let input = game
            do{
                if let favoriteRef = try favoritesGameRef?.addDocument(from: input){
                    favoriteRef.updateData(["firestoreId" : "\(favoriteRef.documentID)"])
                    input.fireStoreId = favoriteRef.documentID
                    
                    
                }
                
                
            }catch{
                print("failed to serialize favorite game")
            }
        
        

        return input
    }
    
    func deleteFavoriteGame(game: GameData) {
        // both deleting function is not working due to the decoding of firestore id is broken. WIP bug fix
        
        if let gameID = game.fireStoreId{
            favoritesGameRef?.document(gameID).delete()
        }
    }
    
    func deleteWishlistGame(game: GameData) {
        if let gameID = game.fireStoreId{
            wishlistRef?.document(gameID).delete()
        }
    }
    
    

    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .favoriteGame || listener.listenerType == .all{
            listener.onFavorite(change: .update, games: favoriteGameList)
        }
        else if listener.listenerType == .wishList || listener.listenerType == .all
        {
            listener.onWishListChange(change: .update, games: wishlist)
        }
        
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    func setUpAccount()->Bool {
        guard let ID = Auth.auth().currentUser?.uid else{
            // this is used when the user sign out, empty favorite gamelist and wishlist
            favoriteGameList = []
            wishlist = []
            return false
        }
        self.userID = ID
        self.setUpFavoritesGameListener()
        self.setUpWishlistListener()
        
        return true
        
    }
    
}
