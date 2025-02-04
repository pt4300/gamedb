//
//  videoTableViewCell.swift
//  GameDB
//
//  Created by Yuting Yu on 11/6/21.
//

import UIKit
import youtube_ios_player_helper

class videoTableViewCell: UITableViewCell {
    @IBOutlet var playerView:YTPlayerView!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
