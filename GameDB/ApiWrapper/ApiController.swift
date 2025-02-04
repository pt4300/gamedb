//
//  ApiController.swift
//  GameDB
//
//  Created by Yuting Yu on 10/6/21.
//

import UIKit

class ApiController: NSObject,ApiProtocol {
    let ps4Code = 48,switchCode = 130, xboxCode = 49
    let twitchSecret = "w52x9sdppb9gurefs3nh8olxea9tdr"
    let twitchID = "j0lgew28w4shc1p60yijf1zeiwbshy"
    var igdbToken:String = ""
    
    override init() {
        super.init()
    }
    
    func fetchIGDBAuthCode(completeHandler: @escaping () -> ()) {
        //this function is used to fetch the auth code for requesting igdb api request. The input id and twich secret is generate from twihch developer console
        // used header here because the request method is post
        let url = URL(string: "https://id.twitch.tv/oauth2/token?client_id=\(twitchID)&client_secret=\(twitchSecret)&grant_type=client_credentials")
        var requestHeader = URLRequest.init(url: url as! URL)
        requestHeader.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: requestHeader) { data, response, error in
            if let error = error{
                print(error)
            }
            else if let data = data{
                
                do{
                    let decoder = JSONDecoder()
                    let authCode = try decoder.decode(twichAuthCode.self, from: data)
                    DispatchQueue.main.async {
                        // the igdb token format is "type accesstoken" so string concatenation is required here
                        self.igdbToken = authCode.token_type + " " + authCode.access_token
                        if self.igdbToken == ""{
                            print("failed to fetch token")
                        }
                        completeHandler()
                        
                    }
                    
                }catch{
                    print(error.localizedDescription)
                }
                
            }
        }
        task.resume()
    }
    
    func fetchIGDBGames(platform: Int,completeHandler:@escaping ([GameData])->Void) {
        //This is igdb game fetch api call. The aim of this call is to obtain a list of gamedata object from igdb database.
        let currentEpochTime:String = String(Int(Date().timeIntervalSince1970))
        let limit = 12
        // the request url is using post method as igdb api are all designed with post method for accesing
        let url = URL(string: "https://api.igdb.com/v4/games")
        var requestHeader = URLRequest.init(url: url as! URL)
        // the http body is set to generate 50 result with latest release date game. The release date restriction to prevent fetching game with only name.
        requestHeader.httpBody = "fields *;  sort first_release_date desc;  limit \(limit); where first_release_date < \(currentEpochTime)&platforms= \(platform) &aggregated_rating > 70 ;".data(using: .utf8, allowLossyConversion: false)
        requestHeader.httpMethod = "POST"
        requestHeader.setValue("\(twitchID)", forHTTPHeaderField: "Client-ID")
        requestHeader.setValue("\(igdbToken)", forHTTPHeaderField: "Authorization")
        requestHeader.setValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: requestHeader) { data, response, error in
            if let error = error{
                print(error.localizedDescription)
            }
            else if let data = data{
                
                do{
                    let decoder = JSONDecoder()
                    let gameList = try decoder.decode([GameData].self, from: data)
                    
                    DispatchQueue.main.async {
                        // require to return the value through completion handler
                        completeHandler(gameList)
                        
                    }
                    
                    
                    
                }catch{
                    print(error)
                }
                
            }
            
        }
        task.resume()
    }
    
    func fetchIGDBCovers(game: GameData,completeHandler:@escaping ()->()) {
        // this function is used to fetch cover image for game. The screenshots fetching will be separated due to the design of igdb api structure
        var id = String(game.id!)
        let url = URL(string: "https://api.igdb.com/v4/covers")
        var requestHeader = URLRequest.init(url: url as! URL)
        requestHeader.httpBody = "fields url;where game= \(id);".data(using: .utf8, allowLossyConversion: false)
        requestHeader.httpMethod = "POST"
        requestHeader.setValue("\(twitchID)", forHTTPHeaderField: "Client-ID")
        requestHeader.setValue("\(igdbToken)", forHTTPHeaderField: "Authorization")
        requestHeader.setValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: requestHeader) { data, response, error in
            if let error = error{
                print(error.localizedDescription)
            }

            else if let data = data{
                
                do{
                    let decoder = JSONDecoder()

                    let coverUrl = try decoder.decode([coverData].self, from: data)
                    DispatchQueue.main.async {
                        if coverUrl.count>0{
                            game.coverUrls = "https:" + coverUrl[0].url
                        }
                        completeHandler()
                    }
                    
                }catch{
                    // since the api have access caps, the response also required for debugging purpose
                    print(response)
                    print(error)
                }
                
            }
            
        }
        task.resume()
        
    }
    
    func fetchIGDBScreenshots(game: GameData,completeHandler:@escaping ()->Void) {
        
        // this function is used to fetch screenshots for game.
        var id = String(game.id!)
        let url = URL(string: "https://api.igdb.com/v4/screenshots")
        var requestHeader = URLRequest.init(url: url as! URL)
        requestHeader.httpBody = "fields url;where game= \(id);".data(using: .utf8, allowLossyConversion: false)
        requestHeader.httpMethod = "POST"
        requestHeader.setValue("\(twitchID)", forHTTPHeaderField: "Client-ID")
        requestHeader.setValue("\(igdbToken)", forHTTPHeaderField: "Authorization")
        requestHeader.setValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: requestHeader) { data, response, error in
            if let error = error{
                print(error.localizedDescription)
            }

            else if let data = data{
                
                do{
                    let decoder = JSONDecoder()

                    let screenshotsURLs = try decoder.decode([coverData].self, from: data)
                    DispatchQueue.main.async {
                        // each screenshoots URL require formatting
                        for item in screenshotsURLs{
                            game.screenshotsUrls.append("https:" + item.url)

                        }
                        completeHandler()
                    }
                    
                    
                    
                }catch{
                    print(response)
                    print(error)
                }
                
            }
            
        }
        task.resume()
    }
    
    func fetchIGDBVideoUrl(game:GameData,completeHandler:@escaping ()->Void){
        // this function is used to fetch screenshots for game.
        var id = String(game.id!)
        let url = URL(string: "https://api.igdb.com/v4/game_videos")
        var requestHeader = URLRequest.init(url: url as! URL)
        requestHeader.httpBody = "fields video_id; where game = \(id);;".data(using: .utf8, allowLossyConversion: false)
        requestHeader.httpMethod = "POST"
        requestHeader.setValue("\(twitchID)", forHTTPHeaderField: "Client-ID")
        requestHeader.setValue("\(igdbToken)", forHTTPHeaderField: "Authorization")
        requestHeader.setValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: requestHeader) { data, response, error in
            if let error = error{
                print(error.localizedDescription)
            }

            else if let data = data{
                
                do{
                    let decoder = JSONDecoder()

                    let youtubeID = try decoder.decode([videoData].self, from: data)
                    DispatchQueue.main.async {
                        // add the game video id in to game video id array, only first one need to be append
                        for id in youtubeID{
                            game.youtuveID.append(id.video_id)
                            print(id)
                            print(id)
                        }
                        completeHandler()
                    }
                    
                    
                    
                }catch{
                    print(response)
                    print(error)
                }
                
            }
            
        }
        task.resume()
        
    }
    func searchIGDBGame(name: String, completeHandler: @escaping ([GameData]) -> Void) {
        //This is igdb game fetch api call. The aim of this call is to obtain a list of gamedata object from igdb database.
        let currentEpochTime:String = String(Int(Date().timeIntervalSince1970))
        // the request url is using post method as igdb api are all designed with post method for accesing
        let url = URL(string: "https://api.igdb.com/v4/games")
        var requestHeader = URLRequest.init(url: url as! URL)
        // the http body is set to generate 50 result with latest release date game. The release date restriction to prevent fetching game with only name.
        // double quotation mark as the syntax for search is searc "keyword"
        requestHeader.httpBody = "fields *; search \"\(name)\";".data(using: .utf8, allowLossyConversion: false)
        requestHeader.httpMethod = "POST"
        requestHeader.setValue("\(twitchID)", forHTTPHeaderField: "Client-ID")
        requestHeader.setValue("\(igdbToken)", forHTTPHeaderField: "Authorization")
        requestHeader.setValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: requestHeader) { data, response, error in
            if let error = error{
                print(error.localizedDescription)
            }
            else if let data = data{
                
                do{
                    let decoder = JSONDecoder()
                    let gameList = try decoder.decode([GameData].self, from: data)
                    print(gameList[0])
                    
                    DispatchQueue.main.async {
                        // require to return the value through completion handler
                        completeHandler(gameList)
                        
                    }
                    
                    
                    
                }catch{
                    print(response)
                    print(error)
                }
                
            }
            
        }
        task.resume()
    }


    
    
}
