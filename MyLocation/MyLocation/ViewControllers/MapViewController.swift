//
//  MapViewController.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 12/3/21.
//

import Foundation
import UIKit
import CoreData
import MapKit

class MapViewController : UIViewController {
	
	@IBOutlet weak var	mapView: MKMapView!
	@IBOutlet weak var	userBarButton: UIBarButtonItem!
	@IBOutlet weak var	locationsBarButton: UIBarButtonItem!
	
	var locations = [Location]()
	var managedObjectContext: NSManagedObjectContext!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		_setColors()
		mapView.delegate = self
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		_updateLocations()
		if !locations.isEmpty {
			showLocations()
		} else {
			showUser()
		}
	}
	
	private func _updateLocations() {
		mapView.removeAnnotations(locations)

		let entity = Location.entity()
		let fetchRequest = NSFetchRequest<Location>()
		fetchRequest.entity = entity

		locations = try! managedObjectContext.fetch(fetchRequest)
		mapView.addAnnotations(locations)
	}
	
	private func _userCenterRegion() -> MKCoordinateRegion {
		return (MKCoordinateRegion(center: mapView.userLocation.coordinate,
										latitudinalMeters: 1000,
										longitudinalMeters: 1000))
	}
	
	private func _annotationCenterRegion(for annotation: MKAnnotation) -> MKCoordinateRegion {
		return (MKCoordinateRegion(center: annotation.coordinate,
									latitudinalMeters: 1000,
									longitudinalMeters: 1000))
	}
	
	private func _centerOfAllAnnotationsRegion(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
		
		var topLeft = CLLocationCoordinate2D(latitude: -90,
											 longitude: 180)
		var bottomRight = CLLocationCoordinate2D(latitude: 90,
												 longitude: -180)
		
		for annotation in annotations {
			topLeft.latitude = max(topLeft.latitude,
								   annotation.coordinate.latitude)
			topLeft.longitude = min(topLeft.longitude,
									annotation.coordinate.longitude)
			bottomRight.latitude = min(bottomRight.latitude,
									   annotation.coordinate.latitude)
			bottomRight.longitude = max(bottomRight.longitude,
										annotation.coordinate.longitude)
		}
		let center = CLLocationCoordinate2D(
					latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2,
					longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2)
		let extraSpace = 1.1
		
		let span = MKCoordinateSpan(latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace,
									longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)
		return (MKCoordinateRegion(center: center, span: span))
	}
	
	private func _region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
		
		let region: MKCoordinateRegion
		
		switch annotations.count {

		case 0:
			region = _userCenterRegion()

		case 1:
			let annotation = annotations[annotations.count - 1]
			region = _annotationCenterRegion(for: annotation)

		default:
			region = _centerOfAllAnnotationsRegion(for: annotations)
		}
		return (mapView.regionThatFits(region))
	}
	
	
	@objc func showLocationDetails(_ sender: UIButton) {
		performSegue(withIdentifier: "EditLocation", sender: sender)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "EditLocation") {
			let navController = segue.destination as! UINavigationController
			let controller = navController.topViewController as! LocationDetailsViewController
			controller.managedObjectContext = managedObjectContext
		
			let button = sender as! UIButton
			let location = locations[button.tag]
			controller.locationToEdit = location
		}
	}
	
	// MARK: - Actions
	@IBAction func showUser() {
		let region = MKCoordinateRegion(center: mapView.userLocation.coordinate,
										latitudinalMeters: 1000,
										longitudinalMeters: 1000)
		mapView.setRegion(mapView.regionThatFits(region),
						  animated: true)
	}
	
	@IBAction func showLocations() {
		let region = _region(for: locations)
		mapView.setRegion(region, animated: true)
	}
	
	
	private func _setColors() {
		userBarButton.tintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeTintColorYellow)
			default:
				return (lightThemeTintColorPurple)
			}
		}
		
		locationsBarButton.tintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeTintColorYellow)
			default:
				return (lightThemeTintColorPurple)
			}
		}
	}
}

extension MapViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView,
				 viewFor annotation: MKAnnotation) -> MKAnnotationView? {

		guard annotation is Location else {
			return nil
		}
		let identifier = "Location"
		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
		
		if annotationView == nil {
			let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			
			pinView.isEnabled = true
			pinView.canShowCallout = true
			pinView.animatesDrop = false
			pinView.pinTintColor = adaptiveTintColorForTitlesAndButtons
			
			let rightButton: UIButton = {
				let button =  UIButton(type: .detailDisclosure)
				button.tintColor = adaptiveTintColorForTitlesAndButtons
				button.addTarget(self, action: #selector(showLocationDetails), for: .touchUpInside)
				return (button)
			}()
			pinView.rightCalloutAccessoryView = rightButton
			
			annotationView = pinView
		}
		
		if let annotationView = annotationView {
			annotationView.annotation = annotation
			
			let button = annotationView.rightCalloutAccessoryView as! UIButton
			if let index = locations.firstIndex(of: annotation as! Location) {
				button.tag = index
			}
		}
		return (annotationView)
	}
}
