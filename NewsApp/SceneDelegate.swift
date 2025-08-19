//
//  SceneDelegate.swift
//  NewsApp
//
//  Created by Yograj on 18/08/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Create tab bar controller
        let tabBarController = UITabBarController()
        
        // Articles tab
        let articlesStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let articlesVC = articlesStoryboard.instantiateViewController(withIdentifier: "ArticlesVC") as! ArticlesVC
        let articlesNav = UINavigationController(rootViewController: articlesVC)
        articlesNav.tabBarItem = UITabBarItem(title: "News", image: UIImage(systemName: "newspaper"), tag: 0)
        
        // Bookmarks tab
        let bookmarksVC = articlesStoryboard.instantiateViewController(withIdentifier: "BookmarksVC") as! BookmarksVC
        let bookmarksNav = UINavigationController(rootViewController: bookmarksVC)
        bookmarksNav.tabBarItem = UITabBarItem(title: "Bookmarks", image: UIImage(systemName: "bookmark"), tag: 1)
        
        // Configure tab bar
        tabBarController.viewControllers = [articlesNav, bookmarksNav]
        
        // Apply persisted theme to the window
        ThemeManager.applyCurrentTheme(to: window)
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        // Listen for runtime theme changes and re-apply to the window
        NotificationCenter.default.addObserver(forName: ThemeManager.themeDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            ThemeManager.applyCurrentTheme(to: self?.window)
        }
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

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

