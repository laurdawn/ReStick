import AppKit
import objc
from constants import MENU_ITEM_MAX_LENGTH, HISTORY_WINDOW_WIDTH, HISTORY_WINDOW_HEIGHT

class ClipboardMenu(AppKit.NSObject):
    @objc.selector
    def initWithActionHandler_(self, action_handler=None):
        self = objc.super(ClipboardMenu, self).init()
        if self is not None:
            self.menu = AppKit.NSMenu.alloc().init()
            self.menu.setAutoenablesItems_(False)
            self.action_handler = action_handler
            AppKit.NSLog(f"Info: NSMenu created")
        return self
    
    def show_menu(self, items):
        """
        显示菜单
        :param items: 要显示的文本列表
        """
        # 清空旧菜单项
        while self.menu.numberOfItems() > 0:
            self.menu.removeItemAtIndex_(0)
            
        # 添加新菜单项
        for text in items:
            item = AppKit.NSMenuItem.alloc().initWithTitle_action_keyEquivalent_(
                text,  # 显示的文本
                'selectItem:',  # 点击处理
                ''  # 快捷键，这里设为空
            )
            item.setTarget_(self.action_handler)
            item.setRepresentedObject_(text)
            self.menu.addItem_(item)
            
        # 获取鼠标位置
        mouse_location = AppKit.NSEvent.mouseLocation()
        # 在鼠标位置显示菜单
        self.menu.popUpMenuPositioningItem_atLocation_inView_(
            None,  # 定位项，None 表示从第一项开始
            mouse_location,  # 显示位置
            None  # 相对视图，None 表示使用屏幕坐标
        )
    
class MenuHandler:
    def __init__(self, history_manager, action_handler=None):
        self.history_manager = history_manager
        self.action_handler = action_handler
        
        # 创建状态栏菜单
        self.status_item = AppKit.NSStatusBar.systemStatusBar().statusItemWithLength_(
            AppKit.NSVariableStatusItemLength
        )
        self.status_item.setTitle_("📋")
        
        # 创建菜单
        self.menu = AppKit.NSMenu.alloc().init()
        self.status_item.setMenu_(self.menu)
        
        # 预先创建历史窗口
        self.clipboard_window = ClipboardMenu.alloc().initWithActionHandler_(self.action_handler)
        
        self.update_menu()
        
    def update_menu(self):
        """更新菜单内容"""
        self.menu.removeAllItems()
        
        # 添加历史记录
        for preview, full_text in zip(
            self.history_manager.get_preview(MENU_ITEM_MAX_LENGTH),
            self.history_manager.get_all()
        ):
            menu_item = AppKit.NSMenuItem.alloc().initWithTitle_action_keyEquivalent_(
                preview, "selectItem:", ""
            )
            menu_item.setTarget_(self.action_handler)
            menu_item.setToolTip_(full_text)  # 鼠标悬停显示完整内容
            menu_item.setRepresentedObject_(full_text)
            self.menu.addItem_(menu_item)
            
        # 添加分隔线
        self.menu.addItem_(AppKit.NSMenuItem.separatorItem())
        
        # 添加清空历史选项
        clear_item = AppKit.NSMenuItem.alloc().initWithTitle_action_keyEquivalent_(
            "清空历史", "clearHistory:", ""
        )
        clear_item.setTarget_(self.action_handler)
        self.menu.addItem_(clear_item)
        
        # 添加退出选项
        quit_item = AppKit.NSMenuItem.alloc().initWithTitle_action_keyEquivalent_(
            "退出", "terminate:", ""
        )
        quit_item.setTarget_(self.action_handler)
        self.menu.addItem_(quit_item)

    def showHistoryWindow(self):
        """显示历史剪贴板窗口"""
        
        # 获取历史记录并显示菜单
        history_items = self.history_manager.get_all()
        self.clipboard_window.show_menu(history_items)
