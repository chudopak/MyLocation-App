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
	
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longitudeLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var tagButton: UIButton!
	@IBOutlet weak var getButton: UIButton!
	
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
		
		if authorizationStatus == .notDetermined {
			locationManager.requestWhenInUseAuthorization()
			return
		}
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
		locationManager.startUpdatingLocation()
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
	
	//MARK: - CLLocationManagerDelegate
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("didFailWitherror \(error)")
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let newLocation = locations.last!
		print("didUpdateLocations \(newLocation)")
	}
	
}
