//
//  Utils.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 11/20/21.
//

import Foundation
import Dispatch

let applicationDocumentDirectory: URL = {
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	return (paths[0])
}()

let MyManagedObjectContextSaveDidFailNotification = Notification.Name(rawValue: 													"MyManagedObjectContexrSaveDidFailNotification")

func fatalCoreDataError(_ error: Error) {
	print("*** Fatal error:\(error)")
	NotificationCenter.default.post(name: MyManagedObjectContextSaveDidFailNotification, object: nil)
}

func afterDelay(_ seconds: Double, closure:  @escaping () -> ()) {
	DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}

class CategoryCell {
	var name: String
	var cIndex: Int
	var indexPath: IndexPath

	init() {
		name = ""
		cIndex = -1
		indexPath = IndexPath(row: cIndex, section: 0)
	}

	convenience init(name: String) {
		self.init()
		self.name = name
	}
}
