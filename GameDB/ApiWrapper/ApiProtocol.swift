//
//  ApiProtocol.swift
//  GameDB
//
//  Created by Yuting Yu on 10/6/21.
//

import Foundation

protocol ApiProtocol: AnyObject {
        
    // detail explaination for each function is listed in the implmentation controller
    func fetchIGDBAuthCode(completeHandler:@escaping ()->())
    func fetchIGDBGames(platform:Int,completeHandler:@escaping ([GameData])->Void)
    func fetchIGDBCovers(game:GameData,completeHandler:@escaping ()->())
    func fetchIGDBScreenshots(game:GameData,completeHandler:@escaping ()->Void)
    func fetchIGDBVideoUrl(game:GameData,completeHandler:@escaping ()->Void)
    func searchIGDBGame(name:String,completeHandler:@escaping ([GameData])->Void)
    
}
