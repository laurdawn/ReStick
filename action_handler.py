import AppKit
import objc

from constants import UPDATE_INTERVAL


class ActionHandler(AppKit.NSObject):
    def init(self):
        self = objc.super(ActionHandler, self).init()
        if self is None:
            return None

        self.history_manager = None
        self.menu_handler = None
        self.clipboard = AppKit.NSPasteboard.generalPasteboard()
        self.last_change_count = self.clipboard.changeCount()

        # 注册快捷键
        self.registerHotkey()

        return self

    @objc.selector
    def setup_withHistoryManager_menuHandler_(self, sender, history_manager, menu_handler):
        self.history_manager = history_manager
        self.menu_handler = menu_handler

        # 启动剪贴板监听
        AppKit.NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(
            UPDATE_INTERVAL, self, "checkClipboard:", None, True
        )

    def checkClipboard_(self, timer):
        """检查剪贴板内容变化"""
        if self.clipboard.changeCount() != self.last_change_count:
            AppKit.NSLog(f"Clipboard changed: {self.clipboard.changeCount()} (previous: {self.last_change_count})")
            self.last_change_count = self.clipboard.changeCount()
            clipboard_string = self.clipboard.stringForType_(AppKit.NSPasteboardTypeString)
            if clipboard_string:
                AppKit.NSLog(f"New clipboard content: {clipboard_string[:50]}...")
                # 检查是否与最新记录相同
                latest_item = self.history_manager.get_latest()
                if latest_item != clipboard_string:
                    AppKit.NSLog("Adding new item to history")
                    self.history_manager.add(clipboard_string)
                    self.menu_handler.update_menu()

    def registerHotkey(self):
        """注册快捷键 command + option + V"""
        required_modifiers = AppKit.NSCommandKeyMask | AppKit.NSAlternateKeyMask
        AppKit.NSLog("Registering global hotkey monitor")

        # 注册全局快捷键监视器
        monitor = AppKit.NSEvent.addGlobalMonitorForEventsMatchingMask_handler_(
            AppKit.NSKeyDownMask,
            lambda event: self.handleHotkey_(event)
        )

        if monitor:
            AppKit.NSLog("Hotkey monitor registered successfully")
            self.hotkey_monitor = monitor  # 保存监视器对象以便后续使用
        else:
            AppKit.NSLog("Failed to register hotkey monitor")
            raise RuntimeError("Failed to register hotkey monitor")

    @objc.selector
    def handleHotkey_(self, event):
        """处理快捷键事件"""

        # 检查是否是 command + option + V
        required_modifiers = AppKit.NSCommandKeyMask | AppKit.NSAlternateKeyMask
        if (event.keyCode() == 9 and  # V key
                (event.modifierFlags() & required_modifiers) == required_modifiers):
            AppKit.NSLog("Triggering history window show for command + option + V")
            self.menu_handler.showHistoryWindow()

    def selectItem_(self, sender):
        """选择历史记录项"""
        item = sender.representedObject()
        if item:
            # 暂停剪贴板监听
            self.last_change_count = self.clipboard.changeCount() + 1
            
            # 设置剪贴板内容
            self.clipboard.clearContents()
            self.clipboard.setString_forType_(item, AppKit.NSPasteboardTypeString)
            
            # 更新最后修改计数
            self.last_change_count = self.clipboard.changeCount()

    def clearHistory_(self, sender):
        """清空历史记录"""
        # 先暂停剪贴板监听
        self.history_manager.clear()
        self.menu_handler.update_menu()
        # 更新最后修改计数，避免清空后立即添加
        self.last_change_count = self.clipboard.changeCount()

    def terminate_(self, sender):
        """退出应用"""
        AppKit.NSApp.terminate_(None)
