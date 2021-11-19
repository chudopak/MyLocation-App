//
//  TagLocationViewController.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 11/18/21.
//

import Foundation
import UIKit
import CoreLocation

private let dateFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .medium
	formatter.timeStyle = .short
	return (formatter)
} ()

class LocationDetailsViewController : UITableViewController {
	
	var location: CLLocationCoordinate2D?
	weak var placemark: CLPlacemark?
	
	@IBOutlet weak var addressCellView: UIView!
	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longitudeLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	
	let addressLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 17)
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.numberOfLines = 0
		label.textAlignment = .right
		return (label)
	}()
	

	override func viewDidLoad() {
		super.viewDidLoad()
		addressLabel.translatesAutoresizingMaskIntoConstraints = false
		_updateLabels()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if (indexPath.section == 0 && indexPath.row == 0) {
			return (88)
		} else if (indexPath.section == 2 && indexPath.row == 2) {
			addressLabel.frame.size = CGSize(width: view.bounds.size.width - 150, height: 1000)
			addressLabel.sizeToFit()
			addressLabel.frame.origin.x = view.frame.size.width - addressLabel.frame.size.width - 20
			addressLabel.frame.origin.y = 10
			addressCellView.addSubview(addressLabel)
			return (addressLabel.frame.size.height + 20)
		} else {
			return (44)
		}
	}
	
	
	private func _updateLocation() {
		if let location = location {
			latitudeLabel.text = String(format: "%.6f", location.latitude)
			longitudeLabel.text = String(format: "%.6f", location.longitude)
		} else {
			latitudeLabel.text = "No location provided"
			longitudeLabel.text = "No location provided"
		}
	}
	
	private func _updateAddress() {
		if let placemark = placemark {
			var str = ""
			str.reserveCapacity(30)
			if let s = placemark.subThoroughfare {					//additional street info
				str += s + " "
			}
			if let s = placemark.thoroughfare {						//street address
				str += s + " "
			}
			if let s = placemark.locality {							//City
				str += s + " "
			}
			if let s = placemark.administrativeArea {				//province state
				str += s + " "
			}
			if let s = placemark.postalCode {
				str += s
			}
			addressLabel.text = str
		} else {
			addressLabel.text = "No Address Provided"
		}
	}
	
	private func _updateDate() {
		dateLabel.text = dateFormatter.string(from: Date())
	}
	
	private func _updateLabels() {
		_updateLocation()
		_updateAddress()
		_updateDate()
	}
	

	@IBAction func cancel(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}

	@IBAction func done(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
}