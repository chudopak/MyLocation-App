//
//  CategoryPickerViewController.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 11/20/21.
//

import Foundation
import UIKit

class CategoryPickerViewController : UITableViewController {
	
	var selectedCategory = CategoryCell()
	
	let categories = [
		"No category",
		"MVideo",
		"Bar",
		"Bookstore",
		"Club",
		"Grocery Store",
		"School",
		"Univercity",
		"Park",
		"Landmark"
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.navigationBar.tintColor = adaptiveTintColorForTitlesAndButtons
		view.backgroundColor = adaptiveBackgroundColor
	}
	
	
	//MARK: - UITableViewDataSource
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (categories.count)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		let categoryName = categories[indexPath.row]
		cell.textLabel!.text = categoryName
		
		if selectedCategory.cIndex == indexPath.row {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		cell.backgroundColor = adaptiveBackgroundColor
		return (cell)
	}
	
	//MARK: - UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row != selectedCategory.indexPath.row {
			if let newCell = tableView.cellForRow(at: indexPath) {
				newCell.accessoryType = .checkmark
			}
			if let oldCell = tableView.cellForRow(at: selectedCategory.indexPath) {
				oldCell.accessoryType = .none
			}
			selectedCategory.indexPath = indexPath
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "PickedCategory") {
			let cell = sender as! UITableViewCell
			if let indexPath = tableView.indexPath(for: cell) {
				selectedCategory.name = categories[indexPath.row]
				selectedCategory.cIndex = indexPath.row
			}
		}
	}
}
