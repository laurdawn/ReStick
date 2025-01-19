import SwiftUI
import KeyboardShortcuts
import ServiceManagement

struct SettingsView: View {
    @State private var selectedSetting: SettingCategory = .general
    @State private var selectedTab = 0
    
    enum SettingCategory: String, CaseIterable {
        case general = "General"
        case translation = "Translation"
    }
    @AppStorage("maxHistoryCount") private var maxHistoryCount = Constants.Clipboard.defaultMaxHistoryCount
    @AppStorage("pollingInterval") private var pollingInterval = Constants.Clipboard.pollingInterval
    @AppStorage("translationService") private var selectedTranslationService: TranslationServiceEnum = .google
    @AppStorage("launchAtLogin") private var launchAtLogin = false {
        didSet {
            let identifier = "com.yourcompany.ReStickLauncher" as CFString
            SMLoginItemSetEnabled(identifier, launchAtLogin)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("", selection: $selectedSetting) {
                ForEach(SettingCategory.allCases, id: \.self) { category in
                    Text(category.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            switch selectedSetting {
            case .general:
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("General")
                            .font(.headline)
                        
                        Toggle("Launch at login", isOn: $launchAtLogin)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("History Clipboard Shortcut:")
                                    .frame(width: 160, alignment: .leading)
                                Spacer()
                                KeyboardShortcuts.Recorder(for: Constants.Shortcut.contextMenuShortcut)
                                    .frame(width: 150)
                            }
                            
                            HStack {
                                Text("Translation Shortcut:")
                                    .frame(width: 160, alignment: .leading)
                                Spacer()
                                KeyboardShortcuts.Recorder(for: Constants.Shortcut.translationShortcut)
                                    .frame(width: 150)
                            }
                        }
                        
                    }
                    .padding(.vertical)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Clipboard Settings")
                            .font(.headline)
                        
                        Stepper(value: $maxHistoryCount, in: 10...1000, step: 10) {
                            Text("Max History Count: \(maxHistoryCount)")
                        }
                        
                        Stepper(value: $pollingInterval, in: 0.1...5.0, step: 0.1) {
                            Text("Polling Interval: \(pollingInterval, specifier: "%.1f")s")
                        }
                    }
                    .padding(.vertical)
                }
                .padding()
                
            case .translation:
                TranslationSettingsView()
            }
        }
        .padding()
    }
}

struct SettingsWindowView: View {
    var body: some View {
        SettingsView()
    }
}

class SettingsWindowManager {
    private var settingsWindow: NSWindow?
    static let shared = SettingsWindowManager()
    
    private init() {}
    
    func showSettingsWindow() {
        if let existingWindow = settingsWindow {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 550, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Settings"
        window.contentView = NSHostingView(rootView: SettingsWindowView())
        window.isReleasedWhenClosed = false
        
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        self.settingsWindow = window
    }
}

#Preview {
    SettingsView()
}
