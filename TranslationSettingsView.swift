import SwiftUI

struct TranslationSettingsView: View {
    
    enum TranslationServiceCategory: String, CaseIterable {
        case general = "通用"
        case deeplx = "DeepLX"
        case google = "Google"
        case deepseek = "DeepSeek"
    }
    
    @State private var selectedService: TranslationServiceCategory = .general
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("", selection: $selectedService) {
                ForEach(TranslationServiceCategory.allCases, id: \.self) { service in
                    Text(service.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            switch selectedService {
            case .general:
                GeneralTranslationSettingsView()
            case .deeplx:
                DeeplxSettingsView()
            case .google:
                GoogleSettingsView()
            case .deepseek:
                DeepSeekSettingsView()
            }
        }
        .padding()
    }
}

struct GeneralTranslationSettingsView: View {
    @AppStorage("translationSourceLang") private var sourceLang = "ZH"
    @AppStorage("translationTargetLang") private var targetLang = "EN"
    @AppStorage("translationService") private var selectedTranslationService: TranslationServiceEnum = .google
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("通用设置")
                .font(.headline)
            
            HStack {
                Text("翻译服务:")
                Picker("", selection: $selectedTranslationService) {
                    ForEach(TranslationServiceEnum.allCases, id: \.self) { service in
                        Text(service.rawValue)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
            }
            
            HStack {
                Text("源语言:")
                TextField("源语言", text: $sourceLang)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
            }
            
            HStack {
                Text("目标语言:")
                TextField("目标语言", text: $targetLang)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
            }
        }
    }
}

struct DeeplxSettingsView: View {
    @AppStorage("deeplxTranslationEndpoint") private var endpoint = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("DeepLX 设置")
                .font(.headline)
            
            HStack {
                Text("API URL:")
                TextField("API URL", text: $endpoint)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}

struct GoogleSettingsView: View {
    @AppStorage("googleTranslationApiKey") private var apiKey = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Google 设置")
                .font(.headline)
            
            HStack {
                Text("API Key:")
                TextField("API Key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}

struct DeepSeekSettingsView: View {
    @AppStorage("deepseekTranslationApiKey") private var apiKey = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("DeepSeek 设置")
                .font(.headline)
            
            HStack {
                Text("API Key:")
                TextField("API Key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}

#Preview {
    TranslationSettingsView()
}
