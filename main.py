import AppKit
import objc
import PyObjCTools.AppHelper
from history_manager import HistoryManager
from menu_handler import MenuHandler
from action_handler import ActionHandler

class ClipboardHistoryApp(AppKit.NSObject):
    def init(self):
        self = objc.super(ClipboardHistoryApp, self).init()
        if self is None:
            return None
            
        # 初始化历史记录管理器
        self.history_manager = HistoryManager()
        
        # 初始化Action处理器
        self.action_handler = ActionHandler.alloc().init()
        
        # 初始化菜单处理器
        self.menu_handler = MenuHandler(self.history_manager, self.action_handler)
        
        # 设置action handler
        self.action_handler.setup_withHistoryManager_menuHandler_(
            None, self.history_manager, self.menu_handler
        )
        
        return self

if __name__ == "__main__":
    app = AppKit.NSApplication.sharedApplication()
    delegate = ClipboardHistoryApp.alloc().init()
    app.setDelegate_(delegate)
    PyObjCTools.AppHelper.runEventLoop()
