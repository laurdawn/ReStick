import SwiftUI
import AppKit
@main
struct ReStickApp: App {
    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
        // 初始化快捷键管理器
        _ = ShortcutManager.shared
        // 初始化状态栏
        PopoverManager.shared.setupStatusBar()
    }
    
    var body: some Scene {
        MenuBarExtra("历史剪贴板", systemImage: "clipboard") {
            ContentView()
        }
        .menuBarExtraStyle(.menu)
    }
}
