//
//  Functions.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 11/22/21.
//

import Foundation
import Dispatch

let applicationDocumentDirectory: URL = {
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	return (paths[0])
}()

func afterDelay(_ seconds: Double, closure:  @escaping () -> ()) {
	DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}
