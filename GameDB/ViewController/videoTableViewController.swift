//
//  videoTableViewController.swift
//  GameDB
//
//  Created by Yuting Yu on 11/6/21.
//

import UIKit

class videoTableViewController: UITableViewController {
    
    var games:[GameData] = []
    var apiController: ApiController?
    var indicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        apiController = ApiController()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
        apiController?.fetchIGDBAuthCode(){
            // the first completion handler is used to begin fetch game after obatin auth code
            self.apiController?.fetchIGDBGames(platform: 48, completeHandler: { (gamedata) in
                self.indicator.startAnimating()
                // the game fetching also include cover image/ screenshots url fetch process
                self.games = gamedata
                // separating fetch cover url request so the update can be processed properly
                for game in self.games{
                    print(game)
                    self.apiController?.fetchIGDBVideoUrl(game: game){
                        self.indicator.stopAnimating()
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! videoTableViewCell
        // need unwrap the id before accessing since the request is asynchronous, first check whether the game has id list, then index the first video id
        if games[indexPath.row].youtuveID.count > 0{
            if let id = games[indexPath.row].youtuveID[0]{
                cell.playerView.load(withVideoId: id, playerVars: ["playsinline":1])

            }}
        cell.title.text = games[indexPath.row].name


        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // used here to expand the table view cell size
        return 300.0
    }



    

    

}
