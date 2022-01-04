//
//  Utils.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 11/20/21.
//

import Foundation

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
