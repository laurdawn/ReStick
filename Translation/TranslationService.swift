import Foundation

protocol TranslationService {
    func translate(text: String) async throws -> String
}

enum TranslationServiceEnum: String, CaseIterable {
    case google = "Google Translate"
    case deeplx = "DeepLX"
    case deepSeek = "DeepSeek AI Translator"
    
    var implementation: TranslationService {
        switch self {
        case .google:
            return GoogleTranslation()
        case .deeplx:
            return DeepLXTranslation()
        case .deepSeek:
            return DeepSeekTranslation()
        }
    }
}

enum TranslationError: Error {
    case invalidURL
    case requestFailed
    case invalidResponse
    case customError(message: String)
}

extension TranslationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .requestFailed:
            return "Translation request failed"
        case .invalidResponse:
            return "Invalid translation response"
        case .customError(let message):
            return message
        }
    }
}
