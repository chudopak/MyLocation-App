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
	@IBOutlet weak var photoImageView: UIImageView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
	
	func configure(for location: Location) {
		
		_setLabelsColors()
		
		descriptionLabel.text = location.locationDescription != "" ? location.locationDescription : "(NoDescription)"
		photoImageView.image = _thumbnail(for: location)
		photoImageView.contentMode = .scaleToFill
		if let placemark = location.placemark {
			var text = ""
			text.add(text: placemark.subThoroughfare)
			text.add(text: placemark.thoroughfare, separatedBy: " ")
			text.add(text: placemark.locality, separatedBy: ", ")
			if (text == "") {
				addressLabel.text = String(format: "Lat: %.6f, Long: %.6f",
													location.latitude,
													location.longitude)
			} else {
				addressLabel.text = text
			}
		} else {
			addressLabel.text = String(format: "Lat: %.6f, Long: %.6f",
												location.latitude,
												location.longitude)
		}
	}
	
	private func _thumbnail(for location: Location) -> UIImage {
		if location.hasPhoto, let image = location.photoImage {
			return image.resized(withBounds: CGSize(width: 52, height: 52))
		}
		return (UIImage(systemName: "questionmark.circle")!)
	}
	
	private func _setLabelsColors() {
		addressLabel.textColor = adaptiveTintColorRegularAdress
		addressLabel.alpha = 0.4
	}

}
