//
//  APIConfig.swift
//  Keyboard
//
//  Created by Zainab on 10.07.2025.
//

import Foundation

struct APIConfig {
    // MARK: - API Configuration
    
    /// Base URL для API сервера
    /// Измените на ваш реальный URL сервера
    static let baseURL: String = {
        #if DEBUG
        // Для разработки - продакшн сервер с SSL
        return "https://muslimaikeyboard.tech"
        #else
        // Для продакшена - ваш сервер с SSL
        return "https://muslimaikeyboard.tech"
        #endif
    }()
    
    /// Таймаут для запросов (в секундах)
    static let requestTimeout: TimeInterval = 180.0 // 3 минуты для генерации стикеров (сервер отвечает за ~26 секунд)
    
    /// Максимальный размер изображения для загрузки (в байтах)
    static let maxImageSize: Int = 10 * 1024 * 1024 // 10 MB
    
    /// User Agent для запросов
    static let userAgent = "Muslim AI Keyboard iOS/1.0"
    
    /// Максимальное количество попыток повторного запроса
    static let maxRetryAttempts = 3
    
    /// Задержка между попытками (в секундах)
    static let retryDelay: TimeInterval = 2.0
    
    // MARK: - API Endpoints
    
    enum Endpoint: String {
        case health = "/health"
        case generateSticker = "/generate-sticker"
        case examples = "/examples"
        
        var url: URL? {
            return URL(string: APIConfig.baseURL + self.rawValue)
        }
    }
    
    // MARK: - Development Settings
    
    /// Включить подробное логирование API запросов
    static let enableVerboseLogging: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    /// Использовать fallback режим если API недоступен
    static let enableFallbackMode = true
    
    /// Автоматически проверять здоровье API при запуске
    static let autoCheckHealth = false
    
    // MARK: - Helper Methods
    
    /// Проверить, является ли URL валидным
    static func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return url.scheme != nil && url.host != nil
    }
    
    /// Получить заголовки по умолчанию для запросов
    static func defaultHeaders() -> [String: String] {
        let languageCode: String
        if #available(iOS 16.0, *) {
            languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        } else {
            languageCode = Locale.current.languageCode ?? "en"
        }

        return [
            "Content-Type": "application/json",
            "User-Agent": userAgent,
            "Accept": "application/json",
            "Accept-Language": languageCode
        ]
    }
    
    /// Логирование для разработки
    static func log(_ message: String, level: LogLevel = .info) {
        guard enableVerboseLogging else { return }
        
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        let prefix = level.prefix
        
        print("[\(timestamp)] \(prefix) API: \(message)")
    }
    
    enum LogLevel {
        case info, warning, error, success
        
        var prefix: String {
            switch self {
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            case .success: return "✅"
            }
        }
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}

// MARK: - API Configuration Instructions

/*
 📋 НАСТРОЙКА API СЕРВЕРА:
 
 1. ТЕКУЩИЙ СЕРВЕР:
    - Сервер развернут на https://muslimaikeyboard.tech
    - Убедитесь, что сервер доступен по адресу https://muslimaikeyboard.tech
    - Проверьте эндпоинт /health: curl https://muslimaikeyboard.tech/health
 
 2. ПРОДАКШЕН:
    - Измените baseURL на ваш реальный сервер
    - Убедитесь, что сервер поддерживает HTTPS
    - Настройте CORS для iOS приложения
 
 3. ТЕСТИРОВАНИЕ API:
    - Используйте /health для проверки доступности
    - Тестируйте /generate-sticker с простыми фразами
    - Проверьте /examples для получения примеров
 
 4. БЕЗОПАСНОСТЬ:
    - Добавьте API ключи если необходимо
    - Настройте rate limiting на сервере
    - Используйте HTTPS в продакшене
 
 5. МОНИТОРИНГ:
    - Включите логирование в DEBUG режиме
    - Отслеживайте ошибки и время ответа
    - Настройте fallback режим для офлайн работы
 
 📱 ИСПОЛЬЗОВАНИЕ В ПРИЛОЖЕНИИ:
 
 // Проверка здоровья API
 let isHealthy = await StickerAPIService.shared.checkAPIHealth()
 
 // Генерация стикера
 let result = try await StickerAPIService.shared.generateSticker(phrase: "бисмиллах")
 
 // Получение примеров
 let examples = try await StickerAPIService.shared.getExamples()
 
 🔧 ОТЛАДКА:
 
 - Проверьте консоль Xcode на наличие API логов
 - Убедитесь, что сервер запущен и доступен
 - Проверьте сетевые настройки симулятора/устройства
 - Используйте Network Link Conditioner для тестирования медленной сети
 
 ⚠️ ВАЖНО:
 
 - В симуляторе iOS localhost указывает на Mac, а не на симулятор
 - На реальном устройстве используйте IP адрес Mac для локального тестирования
 - Убедитесь, что firewall не блокирует подключения к серверу
 */
