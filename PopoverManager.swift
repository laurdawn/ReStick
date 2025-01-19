import AppKit
import SwiftUI

class PopoverManager: NSObject {
    static let shared = PopoverManager()
    
    private var statusBarItem: NSStatusItem?
    private var contentView: ContentView
    
    override init() {
        contentView = ContentView()
        super.init()
    }
    
    func setupStatusBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem?.button {
            button.image = NSImage(named: "ReStickIcon")
        }
    }
    
    func showContextMenu() {
        let menu = NSMenu()
        
        // 添加剪贴板历史记录项
        let historyItems = ClipboardManager.shared.history
        for item in historyItems {
            // 限制菜单项宽度并截断过长的文本
            let maxLength = 30
            let content = item.content.content
            let truncatedContent = content.count > maxLength ? 
                String(content.prefix(maxLength)) + "..." : content
            
            let menuItem = NSMenuItem(
                title: truncatedContent,
                action: #selector(ClipboardManager.shared.copyToClipboard(_:)),
                keyEquivalent: ""
            )
            menuItem.toolTip = content // 添加完整内容作为提示
            menuItem.representedObject = item.content.content
            menuItem.target = ClipboardManager.shared
            menu.addItem(menuItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // 显示在鼠标位置
        let mouseLocation = NSEvent.mouseLocation
        menu.popUp(positioning: nil, at: mouseLocation, in: nil)
    }
}
