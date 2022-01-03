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
	
	var hasPhoto: Bool {
		return photoID != nil
	}
	
	var photoURL: URL {
		assert(photoID != nil, "No photo ID set")
		let filename = "Photo-\(photoID!.intValue).jpg"
		return (applicationDocumentDirectory.appendingPathComponent(filename))
	}
	
	var photoImage: UIImage? {
		return (UIImage(contentsOfFile: photoURL.path))
	}
	
	class func nextPhotoID() -> Int {
		let userDefaults = UserDefaults.standard
		let currentID = userDefaults.integer(forKey: "PhotoID") + 1
		userDefaults.set(currentID, forKey: "PhotoID")
		userDefaults.synchronize()
		return (currentID)
	}
	
	func removePhotFile() {
		if (hasPhoto) {
			do {
				try FileManager.default.removeItem(at: photoURL)
			} catch {
				print("Error romoving file: \(error)")
			}
		}
	}
}
