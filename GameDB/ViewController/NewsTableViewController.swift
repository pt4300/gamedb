//
//  NewsTableViewController.swift
//  GameDB
//
//  Created by Yuting Yu on 1/5/21.
//

import UIKit

class NewsTableViewController: UITableViewController {

    let NEWS_CELL = "newsCell"
    var newsList:[NewsData] = []
    var reviewList:[ReviewData] = []
    // using to determine the current segment, initial view is game
    var currentSegmentIdentifier:Int = 0
    var indicator = UIActivityIndicatorView()
    lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }()

    
    @IBOutlet weak var segementControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])

        fetchGameNews()
    }
    @IBAction func newsChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            fetchGameNews()
            currentSegmentIdentifier = sender.selectedSegmentIndex

            
        case 1:
            fetchReviews()
            currentSegmentIdentifier = sender.selectedSegmentIndex

        default:
            fetchGameNews()

        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch currentSegmentIdentifier {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: NEWS_CELL, for: indexPath) as! newsTableViewCell
            let news = newsList[indexPath.row]
            cell.title.text = news.title
            cell.date.text = news.publish_date
            cell.newsImage.image = nil
            
            if let image = news.newsImage{

                // if already downloard, set it
                cell.newsImage.image = image
            }
            else if news.downloadTaskIdentifier == nil, let imgUrl = news.imagesList?.square_small{
                newsList[indexPath.row].downloadTaskIdentifier = downloadImage(imgUrl)
            }
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: NEWS_CELL, for: indexPath) as! newsTableViewCell
            let review = reviewList[indexPath.row]
            cell.title.text = review.title
            cell.date.text = review.publish_date
            cell.imageView?.image = nil
            
            if let image = review.newsImage{
                // if already downloard, set it
                cell.newsImage.image = image
            }
            else if review.downloadTaskIdentifier == nil, let imgUrl = review.imagesList?.square_small{
                reviewList[indexPath.row].downloadTaskIdentifier = downloadImage(imgUrl)
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: NEWS_CELL, for: indexPath) as! newsTableViewCell
            let news = newsList[indexPath.row]
            cell.title.text = news.title
            cell.date.text = news.publish_date
            cell.newsImage.image = nil
            
            if let image = news.newsImage{
                // if already downloard, set it
                cell.newsImage.image = image
            }
            else if news.downloadTaskIdentifier == nil, let imgUrl = news.imagesList?.square_small{
                newsList[indexPath.row].downloadTaskIdentifier = downloadImage(imgUrl)
            }
            return cell
            
        }

        

        // Configure the cell...

    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "newsSegue"{
            if let cell = sender as? UITableViewCell{
                // the string is formatted as attributed string for display
                let indexPath = tableView.indexPath(for: cell)
                let destination = segue.destination as! NewsDetailViewController
                destination.htmlString = self.newsList[indexPath!.row].detail
                
                
            }
        }
        
        }
    


}

// configue url download protocol
extension NewsTableViewController:URLSessionDataDelegate,URLSessionDownloadDelegate{
    //configure download task
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        switch currentSegmentIdentifier {
        
            
        case 1:
            do{
                let data = try Data(contentsOf: location)
                // find the corresponding cell/news that require to download image
                var cellIndex = -1
                for index in 0..<reviewList.count{
                    let review = reviewList[index]
                    if  review.downloadTaskIdentifier == downloadTask.taskIdentifier{
                        reviewList[index].newsImage = UIImage(data: data)
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
        default:
            do{
                let data = try Data(contentsOf: location)
                // find the corresponding cell/news that require to download image
                var cellIndex = -1
                for index in 0..<newsList.count{
                    let news = newsList[index]
                    if  news.downloadTaskIdentifier == downloadTask.taskIdentifier{
                        newsList[index].newsImage = UIImage(data: data)
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
    
    func fetchGameNews(){
        // news fetching function
        indicator.startAnimating()
        guard let url = URL(string: "https://www.gamespot.com/api/articles/?api_key=e0877c2b6415edcd8a908f620e1d5059a1213008&format=json&limit=25&sort=publish_date:desc")else{
            print("failed to fetch news from gamespot api")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error{
                print(error)
            }
            else if let data = data{
                do{
                    let decoder = JSONDecoder()
                    let newsdata = try decoder.decode(NewsCollection.self, from: data)
                    for item in newsdata.newsList{
                        self.newsList.append(item)

                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.indicator.stopAnimating()
                    }
                }catch{
                    print(error)
                }
            }
        }
        task.resume()
            
        }
    
    func fetchReviews(){
        // reviews fetching function
        indicator.startAnimating()
        guard let url = URL(string: "https://www.gamespot.com/api/reviews/?api_key=e0877c2b6415edcd8a908f620e1d5059a1213008&format=json&limit=25&sort=publish_date:desc")else{
            print("failed to fetch news from gamespot api")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error{
                print(error)
            }
            else if let data = data{
                do{
                    let decoder = JSONDecoder()
                    let reviewsData = try decoder.decode(ReviewsCollection.self, from: data)
                    for item in reviewsData.reviewsList{
                        self.reviewList.append(item)

                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.indicator.stopAnimating()
                    }
                }catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // Deal with error.  Could try redownloading.
    }
    
    }
    

