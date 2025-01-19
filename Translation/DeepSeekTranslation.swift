import Foundation
import SwiftUI

class DeepSeekTranslation: TranslationService {
    @AppStorage("deepseekTranslationApiKey") private var apiKey = ""
    @AppStorage("translationSourceLang") private var sourceLang = "ZH"
    @AppStorage("translationTargetLang") private var targetLang = "EN"
    
    func translate(text: String) async throws -> String {
        guard let url = URL(string: "https://api.deepseek.com/v1/chat/completions") else {
            throw TranslationError.invalidURL
        }
        
        let systemPrompt = """
        你是一个中英文翻译专家，将用户输入的中文翻译成英文，或将用户输入的英文翻译成中文。对于非中文内容，
        它将提供中文翻译结果。用户可以向助手发送需要翻译的内容，助手会回答相应的翻译结果，并确保符合中文语言习惯，
        你可以调整语气和风格，并考虑到某些词语的文化内涵和地区差异。同时作为翻译家，需将原文翻译成具有信达雅标准的译文。
        "信" 即忠实于原文的内容与意图；"达" 意味着译文应通顺易懂，表达清晰；"雅" 则追求译文的文化审美和语言的优美。
        目标是创作出既忠于原作精神，又符合目标语言文化和读者审美的翻译。
        """
        
        let requestBody: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                [
                    "role": "system",
                    "content": systemPrompt
                ],
                [
                    "role": "user",
                    "content": text
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TranslationError.requestFailed
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = json?["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let translatedText = message["content"] as? String else {
            throw TranslationError.invalidResponse
        }
        
        return translatedText
    }
}
