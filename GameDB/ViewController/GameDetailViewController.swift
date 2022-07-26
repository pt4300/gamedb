//
//  GameDetailViewController.swift
//  GameDB
//
//  Created by Yuting Yu on 25/5/21.
//

import UIKit

class GameDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailSummaryTextField: UITextView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    weak var databaseController: DatabaseProtocol?

    var name:String?
    var summary:String?
    var release:String?
    var currentGameData:GameData?
    var apiController:ApiController?
    var imageList:[UIImage?] = []
    var screenshotsIndex = 0
    // leaving the download session in game table view because news and games have different approach to fetch image
    lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }()
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        apiController = ApiController()
        if let game = currentGameData{
          //  navigationController?.title = game.name
            
            apiController?.fetchIGDBAuthCode(completeHandler: {
                // require new auth code for identification to get single screenshots, api design flaw....
                self.apiController?.fetchIGDBScreenshots(game: game) {
                    
                    for url in game.screenshotsUrls{
                        if let url = url{
                            print(url)
                            self.downloadImage(url)

                        }
                    }
                    
                }
            })

        }

        // Do any additional setup after loading the view.
        if let name = self.name{
            nameLabel.text = name
        }
        if let release = self.release {
            releaseDateLabel.text = release
            

        }
        if let summary = self.summary{
            detailSummaryTextField.text = summary

        }
    }
    

    
    @IBAction func addFavoriteGame(_ sender: Any) {
        if let game = currentGameData{
            currentGameData = databaseController?.addFavoriteGame(game: game)

        }
        
    }
    @IBAction func addWishListGame(_ sender: Any) {
        if let game = currentGameData{
            currentGameData = databaseController?.addWishListGame(game: game)
        }
        
    }
    @IBAction func swipeControl(_ sender: Any) {
        guard let recognizer = sender as? UISwipeGestureRecognizer else{
            return
        }
        var newImageIndex = screenshotsIndex
        if recognizer.direction == .left {
            
            
           newImageIndex += 1

        }
        else if recognizer.direction == .right
        {

            newImageIndex -= 1
        }
        showImageWithIndex(index: newImageIndex)

        
    }
    
    func showImageWithIndex(index:Int){
        screenshotsIndex = (index + imageList.count) % imageList.count
        if let newImage =  imageList[screenshotsIndex]{
            imageView.image = newImage
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension GameDetailViewController:URLSessionDownloadDelegate,URLSessionDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do{
            let data = try Data(contentsOf: location)

            self.imageList.append(UIImage(data: data))

                
                // If found the cell to update, reload that row of tableview.
                DispatchQueue.main.async {

                 //   self.viewDidLoad()
                    self.imageView.image = self.imageList[0]!
                }
                
            }catch{
                print(error.localizedDescription)
            }
    }
    func downloadImage(_ imgUrl:String)->Int{
        print("Requesting screenshots: \(imgUrl)...")
        
        if let url = URL(string: imgUrl) {
            let task = session.downloadTask(with: url)
            task.resume()
            
            return task.taskIdentifier
        }
        return -1
    }
    
    
}
