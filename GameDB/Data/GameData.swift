//
//  GameData.swift
//  GameDB
//
//  Created by Yuting Yu on 3/5/21.
//

import Foundation
import UIKit
import  FirebaseFirestoreSwift

class GameData:NSObject,Codable{
    var id:Int?
    var first_release_date:Int?
    var name:String?
    var storyline:String?
    var summary:String?
    var downloadTaskIdentifier: Int?
    var coverImage:UIImage?
    var screenshots:[UIImage?] = []
    var coverUrls: String?
    var screenshotsUrls:[String?] = []
    var youtuveID:[String?] = []

    
    // used for firebase only
    @DocumentID var fireStoreId:String?
    
    private enum CodingKeys:String,CodingKey{
        case id
        case first_release_date
        case name
        case storyline
        case summary
        case fireStoreId
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(Int.self, forKey: .id)
        self.first_release_date = try? container.decode(Int.self, forKey: .first_release_date)
        self.name = try? container.decode(String.self, forKey: .name)
        self.storyline = try? container.decode(String.self, forKey: .storyline)
        self.summary = try? container.decode(String.self, forKey: .summary)
        // checking whether firestore id is exist, if not exist set it to nil for preventing crash

        if container.contains(.fireStoreId){
            // not sure why this firestoreid is not decode appropriately. Checking the container and everything is okay. Modified it to firestoreId also doesnt address the issue, same problem persist.
            self.fireStoreId = try container.decode(DocumentID<String>.self, forKey: .fireStoreId).wrappedValue

        }else{
            fireStoreId = nil
        }

    }
    
}


struct coverData:Codable{
        var url:String

}

struct videoData:Codable{
    var video_id:String
}

struct twichAuthCode:Codable{
    var access_token:String
    var token_type:String

    
}
