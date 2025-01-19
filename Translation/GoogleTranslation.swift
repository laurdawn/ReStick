import Foundation
import SwiftUI

class GoogleTranslation: TranslationService {
    @AppStorage("googleTranslationApiKey") private var apiKey = ""
    @AppStorage("translationSourceLang") private var sourceLang = "ZH"
    @AppStorage("translationTargetLang") private var targetLang = "EN"
    
    var name: String { "Google" }
    var icon: String { "g.circle.fill" }
    
    func translate(text: String) async throws -> String {
        let source = sourceLang
        let target = targetLang
        
        guard let url = URL(string: "https://translation.googleapis.com/language/translate/v2?key=\(apiKey)") else {
            throw TranslationError.invalidURL
        }
        
        let requestBody: [String: Any] = [
            "q": text,
            "source": source,
            "target": target,
            "format": "text"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TranslationError.requestFailed
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let translations = (json?["data"] as? [String: Any])?["translations"] as? [[String: Any]],
              let translatedText = translations.first?["translatedText"] as? String else {
            throw TranslationError.invalidResponse
        }
        
        return translatedText
    }
}
