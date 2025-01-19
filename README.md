# ReStick - 高效的macOS剪贴板工具

## 核心功能

- **剪贴板管理**：历史记录、快速访问
- **快捷操作**：自定义快捷键，提升效率
- **多引擎翻译**：集成DeepLX、DeepSeek（TODO）、Google（TODO）翻译

## 使用说明

**快捷键操作：**
- Command + Option + V：打开剪贴板历史
- Command + Option + T：翻译选中文本，翻译后的文本自动写入剪贴板

## 项目结构

```
ReStick/
├── Translation/      # 翻译服务
│   ├── DeepLXTranslation.swift
│   ├── DeepSeekTranslation.swift  
│   └── GoogleTranslation.swift
├── Utils/            # 工具类
│   └── Toast.swift
├── ClipboardManager.swift
├── Constants.swift
├── ContentView.swift
└── ReStickApp.swift
```

## TODO

1. 日志
2. google接入翻译
3. deepSeek接入翻译

## 许可证

Apache License 2.0 - 详见 [LICENSE](LICENSE)
