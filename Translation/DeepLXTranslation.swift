import Foundation
import SwiftUI

class DeepLXTranslation: TranslationService {
    @AppStorage("deeplxTranslationEndpoint") private var endpoint = ""
    @AppStorage("translationSourceLang") private var sourceLang = "ZH"
    @AppStorage("translationTargetLang") private var targetLang = "EN"
    
    func translate(text: String) async throws -> String {
        let source = sourceLang.isEmpty ? self.sourceLang : sourceLang
        let target = targetLang.isEmpty ? self.targetLang : targetLang
        
        guard !endpoint.isEmpty else {
            let error = TranslationError.customError(message: "请先在设置中配置DeepLX API URL")
            DispatchQueue.main.async {
                Toast.show(message: error.localizedDescription, duration: 3)
            }
            throw error
        }
        
        guard let url = URL(string: endpoint) else {
            let error = TranslationError.invalidURL
            DispatchQueue.main.async {
                Toast.show(message: error.localizedDescription, duration: 3)
            }
            throw error
        }
        
        let requestBody: [String: Any] = [
            "text": text,
            "source_lang": source,
            "target_lang": target
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("Request body: \(requestBody)")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10
        sessionConfig.timeoutIntervalForResource = 20
        let session = URLSession(configuration: sessionConfig)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TranslationError.requestFailed
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let code = json?["code"] as? Int,
              code == 200,
              let translatedText = json?["data"] as? String else {
            throw TranslationError.invalidResponse
        }
        
        return translatedText
    }
}
