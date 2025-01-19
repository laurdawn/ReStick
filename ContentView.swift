import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var clipboardManager = ClipboardManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.MenuConfig.verticalSpacing) {
            clipboardHistorySection
                .frame(maxHeight: .infinity)
            Divider()
            actionButtonsSection
            Divider()
            settingsAndExitSection
        }
        .padding(.vertical, Constants.MenuConfig.verticalPadding)
        .frame(minWidth: 200, minHeight: 400)
    }
    
    // MARK: - View Components
    var clipboardHistorySection: some View {
        ClipboardHistorySection()
            .environmentObject(clipboardManager)
    }
    
    private var actionButtonsSection: some View {
            Button {
                clipboardManager.clearHistory()
            } label: {
            HStack {
                Image(systemName: "trash")
                Text("清空剪贴板")
            }
        }
        .buttonStyle(.borderless)
        .frame(maxWidth: .infinity)
    }
    
    private var settingsAndExitSection: some View {
        HStack {
            Button(action: {
                SettingsWindowManager.shared.showSettingsWindow()
            }) {
                HStack {
                    Image(systemName: "gear")
                    Text("设置")
                }
            }
            
            Button(action: { NSApplication.shared.terminate(nil) }) {
                HStack {
                    Image(systemName: "power")
                    Text("退出")
                }
            }
        }
        .buttonStyle(.borderless)
    }
    
}

// MARK: - ClipboardHistorySection
struct ClipboardHistorySection: View {
    @EnvironmentObject private var clipboardManager: ClipboardManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("历史记录数量: \(clipboardManager.history.count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
            ScrollView {
                VStack(alignment: .leading, spacing: Constants.MenuConfig.verticalSpacing) {
                    if clipboardManager.history.isEmpty {
                        Text("暂无历史记录")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(clipboardManager.history) { item in
                            ClipboardItemView(item: item)
                        }
                    }
                }
                .frame(maxWidth: 30)
            }
            .frame(height: 300)
            .background(Color(.windowBackgroundColor))
            .cornerRadius(6)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - ClipboardItemView
struct ClipboardItemView: View {
    let item: ClipboardItem

    var body: some View {
        Button(action: {
            let menuItem = NSMenuItem()
            menuItem.representedObject = item.content.content
            ClipboardManager.shared.copyToClipboard(menuItem)
        }) {
            // 限制文本长度并添加tooltip
            let maxLength = 20
            let content = item.content.content
            let truncatedContent = content.count > maxLength ? 
                String(content.prefix(maxLength)) + "..." : content
            
            Text(truncatedContent)
                .lineLimit(1)
                .truncationMode(.tail)
                .help(content) // 添加完整内容作为tooltip
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}
