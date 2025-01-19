import Foundation
import KeyboardShortcuts

struct Constants {
    // UI Constants
    static let appName = "ReStick"
    static let appDescription = "Clipboard History Manager"
    
    // Window Size
    static let minWindowWidth: CGFloat = 300
    static let minWindowHeight: CGFloat = 200
    
    // Popover Size
    static let popoverWidth: CGFloat = 280
    static let popoverHeight: CGFloat = 400
    
    // Keyboard Shortcuts
    struct Shortcut {
        static let contextMenuShortcut = KeyboardShortcuts.Name("contextMenuShortcut", default: .init(.v, modifiers: [.command, .option]))
        static let translationShortcut = KeyboardShortcuts.Name("translationShortcut", default: .init(.t, modifiers: [.command, .option]))
    }
    
    // Localized Strings
    struct Strings {
        static let launchAtLoginTitle = "Launch at Login"
        static let maxHistoryCountTitle = "Max History Count"
    }
    
    // UserDefaults Keys
    struct UserDefaults {
        static let launchAtLogin = "launchAtLogin"
        static let maxHistoryCount = "maxHistoryCount"
        static let customShortcutKey = "customShortcut"
        static let contextMenuShortcutKey = "contextMenuShortcut"
    }
    
    // Clipboard Settings
    struct Clipboard {
        static let defaultMaxHistoryCount = 10
        static let loggerSubsystem = "com.laurdawn.ReStick"
        static let loggerCategory = "Clipboard"
        static let pollingInterval: TimeInterval = 0.5
    }
    
    struct MenuConfig {
        static let verticalSpacing: CGFloat = 4
        static let verticalPadding: CGFloat = 4
        static let buttonHeight: CGFloat = 28
    }
}
