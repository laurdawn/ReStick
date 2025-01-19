import Foundation
import KeyboardShortcuts
import SwiftUI
import os.log

class ShortcutManager {
    static let shared = ShortcutManager()
    private let logger = Logger(subsystem: Constants.Clipboard.loggerSubsystem, category: "ShortcutManager")
    
    @AppStorage("translationService") private var selectedTranslationService: TranslationServiceEnum = .google
    
    private init() {
        setupShortcuts()
    }
    
    private func setupShortcuts() {
        // 上下文菜单快捷键
        KeyboardShortcuts.onKeyDown(for: Constants.Shortcut.contextMenuShortcut) {
            PopoverManager.shared.showContextMenu()
        }
        
        // 翻译快捷键
        KeyboardShortcuts.onKeyDown(for: Constants.Shortcut.translationShortcut) { [weak self] in
            self?.handleTranslationShortcut()
        }
    }
    
    private func handleTranslationShortcut() {
        // 1. 获取当前剪贴板内容
        guard let clipboardItem = ClipboardManager.shared.lastHistoryItem else { return }
        let text = clipboardItem.content.content
        
        // 2. 获取当前选择的翻译服务
        let translationService = selectedTranslationService.implementation
        
        // 3. 调用翻译API
        Task {
            do {
                logger.debug("Translate text: \(text)")
                let translatedText = try await translationService.translate(text: text)
                
                // 4. 将翻译结果写入系统剪贴板
                if !translatedText.isEmpty {
                    DispatchQueue.main.async {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(translatedText, forType: .string)
                    }
                }
            } catch {
                logger.error("Translation failed: \(error.localizedDescription)")
            }
        }
    }
}
