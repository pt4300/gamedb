//
//  ReviewData.swift
//  GameDB
//
//  Created by Yuting Yu on 2/5/21.
//

import Foundation
import UIKit

class ReviewData:NSObject,Codable{
    var publish_date:String
    var title:String
    var summary:String
    var detail:String
    var score:String
    var good:String
    var bad:String
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
        case score
        case good
        case bad
        
        
    }
    
    
}

struct ReviewsCollection:Codable{
    var reviewsList:[ReviewData]
    private enum CodingKeys:String,CodingKey{
        case reviewsList = "results"
    }
    
}

