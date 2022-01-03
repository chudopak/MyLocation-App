//
//  SceneDelegate.swift
//  MyLocation
//
//  Created by Stepan Kirillov on 11/12/21.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	
	lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext

	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "DataModel")
		container.loadPersistentStores(completionHandler: {
			storeDescription, error in
			if let error = error {
				fatalCoreDataError(error)
			}
		})
		return (container)
	}()


	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		guard let _ = (scene as? UIWindowScene) else { return }
		_setColorsForBars()
		_passManagedObjectContextToCurrentLocationViewController()
		listenForFatalCoreDataNotifications()
		print(applicationDocumentDirectory)
	}

	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}

	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.
	}
	

	
	private func _passManagedObjectContextToCurrentLocationViewController() {
		let tabBarController = window!.rootViewController as! UITabBarController
		
		if let tabBarViewControllers = tabBarController.viewControllers {
			let currentLocationViewController = tabBarViewControllers[0] as! CurrentLocationViewController
			currentLocationViewController.managedObjectContext = managedObjectContext
			
			var navController = tabBarViewControllers[1] as! UINavigationController
			let controller2 = navController.viewControllers.first as! LocationViewController
			controller2.managedObjectContext = managedObjectContext
			
			navController = tabBarViewControllers[2] as! UINavigationController
			let controller3 = navController.viewControllers.first as! MapViewController
			controller3.managedObjectContext = managedObjectContext
		}
	}
	
	func listenForFatalCoreDataNotifications() {
		NotificationCenter.default.addObserver(forName: MyManagedObjectContextSaveDidFailNotification,
											   object: nil,
											   queue: OperationQueue.main) {
			notification in
			let alert = UIAlertController(title: "Internal Error",
										  message: "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app. Sorry for the inconvenience.",
										  preferredStyle: .alert)
			let action = UIAlertAction(title: "OK", style: .default) { _ in
				let exception = NSException(name: NSExceptionName.internalInconsistencyException,
											reason: "Fatal Core Data Error",
											userInfo: nil)
				exception.raise()
			}
			alert.addAction(action)
			self.viewControllerForShowingAlert().present(alert, animated: true, completion: nil)
		}
	}
	
	func viewControllerForShowingAlert() -> UIViewController {
		let rootViewController = self.window!.rootViewController!
		if let presentedViewController = rootViewController.presentedViewController {
			return (presentedViewController)
		} else {
			return (rootViewController)
		}
	}
	
	private func _setColorsForBars() {
		UINavigationBar.appearance().barTintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeBarsColor)
			default:
				return (lightThemeBarsColor)
			}
		}
		UINavigationBar.appearance().titleTextAttributes = [
			NSAttributedString.Key.foregroundColor:
				UIColor { tc in
					switch tc.userInterfaceStyle {
					case .dark:
						return (darkThemeTintColorYellow)
					default:
						return (lightThemeTintColorPurple)
					}
				}
		]
		UITabBar.appearance().barTintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeBarsColor)
			default:
				return (lightThemeBarsColor)
			}
		}
		UITabBar.appearance().tintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeTintColorYellow)
			default:
				return (lightThemeTintColorPurple)
			}
		}
	}
	
}

