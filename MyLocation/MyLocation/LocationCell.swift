//
//  LocationCell.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 11/30/21.
//

import UIKit

class LocationCell: UITableViewCell {

	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func configure(for location: Location) {
		
		descriptionLabel.text = location.locationDescription != "" ? location.locationDescription : "(NoDescription)"
		
		if let placemark = location.placemark {
			var text = ""
			if let s = placemark.subThoroughfare {
				text = s + " "
			}
			if let s = placemark.thoroughfare {
				text += s + ", "
			}
			if let s = placemark.locality {
				text += s
			}
			addressLabel.text = text
		} else {
			addressLabel.text = String(format: "Lat: %.6f, Long: %.6f",
												location.latitude,
												location.longitude)
		}
	}

}
