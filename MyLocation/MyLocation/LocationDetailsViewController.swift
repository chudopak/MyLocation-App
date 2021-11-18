//
//  TagLocationViewController.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 11/18/21.
//

import Foundation
import UIKit
import CoreLocation

class LocationDetailsViewController : UITableViewController {
	
	weak var location: CLLocation?
	weak var placemark: CLPlacemark?
	
	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longitudeLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		_updateLabels()
	}
	
	
	private func _updateLocation() {
		if let location = location {
			latitudeLabel.text = String(format: "%.6f", location.coordinate.latitude)
			longitudeLabel.text = String(format: "%.6f", location.coordinate.longitude)
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
				str += s
			}
			str += "\n"
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
		dateLabel.text = "Noo date"
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
