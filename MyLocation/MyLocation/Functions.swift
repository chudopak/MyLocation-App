//
//  Functions.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 11/22/21.
//

import Foundation
import Dispatch

func afterDelay(_ seconds: Double, closure:  @escaping () -> ()) {
	DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}
