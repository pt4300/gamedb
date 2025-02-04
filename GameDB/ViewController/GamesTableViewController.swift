//
//  GamesTableViewController.swift
//  GameDB
//
//  Created by Yuting Yu on 3/5/21.
//

import UIKit
import Firebase

class GamesTableViewController: UITableViewController {


    
    var games:[GameData] = []
    var ps4Games:[GameData] = []
    var switchGames:[GameData] = []
    var xboxGames:[GameData]=[]
    // store ps4/switch/xbox code here, canno separate this to api wrapper since it needs for switch segementation
    let ps4Code = 48,switchCode = 130, xboxCode = 49
    let GAME_CELL = "gameCell"
    var igdbToken:String = ""
    var indicator = UIActivityIndicatorView()
    // set the listenertype to favoriteGame
    var listenerType = ListenerType.favoriteGame
    var currentSegementIdentifier:Int = 0
    weak var databaseController: DatabaseProtocol?
    var apiController: ApiController?


    // leaving the download session in game table view because news and games have different approach to fetch image
    lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiController = ApiController()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        NSLayoutConstraint.activate([indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
        apiController?.fetchIGDBAuthCode(){
            // the first completion handler is used to begin fetch game after obatin auth code
            self.indicator.startAnimating()
            self.apiController?.fetchIGDBGames(platform: self.ps4Code, completeHandler: { (gamedata) in
                // the game fetching also include cover image/ screenshots url fetch process
                self.games = gamedata
                self.ps4Games = gamedata
                self.indicator.stopAnimating()
                // separating fetch cover url request so the update can be processed properly
                for game in self.games{
                    self.apiController?.fetchIGDBCovers(game: game){
                        self.tableView.reloadData()
                    }
                }
            })
        }


        
        
    }
    
    @IBAction func changePlatform(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            if ps4Games.count == 0{
                self.apiController?.fetchIGDBAuthCode {
                    self.indicator.startAnimating()
                    self.apiController?.fetchIGDBGames(platform: self.ps4Code, completeHandler: { (gamedata) in
                        // the game fetching also include cover image/ screenshots url fetch process
                        self.ps4Games = gamedata
                        self.indicator.stopAnimating()
                        // separating fetch cover url request so the update can be processed properly
                        for game in self.games{
                            self.apiController?.fetchIGDBCovers(game: game){
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            }
            else{
                games = ps4Games
                self.tableView.reloadData()

            }

        case 1:
            if xboxGames.count == 0{
                self.apiController?.fetchIGDBAuthCode {
                    self.indicator.startAnimating()
                    self.apiController?.fetchIGDBGames(platform: self.xboxCode, completeHandler: { (gamedata) in
                        // the game fetching also include cover image/ screenshots url fetch process
                        self.xboxGames = gamedata
                        self.games = gamedata
                        self.indicator.stopAnimating()
                        // separating fetch cover url request so the update can be processed properly
                        for game in self.games{
                            self.apiController?.fetchIGDBCovers(game: game){
                                self.tableView.reloadData()
                            }
                        }
                        self.tableView.reloadData()
                    })
                }
            }
            else{
                games = xboxGames
                self.tableView.reloadData()

            }

        case 2:
            // cached the game after initial fetch to reduce request number. The cover image require single request on single game
            if switchGames.count == 0{
                
                self.apiController?.fetchIGDBAuthCode {
                    self.indicator.startAnimating()
                    self.apiController?.fetchIGDBGames(platform: self.switchCode, completeHandler: { (gamedata) in
                        // the game fetching also include cover image/ screenshots url fetch process
                        self.switchGames = gamedata
                        self.games = gamedata
                        self.indicator.stopAnimating()
                        // separating fetch cover url request so the update can be processed properly
                        for game in self.games{
                            self.apiController?.fetchIGDBCovers(game: game){
                                self.tableView.reloadData()
                            }
                        }
                        self.tableView.reloadData()
                    })
                }
            }
            else{
                games = switchGames
                self.tableView.reloadData()

            }

        default:
            print("hello")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return games.count
    }
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: GAME_CELL, for: indexPath) as! GamesTableViewCell
        let game = games[indexPath.row]
        cell.title.text = game.name
        cell.coverImage.image = nil

        if let image = game.coverImage{
            // if already downloard, set it
            cell.coverImage.image = image
        }
        else if game.downloadTaskIdentifier == nil, let url = game.coverUrls{

            game.downloadTaskIdentifier = downloadImage(url)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
     // Configure the cell...
     
     return cell
     }
     
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let game = games[indexPath.row]
//        var usersReference = Firestore.firestore().collection("users")
//        var gameReference = Firestore.firestore().collection("favoriteGames")
//        
//        if let userID = Auth.auth().currentUser?.uid{
//            usersReference.document("\(userID)").collection("favoriteGames").addDocument(data: ["game":game])
//            let gameAdded = databaseController?.addFavoriteGame(game: game)
//            games[indexPath.row].fireStoreId = gameAdded?.fireStoreId
//
//        }
//        // update the fireid into existing gamelist, prevent duplication
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
    

    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // the seguge way pass the releated information to the game detailed view. all segue for favorite/wishlist/game table view share same detail view list
        if segue.identifier == "gameDetailSegue"{
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

extension GamesTableViewController:URLSessionDownloadDelegate,URLSessionDelegate{
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // leaving here since all url download session are different. Multiple api is used
        do{
                let data = try Data(contentsOf: location)
                // find the corresponding cell/news that require to download image
                var cellIndex = -1
                for index in 0..<games.count{
                    let game = games[index]
                    if  game.downloadTaskIdentifier == downloadTask.taskIdentifier{
                        games[index].coverImage = UIImage(data: data)
                        cellIndex = index
                    }
                    
                }
                let cellIndexPath = IndexPath(row: cellIndex, section: 0)
                
                // If found the cell to update, reload that row of tableview.
                DispatchQueue.main.async {
                    if self.tableView.indexPathsForVisibleRows?.contains(cellIndexPath) ?? false {
                        self.tableView.reloadRows(at: [cellIndexPath], with: .automatic)
                    }
                    
                }
                
            }catch{
                print(error.localizedDescription)
            }
     
    }

    func downloadImage(_ imgUrl:String)->Int{
        print("Requesting image: \(imgUrl)...")
        
        if let url = URL(string: imgUrl) {
            let task = session.downloadTask(with: url)
            task.resume()
            
            return task.taskIdentifier
        }
        return -1
    }
}


extension GamesTableViewController:DatabaseListener{
    func onFavorite(change: DatabaseChange, games: [GameData]) {
        //
    }
    
    func onWishListChange(change: DatabaseChange, games: [GameData]) {
        //
    }
}
