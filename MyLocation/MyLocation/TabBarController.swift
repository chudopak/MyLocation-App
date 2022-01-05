//
//  ViewController.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 11/12/21.
//

import UIKit

class TabBarController: UITabBarController {

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		switch traitCollection.userInterfaceStyle {
		case .dark:
			return .lightContent
		default:
			return .darkContent
		}
	}
	override var childForStatusBarStyle: UIViewController? {
		return nil
	}

}

