//
//  CurrentLocationViewController.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 11/12/21.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate, CAAnimationDelegate {
	
	let locationManager = CLLocationManager()
	var location: CLLocation?
	var updatingLocation = false
	var lastLocationError: Error?
	
	let geocoder = CLGeocoder()
	var placemark: CLPlacemark?
	var performingReverseGeocoding = false
	var lastGeocodingError: Error?
	
	var timer: Timer?
	
	var managedObjectContext: NSManagedObjectContext!
	
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longitudeLabel: UILabel!
	@IBOutlet weak var latitudeTextLabel: UILabel!
	@IBOutlet weak var longitudeTextLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var tagButton: UIButton!
	@IBOutlet weak var getButton: UIButton!
	
	@IBOutlet weak var containerView: UIView!
	
	private var _isLogoVisible = false
	
	lazy var logoButton: UIButton = {
		let button = UIButton(type: .custom)
		switch traitCollection.userInterfaceStyle {
		case .dark:
			button.setBackgroundImage(UIImage(named: "LogoDark"), for: .normal)
		default:
			button.setBackgroundImage(UIImage(named: "LogoLight"), for: .normal)
		}
		button.sizeToFit()
		button.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
		button.center.x = self.view.bounds.midX
		button.center.y = self.view.safeAreaLayoutGuide.layoutFrame.height * 0.45
		button.bounds = CGRect(x: 0,
							   y: 0,
							   width: self.view.bounds.size.width * 0.9,
							   height: self.view.bounds.size.width * 0.9)
		return (button)
	}()
	
	let spinnerTag = 107
	
	lazy var spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView(style: .medium)
		spinner.center.x = messageLabel.center.x
		spinner.center.y = messageLabel.center.y + spinner.bounds.size.height + 25
		spinner.startAnimating()
		spinner.tag = spinnerTag
		return (spinner)
	} ()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		_setColors()
		_setConstraints()
		_showLogoView()
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
	
	private func _string(from placemark: CLPlacemark) -> String {
		
		var line1 = ""
		line1.reserveCapacity(20)
		line1.add(text: placemark.subThoroughfare, separatedBy: " ")
		line1.add(text: placemark.thoroughfare)
		
		var line2 = ""
		line2.reserveCapacity(20)
		line2.add(text: placemark.locality, separatedBy: "")
		line2.add(text: placemark.administrativeArea, separatedBy: " ")
		line2.add(text: placemark.postalCode)
		line1.add(text: line2, separatedBy: "\n")
		
		return (line1)
	}
	
	private func _updateLabels() {
		if let location = location {
			latitudeLabel.text = String(format: "%.6f", location.coordinate.latitude)
			longitudeLabel.text = String(format: "%.6f", location.coordinate.longitude)
			tagButton.isHidden = false
			addressLabel.text = _getAddressLabelText()
			latitudeTextLabel.isHidden = false
			longitudeTextLabel.isHidden = false
		} else {
			latitudeLabel.text = ""
			longitudeLabel.text = ""
			addressLabel.text = ""
			tagButton.isHidden = true
			latitudeTextLabel.isHidden = true
			longitudeTextLabel.isHidden = true
		}
		if (_isLogoVisible) {
			messageLabel.text = ""
		} else {
			messageLabel.text = _getMessageLabelText()
		}
	}
	
	private func _showLogoView() {
		if (!_isLogoVisible) {
			_isLogoVisible = true
			containerView.isHidden = true
			view.addSubview(logoButton)
		}
	}
	
	private func _configureGetButtonText() {
		if (updatingLocation) {
			getButton.setTitle("Stop", for: .normal)
			
			if (view.viewWithTag(spinnerTag) == nil) {
				containerView.addSubview(spinner)
			}
		} else {
			getButton.setTitle("Get My Location", for: .normal)
			if let spinner = view.viewWithTag(spinnerTag) {
				spinner.removeFromSuperview()
			}
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
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "ShowTagLocation") {
			let navigationController = segue.destination as! UINavigationController
			let controller = navigationController.topViewController as! LocationDetailsViewController
			controller.location = location?.coordinate
			controller.placemark = placemark
			controller.managedObjectContext = managedObjectContext
		}
	}
	
	private func _hideLogoView() {
		_isLogoVisible = false
		containerView.isHidden = false
		
		containerView.center.x = view.bounds.size.width * 2
		containerView.center.y = 40 + containerView.bounds.size.height / 2
		
		let centerX = view.bounds.midX
		
		let panelMover = _configurePanelMover(centerX: centerX)
		containerView.layer.add(panelMover, forKey: "panelMover")
		
		let logoMover = _configureLogoMover(centerX: centerX)
		logoButton.layer.add(logoMover, forKey: "logoMover")

		let logoRotator = _configureLogoRotator(centerX: centerX)
		logoButton.layer.add(logoRotator, forKey: "logoRotator")
	}
	
	private func _configureLogoMover(centerX: CGFloat) -> CABasicAnimation {
		let logoMover = CABasicAnimation(keyPath: "position")
		logoMover.isRemovedOnCompletion = false
		logoMover.fillMode = CAMediaTimingFillMode.forwards
		logoMover.duration = 0.5
		logoMover.fromValue = NSValue(cgPoint: logoButton.center)
		logoMover.toValue = NSValue(cgPoint:
			  CGPoint(x: -centerX, y: logoButton.center.y))
		logoMover.timingFunction = CAMediaTimingFunction(
						 name: CAMediaTimingFunctionName.easeIn)
		return (logoMover)
	}
	
	private func _configureLogoRotator(centerX: CGFloat) -> CABasicAnimation {
		let logoRotator = CABasicAnimation(keyPath:
							   "transform.rotation.z")
		logoRotator.isRemovedOnCompletion = false
		logoRotator.fillMode = CAMediaTimingFillMode.forwards
		logoRotator.duration = 0.5
		logoRotator.fromValue = 0.0
		logoRotator.toValue = -2 * Double.pi
		logoRotator.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
		return (logoRotator)
	}
	
	private func _configurePanelMover(centerX: CGFloat) -> CABasicAnimation {
		let panelMover = CABasicAnimation(keyPath: "position")
		panelMover.isRemovedOnCompletion = false
		panelMover.fillMode = CAMediaTimingFillMode.forwards
		panelMover.duration = 0.6
		panelMover.fromValue = NSValue(cgPoint: containerView.center)
		panelMover.toValue = NSValue(cgPoint: CGPoint(x: centerX,
													  y: containerView.center.y))
		panelMover.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
		panelMover.delegate = self
		return (panelMover)
	}
	
	func animationDidStop(_ anim: CAAnimation,
				   finished flag: Bool) {
		containerView.layer.removeAllAnimations()
		containerView.center.x = view.bounds.size.width * 0.5
		containerView.center.y = containerView.bounds.size.height * 0.5
		logoButton.layer.removeAllAnimations()
		logoButton.removeFromSuperview()
	}
	
	//MARK: - Button targets
	@IBAction func getLocation() {
		if (!_validateAuthorizationStatus()) {
			return
		}
		if (_isLogoVisible) {
			_hideLogoView()
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
	
	//MARK: - CLLocationManagerDelegate
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		
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
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let newLocation = locations.last!
		
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
			_stopLocationManager()
			_updateLabels()
			_configureGetButtonText()
		}
	}
	
	private func _setColors() {
		view.backgroundColor = adaptiveBackgroundColor
		view.tintColor = adaptiveTintColorRegular
		tagButton.tintColor = adaptiveTintColorForTitlesAndButtons
		getButton.tintColor = adaptiveTintColorForTitlesAndButtons
	}
	
	private func _setConstraints() {
		let safeAreaHeight = view.safeAreaLayoutGuide.layoutFrame.size.height
		let containerViewHeight = safeAreaHeight * 0.65
		let messageLabelHeight: CGFloat = 40
		let tagButtonHeight: CGFloat = 35
		let latitudeHeight: CGFloat = 25
		let longitudeHeight: CGFloat = 25
		let addressLabelHeight: CGFloat = 50
		let getButtonHeight: CGFloat = 40
		
		let filledHeightSpase = messageLabelHeight + tagButtonHeight + latitudeHeight + longitudeHeight + addressLabelHeight
		
		let emptyHeightSpace = containerViewHeight - filledHeightSpase
		
		let latitudeLabelWidth: CGFloat = 130
		let longitudeLabelWidth: CGFloat = 130
		
		containerView.translatesAutoresizingMaskIntoConstraints = false
		tagButton.translatesAutoresizingMaskIntoConstraints = false
		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		latitudeLabel.translatesAutoresizingMaskIntoConstraints = false
		longitudeLabel.translatesAutoresizingMaskIntoConstraints = false
		latitudeTextLabel.translatesAutoresizingMaskIntoConstraints = false
		longitudeTextLabel.translatesAutoresizingMaskIntoConstraints = false
		addressLabel.translatesAutoresizingMaskIntoConstraints = false
		getButton.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			containerView.heightAnchor.constraint(equalToConstant: containerViewHeight),
			containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			containerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
			containerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16)
		])
		
		NSLayoutConstraint.activate([
			tagButton.heightAnchor.constraint(equalToConstant: tagButtonHeight),
			tagButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			tagButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 40),
			tagButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -40)
		])
		
		NSLayoutConstraint.activate([
			messageLabel.heightAnchor.constraint(equalToConstant: messageLabelHeight),
			messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
			messageLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor),
			messageLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor)
		])
		
		NSLayoutConstraint.activate([
			latitudeLabel.heightAnchor.constraint(equalToConstant: latitudeHeight),
			latitudeLabel.widthAnchor.constraint(equalToConstant: latitudeLabelWidth),
			latitudeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: emptyHeightSpace * 0.2),
			latitudeLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor)
		])

		NSLayoutConstraint.activate([
			latitudeTextLabel.heightAnchor.constraint(equalToConstant: latitudeHeight),
			latitudeTextLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: emptyHeightSpace * 0.2),
			latitudeTextLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor),
			latitudeTextLabel.rightAnchor.constraint(equalTo: latitudeLabel.leftAnchor)
		])
		
		NSLayoutConstraint.activate([
			longitudeLabel.heightAnchor.constraint(equalToConstant: longitudeHeight),
			longitudeLabel.widthAnchor.constraint(equalToConstant: longitudeLabelWidth),
			longitudeLabel.topAnchor.constraint(equalTo: latitudeLabel.bottomAnchor, constant: emptyHeightSpace * 0.1),
			longitudeLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor)
		])

		NSLayoutConstraint.activate([
			longitudeTextLabel.heightAnchor.constraint(equalToConstant: longitudeHeight),
			longitudeTextLabel.topAnchor.constraint(equalTo: latitudeLabel.bottomAnchor, constant: emptyHeightSpace * 0.1),
			longitudeTextLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor),
			longitudeTextLabel.rightAnchor.constraint(equalTo: latitudeLabel.leftAnchor)
		])
		
		NSLayoutConstraint.activate([
			addressLabel.heightAnchor.constraint(equalToConstant: addressLabelHeight),
			addressLabel.topAnchor.constraint(equalTo: longitudeLabel.bottomAnchor, constant: emptyHeightSpace * 0.2),
			addressLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor),
			addressLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor)
		])

		NSLayoutConstraint.activate([
			getButton.heightAnchor.constraint(equalToConstant: getButtonHeight),
			getButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant:  -(safeAreaHeight * 0.05)),
			getButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
			getButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30)
		])
		
	}
}
