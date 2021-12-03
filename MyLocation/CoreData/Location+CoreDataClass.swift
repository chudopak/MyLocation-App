//
//  Location+CoreDataClass.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 11/24/21.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {

	public var coordinate: CLLocationCoordinate2D {
		return (CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
	}
	
	public var title: String? {
		get {
			if locationDescription.isEmpty {
				return ("(No description)")
			} else {
				return (locationDescription)
			}
		}
	}
	
	public var subtitle: String? {
		get {
			return (category)
		}
	}
	
}
