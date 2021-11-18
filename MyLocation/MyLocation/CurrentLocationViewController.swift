//
//  CurrentLocationViewController.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 11/12/21.
//

import Foundation
import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
	
	let locationManager = CLLocationManager()
	var location: CLLocation?
	var updatingLocation = false
	var lastLocationError: Error?
	
	let geocoder = CLGeocoder()
	var placemark: CLPlacemark?
	var performingReverseGeocoding = false
	var lastGeocodingError: Error?
	
	var timer: Timer?
	
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longitudeLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var tagButton: UIButton!
	@IBOutlet weak var getButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		_updateLabels()
		_configureGetButtonText()
	}
	
	private func _validateAuthorizationStatus() -> Bool{
		let authorizationStatus = locationManager.authorizationStatus
		
		switch authorizationStatus {
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
			return false
		case .denied, .restricted:
			_showLocationServicesDeniedAlert()
			return false
		default:
			return true
		}
	}
	
	@IBAction func getLocation() {
		if (!_validateAuthorizationStatus()) {
			return
		}
		placemark = nil
		lastGeocodingError = nil
		if updatingLocation {
			_stopLocationManager()
		} else {
			location = nil
			lastLocationError = nil
			_startLocationManager()
		}
		_updateLabels()
		_configureGetButtonText()
	}
	
	private func _showLocationServicesDeniedAlert() {
		let alert = UIAlertController(title: "Location Disabeled",
									  message: "Go to preferences and enable location ",
									  preferredStyle: .alert)
		let okAlert = UIAlertAction(title: "OK",
									style: .default,
									handler: nil)
		alert.addAction(okAlert)
		present(alert, animated: true, completion: nil)
	}
	
	
	
	private func _string(from placemark: CLPlacemark) -> String {
		var str1 = ""
		str1.reserveCapacity(30)
		if let s = placemark.subThoroughfare {					//additional street info
			str1 += s + " "
		}
		if let s = placemark.thoroughfare {						//street address
			str1 += s
		}
		str1 += "\n"
		if let s = placemark.locality {							//City
			str1 += s + " "
		}
		if let s = placemark.administrativeArea {				//province state
			str1 += s + " "
		}
		if let s = placemark.postalCode {
			str1 += s
		}
		return (str1)
	}
	
	private func _getMessageLabelText() -> String {
		let statusMessage: String
		if updatingLocation {
			statusMessage = "Searching..."
		} else if !CLLocationManager.locationServicesEnabled() {
			statusMessage = "Location Services Disabled"
		} else if let error = lastLocationError as NSError? {
			if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
				statusMessage = "Location services Disabled"
			} else {
				statusMessage = "Error Geting Location"
			}
		} else {
			statusMessage = "Tap 'Get My Location' to Start"
		}
		return (statusMessage)
	}
	
	private func _getAddressLabelText() -> String {
		let addressMessage: String
		if let placemark = placemark {
			addressMessage = _string(from: placemark)
		} else if (performingReverseGeocoding) {
			addressMessage = "Searching for Address..."
		} else if (lastGeocodingError != nil) {
			addressMessage = "Error Finding Address"
		} else {
			addressMessage = "No Address Found"
		}
		return (addressMessage)
	}
	
	private func _updateLabels() {
		if let location = location {
			latitudeLabel.text = String(format: "%.6f", location.coordinate.latitude)
			longitudeLabel.text = String(format: "%.6f", location.coordinate.longitude)
			tagButton.isHidden = false
			addressLabel.text = _getAddressLabelText()
		} else {
			latitudeLabel.text = ""
			longitudeLabel.text = ""
			addressLabel.text = ""
			tagButton.isHidden = true
		}
		messageLabel.text = _getMessageLabelText()
	}
	
	private func _configureGetButtonText() {
		if (updatingLocation) {
			getButton.setTitle("Stop", for: .normal)
		} else {
			getButton.setTitle("Get My Location", for: .normal)
		}
	}
	
	@objc func _didTimeOut() {
		if location == nil {
			_stopLocationManager()
			lastLocationError = NSError(domain: "MyLocationDomainError", code: 1, userInfo: nil)
			_updateLabels()
			_configureGetButtonText()
		}
	}

	private func _startLocationManager() {
		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
			locationManager.startUpdatingLocation()
			updatingLocation = true
			weak var weakSelf = self
			timer = Timer.scheduledTimer(timeInterval: 60, target: weakSelf!, selector: #selector(_didTimeOut), userInfo: nil, repeats: false)
		}
	}
	
	private func _stopLocationManager() {
		if updatingLocation {
			locationManager.stopUpdatingLocation()
			locationManager.delegate = nil
			updatingLocation = false
			if let timer = timer {
				timer.invalidate()
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "ShowTagLocation") {
			let navigationController = segue.destination as! UINavigationController
			let controller = navigationController.topViewController as! LocationDetailsViewController
			controller.location = location
			controller.placemark = placemark
		}
	}
	
	//MARK: - CLLocationManagerDelegate
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//		print("didFailWitherror \(error)")
		
		//return because app loking for location but can't find it FOR NOW but it doesn't mean's all is lost
		if (error as NSError).code == CLError.locationUnknown.rawValue {
			return
		}
		
		lastLocationError = error
		_stopLocationManager()
		_updateLabels()
		_configureGetButtonText()
	}
	
	private func _performReverseGeocoding(for newLocation: CLLocation) {
		performingReverseGeocoding = true
		geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
			[weak self] placemark, error in
//			print("***Found placemarks: \(String(describing: placemark)), error: \(String(describing: error))")
			self?.lastGeocodingError = error
			if error == nil, let p = placemark, !p.isEmpty{
				self?.placemark = p.last!
			} else {
				self?.placemark = nil
			}
			self?.performingReverseGeocoding = false
			self?._updateLabels()
		})
	}
	
	private func _updatingLocation(for newLocation: CLLocation, with distance: CLLocationDistance) {
		lastLocationError = nil
		location = newLocation
		if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
			_stopLocationManager()
			_configureGetButtonText()
			if (distance > 0) {
				performingReverseGeocoding = false
			}
		}
		_updateLabels()
		
		if (!performingReverseGeocoding) {
			_performReverseGeocoding(for: newLocation)
		}
	}
	
	private func _stoppingIfNoAccuracyImprovementForTenSeconds(newLocation: CLLocation) {
		let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
		if (timeInterval > 10) {
//			print("***Force done!")
			_stopLocationManager()
			_updateLabels()
			_configureGetButtonText()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let newLocation = locations.last!
//		print("didUpdateLocations \(String(describing: newLocation))")
//		print("Accuracy", newLocation.horizontalAccuracy)
		
		if (newLocation.timestamp.timeIntervalSinceNow < -5) {
			return
		}
		if (newLocation.horizontalAccuracy) < 0 {
			return
		}
		var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
		if let location = location {
			distance = newLocation.distance(from: location)
		}
		if (location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy
				|| newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
			_updatingLocation(for: newLocation, with: distance)
		} else if (distance < 1) {
			_stoppingIfNoAccuracyImprovementForTenSeconds(newLocation: newLocation)
		}
	}
}
