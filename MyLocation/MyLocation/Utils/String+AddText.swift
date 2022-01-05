//
//  String+AddText.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 1/3/22.
//

import UIKit

extension String {
	mutating func add(text: String?, separatedBy separator: String = "") {
		if let text = text {
			if !isEmpty {
				self += separator
			}
			self += text
		}
	}
}
