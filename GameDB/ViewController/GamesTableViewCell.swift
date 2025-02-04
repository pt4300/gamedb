//
//  GamesTableViewCell.swift
//  GameDB
//
//  Created by Yuting Yu on 3/5/21.
//

import UIKit

class GamesTableViewCell: UITableViewCell {

    // all games have same structure so we can hold the display section item in one array


    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
