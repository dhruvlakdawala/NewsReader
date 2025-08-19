//
//  ThemeManager.swift
//  NewsApp
//
//  Created by Yograj on 19/08/25.
//

import UIKit

// MARK: - AppTheme Enum
/// Represents the available themes in the app.
enum AppTheme: Int, CaseIterable {
    case system = 0   /// Matches the system appearance (light/dark based on device settings).
    case light = 1    /// Forces light mode.
    case dark = 2     /// Forces dark mode.
    
    /// A human-readable name for each theme, useful for UI (like Settings screens).
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    /// Maps each theme to a corresponding `UIUserInterfaceStyle`.
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - ThemeManager
/// Handles persisting and applying the app’s current theme.
/// - Uses `UserDefaults` to store the theme selection.
/// - Posts a notification when the theme changes so the UI can respond.
final class ThemeManager {
    
    /// Singleton instance for global access.
    static let shared = ThemeManager()
    
    /// Prevents external initialization.
    private init() {}
    
    /// Notification posted whenever the theme changes.
    static let themeDidChangeNotification = Notification.Name("ThemeManager.themeDidChange")
    
    /// Key used for persisting the selected theme in `UserDefaults`.
    private let storageKey = "AppTheme"
    
    /// Returns the current theme (persisted in `UserDefaults`).
    /// Setting this updates storage and notifies observers if the theme changes.
    var currentTheme: AppTheme {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: storageKey)
            return AppTheme(rawValue: rawValue) ?? .system
        }
        set {
            let oldTheme = currentTheme
            guard newValue != oldTheme else { return } // Avoid unnecessary updates
            UserDefaults.standard.set(newValue.rawValue, forKey: storageKey)
            
            // Notify observers that the theme has changed
            NotificationCenter.default.post(name: ThemeManager.themeDidChangeNotification, object: newValue)
        }
    }
    
    /// Applies the current theme to the given window.
    /// - Parameter window: The main app window (usually from SceneDelegate or AppDelegate).
    ///
    /// This method also configures navigation and tab bar appearances
    /// so they look consistent across light/dark modes.
    func applyTheme(to window: UIWindow?) {
        guard let window = window else { return }
        
        if #available(iOS 13.0, *) {
            // Apply the theme to the window
            window.overrideUserInterfaceStyle = currentTheme.userInterfaceStyle
            
            // Configure Navigation Bar appearance
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithDefaultBackground()
            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
            UINavigationBar.appearance().compactAppearance = navAppearance
            
            // Configure Tab Bar appearance
            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithDefaultBackground()
            UITabBar.appearance().standardAppearance = tabAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
    }
    
    /// Convenience method to apply the currently saved theme.
    /// - Parameter window: The main app window.
    static func applyCurrentTheme(to window: UIWindow?) {
        ThemeManager.shared.applyTheme(to: window)
    }
}
