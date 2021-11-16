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
	
	@IBAction func getLocation() {
		let authorizationStatus = locationManager.authorizationStatus
		
		switch authorizationStatus {
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
			return
		case .denied, .restricted:
			showLocationServicesDeniedAlert()
			return
		default:
			print("All ok")
		}
		
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
	
	func showLocationServicesDeniedAlert() {
		let alert = UIAlertController(title: "Location Disabeled",
									  message: "Go to preferences and enable location ",
									  preferredStyle: .alert)
		let okAlert = UIAlertAction(title: "OK",
									style: .default,
									handler: nil)
		alert.addAction(okAlert)
		present(alert, animated: true, completion: nil)
	}
	
	private func _configureGetButtonText() {
		if (updatingLocation) {
			getButton.setTitle("Stop", for: .normal)
		} else {
			getButton.setTitle("Get My Location", for: .normal)
		}
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
	
	private func _updateLabels() {
		if let location = location {
			latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
			longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
			tagButton.isHidden = false
		} else {
			latitudeLabel.text = ""
			longitudeLabel.text = ""
			addressLabel.text = ""
			tagButton.isHidden = true
		}
		messageLabel.text = _getMessageLabelText()
	}
	
	private func _startLocationManager() {
		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
			locationManager.startUpdatingLocation()
			updatingLocation = true
		}
	}
	
	private func _stopLocationManager() {
		if updatingLocation {
			locationManager.stopUpdatingLocation()
			locationManager.delegate = nil
			updatingLocation = false
		}
	}
	
	//MARK: - CLLocationManagerDelegate
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("didFailWitherror \(error)")
		
		//return because app loking for location but can't find it FOR NOW but it doesn't mean's all is lost
		if (error as NSError).code == CLError.locationUnknown.rawValue {
			return
		}
		
		lastLocationError = error
		_stopLocationManager()
		_updateLabels()
		_configureGetButtonText()
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let newLocation = locations.last!
		print("didUpdateLocations \(String(describing: newLocation))")
		print("Accuracy", newLocation.horizontalAccuracy)
		
		if (newLocation.timestamp.timeIntervalSinceNow < -5) {
			return
		}
		if (newLocation.horizontalAccuracy) < 0 {
			return
		}
		if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
			lastLocationError = nil
			location = newLocation
			_stopLocationManager()
			_updateLabels()
			_configureGetButtonText()
		}
	}
}
