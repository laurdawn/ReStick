import SwiftUI
import ServiceManagement

class Settings: ObservableObject {
    static let shared = Settings()
    
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: Constants.UserDefaults.launchAtLogin)
            setLaunchAtLogin()
        }
    }
    
    @Published var maxHistoryCount: Int = Constants.Clipboard.defaultMaxHistoryCount {
        didSet {
            UserDefaults.standard.set(maxHistoryCount, forKey: Constants.UserDefaults.maxHistoryCount)
        }
    }
    
    private init() {
        self.launchAtLogin = UserDefaults.standard.bool(forKey: Constants.UserDefaults.launchAtLogin)
        self.maxHistoryCount = UserDefaults.standard.integer(forKey: Constants.UserDefaults.maxHistoryCount)
        
        if self.maxHistoryCount == 0 {
            self.maxHistoryCount = Constants.Clipboard.defaultMaxHistoryCount
            UserDefaults.standard.set(self.maxHistoryCount, forKey: Constants.UserDefaults.maxHistoryCount)
        }
    }
    
    private func setLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            try? SMAppService.mainApp.register()
        } else {
            let bundleId = Bundle.main.bundleIdentifier ?? ""
            SMLoginItemSetEnabled(bundleId as CFString, launchAtLogin)
        }
    }
}
