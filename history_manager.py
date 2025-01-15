from collections import deque
from constants import MAX_HISTORY_SIZE

class HistoryManager:
    def __init__(self):
        self.history = deque(maxlen=MAX_HISTORY_SIZE)
        
    def add(self, item):
        """添加新的剪贴板内容"""
        if item and item not in self.history:
            self.history.appendleft(item)
            
    def clear(self):
        """清空历史记录"""
        self.history.clear()
        
    def get_all(self):
        """获取所有历史记录"""
        return list(self.history)
        
    def get_latest(self):
        """获取最新的历史记录项"""
        if self.history:
            return self.history[0]
        return None
        
    def get_preview(self, max_length):
        """获取预览格式的历史记录"""
        return [f"{i+1}. {item[:max_length]}" for i, item in enumerate(self.history)]
