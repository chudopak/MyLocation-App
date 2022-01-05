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
	
	lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
		let fetchRequest = NSFetchRequest<Location>()
		
		let entity = Location.entity()
		fetchRequest.entity = entity
		
		let sort1 = NSSortDescriptor(key: "category",
									 ascending: true)
		let sort2 = NSSortDescriptor(key: "date",
									 ascending: true)
		fetchRequest.sortDescriptors = [sort1, sort2]
		
		fetchRequest.fetchBatchSize = 20
		
		let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
																managedObjectContext: self.managedObjectContext,
																sectionNameKeyPath: "category",
																cacheName: "Location")
		fetchResultsController.delegate = self
		return (fetchResultsController)
	} ()
	
	var	managedObjectContext: NSManagedObjectContext!

	deinit {
		fetchedResultsController.delegate = nil
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		_setColors()
		_performFetch()
		navigationItem.rightBarButtonItem = editButtonItem
		navigationItem.rightBarButtonItem?.title = "Edit"
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing,animated:animated)
		if (isEditing) {
			editButtonItem.title = "Done"
		}
		else {
			editButtonItem.title = "Edit"
		}
	}
	
	private func _performFetch() {
		do {
			try fetchedResultsController.performFetch()
		} catch {
			fatalCoreDataError(error)
		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections!.count
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let labelRect = CGRect(x: 15,
							   y: tableView.sectionHeaderHeight - 14,
							   width: UIScreen.main.bounds.width,
							   height: 14)
		let label = UILabel(frame: labelRect)
		label.font = UIFont.boldSystemFont(ofSize: 14)
		label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)
		label.textColor = adaptiveTintColorForTitlesAndButtons
		label.backgroundColor = .clear
		
		let viewRect = CGRect(x: 0,
							  y: 0,
							  width: tableView.bounds.size.width,
							  height: tableView.sectionHeaderHeight)
		let view = UIView(frame: viewRect)
		view.backgroundColor = .clear
		view.addSubview(label)
		return (view)
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sectionInfo = fetchedResultsController.sections![section]
		return (sectionInfo.name.uppercased())
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections![section]
		return (sectionInfo.numberOfObjects)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell",
												 for: indexPath) as! LocationCell
		
		let location = fetchedResultsController.object(at: indexPath)
		cell.backgroundColor = adaptiveBackgroundColor
		cell.configure(for: location)
		return (cell)
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return (58)
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if (editingStyle == .delete) {
			let locationObj = fetchedResultsController.object(at: indexPath)
			locationObj.removePhotFile()
			managedObjectContext.delete(locationObj)
			do {
				try managedObjectContext.save()
			} catch {
				fatalCoreDataError(error)
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if (segue.identifier == "EditLocation") {
			let navigationController = segue.destination as! UINavigationController
			let controller = navigationController.topViewController as! LocationDetailsViewController
			controller.managedObjectContext = managedObjectContext
			if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
				controller.locationToEdit = fetchedResultsController.object(at: indexPath)
			}
		}
	}
	
	private func _setColors() {
		tableView.backgroundColor = adaptiveBackgroundColor
		view.backgroundColor = adaptiveBackgroundColor
		
	}
}

//MARK: - NSGetchedResultsController Delegate Extension
extension LocationViewController : NSFetchedResultsControllerDelegate {
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		print("** Controller Will Change Content")
		tableView.beginUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

		switch type {
		case .insert:
			print("*** NSFetchedResultsChangeInsert (object)")
			tableView.insertRows(at: [newIndexPath!], with: .fade)

		case .delete:
			print("*** NSFetchedResyltsCHengeDelete (object)")
			tableView.deleteRows(at: [indexPath!], with: .fade)
			
		case .update:
			print("*** NSFetchedResyltsChengeUpdate (object)")
			if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
				let location = controller.object(at: indexPath!) as! Location
				cell.configure(for: location)
			}
		
		case .move:
			print("*** NSFetchedresultsChangeMove")
			tableView.deleteRows(at: [indexPath!], with: .fade)
			tableView.insertRows(at: [newIndexPath!], with: .fade)
		
		@unknown default:
			fatalError("Unhandled switch case of NSFetchedResyltsChangeType")
		}
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		switch type {
		case .insert:
			print("*** NSFetchedResultsChangeInsert (section)")
			tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)

		case .delete:
			print("*** NSFetchedResultsChangeDelete (section)")
			tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)

		case .update:
			print("*** NSFetchedResultsChangeUpdate (section)")
		case .move:
			print("*** NSFetchedResultsChangeMove (section)")
		@unknown default:
			fatalError("Unhandled switch case of NSFetchedResultsChangeType")
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		print("*** controllerDidChangeContent")
		tableView.endUpdates()
	}
}
