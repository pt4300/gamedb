//
//  myFavoriteTableViewController.swift
//  GameDB
//
//  Created by Yuting Yu on 3/5/21.
//

import UIKit

class myFavoriteTableViewController: UITableViewController {
    
    var favoriteGames:[GameData] = []
    var listenerType: ListenerType = .favoriteGame
    weak var databaseController: DatabaseProtocol?
    let FAVORITE_GAME_CELL = "favoriteCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favoriteGames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FAVORITE_GAME_CELL, for: indexPath)
        cell.textLabel?.text = favoriteGames[indexPath.row].name

        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            databaseController?.deleteFavoriteGame(game: favoriteGames[indexPath.row])
            favoriteGames.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favoriteGameSegue"{
            // the seguge way pass the releated information to the game detailed view. all segue for favorite/wishlist/game table view share same detail view list
            if let cell = sender as? UITableViewCell{
                
                let indexPath = tableView.indexPath(for: cell)
                let destination = segue.destination as! GameDetailViewController
                destination.name = self.favoriteGames[indexPath!.row].name
                let date = NSDate(timeIntervalSince1970: TimeInterval(self.favoriteGames[indexPath!.row].first_release_date!))
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                let releaseDate = df.string(for:date)
                destination.release = releaseDate
                destination.summary = self.favoriteGames[indexPath!.row].summary
                destination.currentGameData = self.favoriteGames[indexPath!.row]

                
                
                
            }
        }
        

        
    }
    

}


extension myFavoriteTableViewController:DatabaseListener{
    func onFavorite(change: DatabaseChange, games: [GameData]) {
        favoriteGames = games
        tableView.reloadData()
    }
    
    func onWishListChange(change: DatabaseChange, games: [GameData]) {
        //
    }
    
    
}
