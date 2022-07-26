//
//  wishlistTableViewController.swift
//  GameDB
//
//  Created by Yuting Yu on 11/6/21.
//

import UIKit

class wishlistTableViewController: UITableViewController {

    
    var wishlist:[GameData] = []
    var listenerType: ListenerType = .wishList
    weak var databaseController: DatabaseProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        return wishlist.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishlistCell", for: indexPath)
        cell.textLabel?.text = wishlist[indexPath.row].name

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
            // deletion process is bugged at moment because the firebase id cannot be decode properly from codable object. detail explainantion please check the gamedata.swift
            databaseController?.deleteFavoriteGame(game: wishlist[indexPath.row])
            wishlist.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    

    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "wishlistSegue"{
            // the seguge way pass the releated information to the game detailed view. all segue for favorite/wishlist/game table view share same detail view list
            if let cell = sender as? UITableViewCell{
                
                let indexPath = tableView.indexPath(for: cell)
                let destination = segue.destination as! GameDetailViewController
                destination.name = self.wishlist[indexPath!.row].name
                let date = NSDate(timeIntervalSince1970: TimeInterval(self.wishlist[indexPath!.row].first_release_date!))
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                let releaseDate = df.string(for:date)
                destination.release = releaseDate
                destination.summary = self.wishlist[indexPath!.row].summary
                destination.currentGameData = self.wishlist[indexPath!.row]

                
                
                
            }
        }
    }
    

}

extension wishlistTableViewController:DatabaseListener{
    func onFavorite(change: DatabaseChange, games: [GameData]) {
            //
        
    }
    
    func onWishListChange(change: DatabaseChange, games: [GameData]) {
        wishlist = games
        tableView.reloadData()
    }
}
