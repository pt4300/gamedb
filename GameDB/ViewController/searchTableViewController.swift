//
//  searchTableViewController.swift
//  GameDB
//
//  Created by Yuting Yu on 11/6/21.
//

import UIKit

class searchTableViewController: UITableViewController,UISearchBarDelegate {
    var indicator = UIActivityIndicatorView()
    var games:[GameData] = []
    var apiController:ApiController?
    override func viewDidLoad() {
        apiController = ApiController()
        super.viewDidLoad()
        
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController


        
        //ensure search bar is alwasy visble
        navigationItem.hidesSearchBarWhenScrolling = false
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)

        
        NSLayoutConstraint.activate([indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // using default cell here to avoid 429 error. All cover image require single request to fetch for every game. Not ideal under search view
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCell", for: indexPath)
        cell.textLabel?.text = games[indexPath.row].name
        return cell
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text == ""{
            // clean table view once user press cancel
            games.removeAll()
            tableView.reloadData()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        games.removeAll()
        // remove the no results section

        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // clean the meals before next fetch
        games.removeAll()
        // no results section start loading after first search clicked
        tableView.reloadData()
        indicator.startAnimating()
        if let searchText = searchBar.text,searchText != ""{
            apiController?.fetchIGDBAuthCode(completeHandler: {
                self.apiController?.searchIGDBGame(name: searchText, completeHandler: { (games) in
                    self.games = games
                    self.tableView.reloadData()
                    self.indicator.stopAnimating()
                })
            })

        }else{
            indicator.stopAnimating()
        }
    }



    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if segue.identifier == "searchSegue"{
            // the seguge way pass the releated information to the game detailed view. all segue for favorite/wishlist/game table view share same detail view list
            if let cell = sender as? UITableViewCell{
                
                let indexPath = tableView.indexPath(for: cell)
                let destination = segue.destination as! GameDetailViewController
                destination.name = self.games[indexPath!.row].name
                let date = NSDate(timeIntervalSince1970: TimeInterval(self.games[indexPath!.row].first_release_date!))
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                let releaseDate = df.string(for:date)
                destination.release = releaseDate
                destination.summary = self.games[indexPath!.row].summary
                destination.currentGameData = self.games[indexPath!.row]

                
                
                
            }
        }
    }
    

}
