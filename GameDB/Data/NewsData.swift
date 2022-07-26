//
//  NewsData.swift
//  GameDB
//
//  Created by Yuting Yu on 1/5/21.
//

import Foundation
import UIKit

class NewsData:NSObject,Codable{
    var publish_date:String
    var title:String
    var summary:String
    var detail:String
    var imagesList:ImageData?
    
    // used for download image ,not json
    
    var newsImage: UIImage?
    var downloadTaskIdentifier: Int?
    
    private enum CodingKeys:String,CodingKey{
        case publish_date
        case title
        case summary = "deck"
        case detail = "body"
        case imagesList = "image"
        
        
    }
    
    
}

struct NewsCollection:Codable{
    var newsList:[NewsData]
    private enum CodingKeys:String,CodingKey{
        case newsList = "results"
    }
    
}
struct ImageData:Codable{
    var square_small:String
    
}



