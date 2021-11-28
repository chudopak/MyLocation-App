//
//  TagLocationViewController.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 11/18/21.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .medium
	formatter.timeStyle = .short
	return (formatter)
} ()

class LocationDetailsViewController : UITableViewController {
	
	var			location: CLLocationCoordinate2D?
	weak var	placemark: CLPlacemark?
	var 		category = CategoryCell(name: "No Category")
	
	var			managedObjectContext: NSManagedObjectContext!
	
	var			date = Date()
	
	
	@IBOutlet weak var	addressCellView: UIView!
	@IBOutlet weak var	descriptionTextView: UITextView!
	@IBOutlet weak var	categoryLabel: UILabel!
	@IBOutlet weak var	latitudeLabel: UILabel!
	@IBOutlet weak var	longitudeLabel: UILabel!
	@IBOutlet weak var	dateLabel: UILabel!
	
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
		
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		gestureRecognizer.cancelsTouchesInView = false
		tableView.addGestureRecognizer(gestureRecognizer)
	}
	
	@objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
		let point = gestureRecognizer.location(in: tableView)
		let indexPath = tableView.indexPathForRow(at: point)
		
		if (indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0) {
			return
		}
		descriptionTextView.resignFirstResponder()
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
	
	//MARK: - UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if (indexPath.section == 0 || indexPath.section == 1) {
			return (indexPath)
		} else {
			return (nil)
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if (indexPath.section == 0 && indexPath.row == 0) {
			descriptionTextView.becomeFirstResponder()
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
		dateLabel.text = dateFormatter.string(from: date)
	}
	
	private func _updateDescriptionAndCategoryName() {
		descriptionTextView.text = ""
		categoryLabel.text = category.name
	}
	
	private func _updateLabels() {
		_updateLocation()
		_updateAddress()
		_updateDate()
		_updateDescriptionAndCategoryName()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "PickCategory") {
			let controller = segue.destination as! CategoryPickerViewController
			controller.selectedCategory = category
		}
	}
	
	@IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
		let controller = segue.source as! CategoryPickerViewController
		category = controller.selectedCategory
		categoryLabel.text = category.name
	}
	
	@IBAction func cancel(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}

	@IBAction func done(_ sender: UIBarButtonItem) {
		let hudView = HudView.hud(inView: navigationController!.view, animated: true)
		hudView.text = "Tagged"
		
		let coreDataLocation = Location(context: managedObjectContext)

		coreDataLocation.locationDescription = descriptionTextView.text
		coreDataLocation.category = category.name
		coreDataLocation.latitude = location?.latitude ?? 0.0
		coreDataLocation.longitude = location?.longitude ?? 0.0
		coreDataLocation.date = date
		coreDataLocation.placemark = placemark
		
		
		do {
			try managedObjectContext.save()
			afterDelay(0.6) {
				self.dismiss(animated: true, completion: nil)
			}
		} catch {
			fatalCoreDataError(error)
		}
	}
}
