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
	var			locationToEdit: Location? {
		didSet {
			if let editLocation = locationToEdit {
				_descriptionText = editLocation.locationDescription
				category.name = editLocation.category
				_date = editLocation.date
				location = CLLocationCoordinate2D(latitude: editLocation.latitude, longitude: editLocation.longitude)
				placemark = editLocation.placemark
			}
		}
	}
	private var			_descriptionText = ""
	
	private var			_date = Date()
	
	private var			_image: UIImage? {
		didSet {
			if let image = _image {
				imageView.isHidden = false
				imageView.image = image
				addPhotoLabel.text = ""
			} else {
				imageView.isHidden = true
				addPhotoLabel.text = "Add Photo"
			}
		}
	}
	
	
	@IBOutlet weak var	addressCellView: UIView!
	@IBOutlet weak var	descriptionTextView: UITextView!
	@IBOutlet weak var	categoryLabel: UILabel!
	@IBOutlet weak var	latitudeLabel: UILabel!
	@IBOutlet weak var	longitudeLabel: UILabel!
	@IBOutlet weak var	dateLabel: UILabel!
	@IBOutlet weak var	imageView: UIImageView!
	@IBOutlet weak var	addPhotoLabel: UILabel!
	
	private lazy var _addressLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 17)
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.numberOfLines = 0
		label.textAlignment = .right
		label.translatesAutoresizingMaskIntoConstraints = false
		return (label)
	}()
	

	override func viewDidLoad() {
		super.viewDidLoad()
		
		if locationToEdit != nil {
			title = "Edit Location"
		}
		descriptionTextView.text = _descriptionText

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
			_addressLabel.frame.size = CGSize(width: view.bounds.size.width - 150, height: 1000)
			_addressLabel.sizeToFit()
			_addressLabel.frame.origin.x = view.frame.size.width - _addressLabel.frame.size.width - 20
			_addressLabel.frame.origin.y = 10
			addressCellView.addSubview(_addressLabel)
			return (_addressLabel.frame.size.height + 20)
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
		tableView.deselectRow(at: indexPath, animated: false)
		if (indexPath.section == 0 && indexPath.row == 0) {
			descriptionTextView.becomeFirstResponder()
		} else if (indexPath.section == 1 && indexPath.row == 0) {
			pickPhoto()
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
			_addressLabel.text = str
		} else {
			_addressLabel.text = "No Address Provided"
		}
	}
	
	private func _updateDate() {
		dateLabel.text = dateFormatter.string(from: _date)
	}
	
	private func _updateDescriptionAndCategoryName() {
		if (locationToEdit == nil) {
			descriptionTextView.text = ""
		}
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
		
		let coreDataLocation: Location
		if let tmp = locationToEdit {
			hudView.text = "Updated"
			coreDataLocation = tmp
		} else {
			hudView.text = "Tagged"
			coreDataLocation = Location(context: managedObjectContext)
		}

		coreDataLocation.locationDescription = descriptionTextView.text
		coreDataLocation.category = category.name
		coreDataLocation.latitude = location?.latitude ?? 0.0
		coreDataLocation.longitude = location?.longitude ?? 0.0
		coreDataLocation.date = _date
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

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func choosePhotoFromLibrary() {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .photoLibrary
		imagePicker.delegate = self
		imagePicker.allowsEditing = true
		present(imagePicker, animated: true, completion: nil)
	}
	
	func takeNewPhoto() {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .camera
		imagePicker.delegate = self
		imagePicker.allowsEditing = true
		present(imagePicker, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		_image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
		
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
	
	func pickPhoto() {
		if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
			showPhotoMenu()
		} else {
			choosePhotoFromLibrary()
		}
	}
	
	func showPhotoMenu() {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		
		alert.addAction(actCancel)
		
		let actPhoto = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
			self.takeNewPhoto()
		})
		
		alert.addAction(actPhoto)
		
		let actLibrary = UIAlertAction(title: "Chose From Library", style: .default, handler: { _ in
			self.choosePhotoFromLibrary()
		})
		
		alert.addAction(actLibrary)
		
		present(alert, animated: true, completion: nil)
	}
}
