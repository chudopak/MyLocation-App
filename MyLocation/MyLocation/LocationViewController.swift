//
//  LocationViewController.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 11/29/21.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class LocationViewController : UITableViewController {
	
	var	locations = [Location]()
	
	var	managedObjectContext: NSManagedObjectContext!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let	fetchRequest = NSFetchRequest<Location>()
		
		let entity = Location.entity()
		fetchRequest.entity = entity
		
		let	sortDescriptor = NSSortDescriptor(key: "date",
											  ascending: true)
		
		fetchRequest.sortDescriptors = [sortDescriptor]
		do {
			locations = try managedObjectContext.fetch(fetchRequest)
		} catch {
			fatalCoreDataError(error)
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (locations.count)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell",
												 for: indexPath)
		
		let location = locations[indexPath.row]
		
		let descriptionLabel = cell.viewWithTag(100) as! UILabel
		descriptionLabel.text = location.locationDescription != "" ? location.locationDescription : "NoDescription"
		
		let addressLabel = cell.viewWithTag(101) as! UILabel
		if let placemark = location.placemark {
			var text = ""
			if let s = placemark.subThoroughfare {
				text = s + " "
			}
			if let s = placemark.thoroughfare {
				text += s + ", "
			}
			if let s = placemark.locality {
				text += s
			}
			addressLabel.text = text
		} else {
			addressLabel.text = ""
		}
		return (cell)
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return (58)
	}
	
}
