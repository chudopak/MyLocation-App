//
//  ConstantValues.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 1/3/22.
//

import Foundation
import UIKit

let darkThemeBackgroundColor = UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1)
let lightThemeBackgroundColor = UIColor(red: 248 / 255, green: 245 / 255, blue: 238 / 255, alpha: 1)
let adaptiveBackgroundColor = UIColor { tc in
	switch tc.userInterfaceStyle {
	case .dark:
		return (darkThemeBackgroundColor)
	default:
		return (lightThemeBackgroundColor)
	}
}

let darkThemeTintColor = UIColor(red: 256 / 256, green: 256 / 256, blue: 256 / 256, alpha: 1)
let lightThemeTintColor = UIColor(red: 0 / 256, green: 0 / 256, blue: 0 / 256, alpha: 1)
let adaptiveTintColorRegular = UIColor { tc in
	switch tc.userInterfaceStyle {
	case .dark:
		return (darkThemeTintColor)
	default:
		return (lightThemeTintColor)
	}
}


let darkThemeTintColorYellow = UIColor(red: 255 / 256, green: 214 / 256, blue: 10 / 256, alpha: 1)
let lightThemeTintColorPurple = UIColor(red: 82 / 256, green: 15 / 256, blue: 45 / 256, alpha: 1)
let adaptiveTintColorForTitlesAndButtons = UIColor { tc in
	switch tc.userInterfaceStyle {
	case .dark:
		return (darkThemeTintColorYellow)
	default:
		return (lightThemeTintColorPurple)
	}
}


let darkThemeBarsColor = UIColor(red: 32 / 256, green: 32 / 256, blue: 32 / 256, alpha: 1)
let lightThemeBarsColor = UIColor(red: 238 / 256, green: 235 / 256, blue: 228 / 256, alpha: 1)
let adaptiveBarsColor = UIColor { tc in
	switch tc.userInterfaceStyle {
	case .dark:
		return (darkThemeBarsColor)
	default:
		return (lightThemeBarsColor)
	}
}

let darkThemeBlackAndWhite = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
let lightThemeBlackAndWhite = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
let adaptiveBlackAndWhite = UIColor { tc in
	switch tc.userInterfaceStyle {
	case .dark:
		return (darkThemeBlackAndWhite)
	default:
		return (lightThemeBlackAndWhite)
	}
}

let darkThemeTintColorAdress = UIColor(red: 256 / 256, green: 256 / 256, blue: 256 / 256, alpha: 0)
let lightThemeTintColorAdress = UIColor(red: 0 / 256, green: 0 / 256, blue: 0 / 256, alpha: 0)
let adaptiveTintColorRegularAdress = UIColor { tc in
	switch tc.userInterfaceStyle {
	case .dark:
		return (darkThemeTintColor)
	default:
		return (lightThemeTintColor)
	}
}

