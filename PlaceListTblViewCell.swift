//
//  PlaceListTblViewCell.swift
//  DemoNearbyGooglePlaces
//
//  Created by VSL057 on 13/03/19.
//  Copyright © 2019 Disha. All rights reserved.
//

import UIKit
import Cosmos

class PlaceListTblViewCell: UITableViewCell {

    @IBOutlet weak var imgPlace: UIImageView!
    @IBOutlet weak var lblPlaceName: UILabel!
    @IBOutlet weak var viewPlaceRating: CosmosView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
