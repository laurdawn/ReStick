import SwiftUI
import os.log
import AppKit

// MARK: - ClipboardContent
struct ClipboardContent: Codable {
    let content: String
}

// MARK: - ClipboardItem
struct ClipboardItem: Identifiable, Equatable, Codable {
    var id = UUID()
    let content: ClipboardContent
    let timestamp: Date
    
    init(content: String) {
        self.content = ClipboardContent(content: content)
        self.timestamp = Date()
    }
    
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.content.content == rhs.content.content &&
               lhs.timestamp == rhs.timestamp
    }
}

class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()
    private var isMonitoring = false
    private var isChecking = false
    private var timer: Timer?
    private lazy var logger = Logger(
        subsystem: Constants.Clipboard.loggerSubsystem,
        category: Constants.Clipboard.loggerCategory
    )
        
    /// 获取最新的剪贴板历史记录项
    /// - Returns: 最新的历史记录项，如果历史记录为空则返回nil
    private(set) var lastHistoryItem: ClipboardItem?

    @Published private(set) var history: [ClipboardItem] = [] {
        didSet {
            // 保存历史记录
            if let encoded = try? JSONEncoder().encode(history) {
                UserDefaults.standard.set(encoded, forKey: "clipboardHistory")
            }
        }
    }
    @AppStorage("maxHistoryCount") var maxHistoryCount = Constants.Clipboard.defaultMaxHistoryCount
    @AppStorage("pollingInterval") var pollingInterval = Constants.Clipboard.pollingInterval {
        didSet {
            // 更新定时器间隔
            timer?.invalidate()
            startMonitoring()
        }
    }
    
    // MARK: - Initialization
    private init() {
        // 加载历史记录
        if let data = UserDefaults.standard.data(forKey: "clipboardHistory"),
           let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            history = decoded
            // 只在初始化时设置 lastHistoryItem
            if lastHistoryItem == nil {
                lastHistoryItem = history.first
            }
        }
        startMonitoring()
    }
    
    // MARK: - Public Methods
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        timer = Timer.scheduledTimer(withTimeInterval: Constants.Clipboard.pollingInterval, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        
        logger.info("Clipboard monitoring started")
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
        logger.info("Clipboard monitoring stopped")
    }
    
    @objc func clearHistory() {
        history.removeAll()
        logger.info("Clipboard history cleared")
    }
    
    private func checkClipboard() {
        guard let content = NSPasteboard.general.string(forType: .string),
              !content.isEmpty else {
            return
        }
        
        // 只在内容不同时更新
        guard lastHistoryItem?.content.content != content else {
            return
        }
        
        guard !isChecking else {
            return
        }
        
        isChecking = true
        
        addToHistory(content)
        lastHistoryItem = ClipboardItem(content: content)
        // 完成所有操作后再重置标志
        isChecking = false
        
    }
    
    func addToHistory(_ content: String) {
        DispatchQueue.main.async {
            let newItem = ClipboardItem(content: content)
            self.history.insert(newItem, at: 0)
            
            // 限制历史记录数量
            if self.history.count > self.maxHistoryCount {
                self.history = Array(self.history.prefix(self.maxHistoryCount))
            }
            
            self.logger.info("New clipboard item added: \(content)")
        }
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Clipboard Operations
    @objc func copyToClipboard(_ sender: NSMenuItem) {
        if let content = sender.representedObject as? String {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(content, forType: .string)
            
            // 添加视觉反馈
            NSHapticFeedbackManager.defaultPerformer.perform(
                .generic,
                performanceTime: .default
            )
        }
    }
}
