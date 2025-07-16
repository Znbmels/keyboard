//
//  StickerAPIService.swift
//  Keyboard
//
//  Created by Zainab on 10.07.2025.
//

import Foundation
import UIKit

// MARK: - API Models
struct EmptyBody: Codable {
    // Пустая структура для запросов без тела
}

struct StickerGenerationRequest: Codable {
    let phrase: String
    let username: String

    init(phrase: String, username: String = "ios_user") {
        self.phrase = phrase
        self.username = username
    }
}

// Альтернативные структуры запроса, которые может ожидать бекенд
struct AlternativeRequest1: Codable {
    let text: String
    let user: String

    init(phrase: String, username: String = "ios_user") {
        self.text = phrase
        self.user = username
    }
}

struct AlternativeRequest2: Codable {
    let prompt: String

    init(phrase: String) {
        self.prompt = phrase
    }
}

struct AlternativeRequest3: Codable {
    let message: String
    let type: String

    init(phrase: String) {
        self.message = phrase
        self.type = "sticker"
    }
}

// MARK: - Async API Models
struct StickerTaskResponse: Codable {
    let success: Bool
    let taskId: String
    let message: String
    let estimatedTime: Int

    enum CodingKeys: String, CodingKey {
        case success, message
        case taskId = "task_id"
        case estimatedTime = "estimated_time"
    }
}

struct TaskStatusResponse: Codable {
    let taskId: String
    let status: TaskStatus
    let progress: Int
    let currentStep: String
    let createdAt: String
    let updatedAt: String
    let errorMessage: String?
    let estimatedRemaining: Int?

    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case status, progress
        case currentStep = "current_step"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case errorMessage = "error_message"
        case estimatedRemaining = "estimated_remaining"
    }
}

enum TaskStatus: String, Codable {
    case pending = "pending"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
}

struct StickerGenerationResponse: Codable {
    let success: Bool
    let message: String
    let imageUrl: String?
    let contentType: String?
    let generationTime: Double?
    let analysis: APIAnalysis?
    let isIslamic: Bool?

    enum CodingKeys: String, CodingKey {
        case success, message, contentType, analysis
        case imageUrl = "image_url"
        case generationTime = "generation_time"
        case isIslamic = "is_islamic"
    }
}

struct APIAnalysis: Codable {
    let contentType: String
    let meaning: String
    let emotion: String
    let context: String
    let recommendedStyle: String
    let recommendedColors: [String]
    let hasUserColorRequest: Bool
    
    enum CodingKeys: String, CodingKey {
        case contentType = "content_type"
        case meaning, emotion, context
        case recommendedStyle = "recommended_style"
        case recommendedColors = "recommended_colors"
        case hasUserColorRequest = "has_user_color_request"
    }
}

struct APIHealthResponse: Codable {
    let status: String
    let agents: APIAgents
    let version: String
    let islamicCompliance: String
    
    enum CodingKeys: String, CodingKey {
        case status, agents, version
        case islamicCompliance = "islamic_compliance"
    }
}

struct APIAgents: Codable {
    let promptAgent: String
    let imageAgent: String
    let saveAgent: String
    
    enum CodingKeys: String, CodingKey {
        case promptAgent = "prompt_agent"
        case imageAgent = "image_agent"
        case saveAgent = "save_agent"
    }
}

struct APIExamplesResponse: Codable {
    let textualExamples: [String]
    let visualExamples: [String]
    let note: String?
    
    enum CodingKeys: String, CodingKey {
        case textualExamples = "textual_examples"
        case visualExamples = "visual_examples"
        case note
    }
}

struct APITestResponse: Codable {
    let status: String
    let message: String
    let timestamp: String
    let cors: String
}

struct APIErrorResponse: Codable {
    let detail: String?
    let message: String?
    let error: String?

    var errorMessage: String {
        return detail ?? message ?? error ?? "Unknown error"
    }
}

// MARK: - API Service
final class StickerAPIService: ObservableObject {
    static let shared = StickerAPIService()

    // Конфигурация API
    let baseURL = APIConfig.baseURL
    private let timeout = APIConfig.requestTimeout

    // Настроенная URLSession с timeout для AI генерации
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout // 180 секунд для запроса
        config.timeoutIntervalForResource = timeout * 2 // 360 секунд для ресурса
        config.waitsForConnectivity = true // Ждать подключения к сети
        config.allowsCellularAccess = true // Разрешить мобильный интернет
        config.httpMaximumConnectionsPerHost = 2 // Максимум 2 соединения
        return URLSession(configuration: config)
    }()

    @Published var isConnected = false
    @Published var lastError: String?

    private init() {
        // Инициализируем с базовыми значениями
        self.isConnected = false
        self.lastError = nil

        // Опционально проверяем здоровье API в фоне
        if APIConfig.autoCheckHealth {
            Task { [weak self] in
                _ = await self?.checkAPIHealth()
            }
        }
    }
    
    // MARK: - Health Check
    func checkAPIHealth() async -> Bool {
        APIConfig.log("Checking API health at \(baseURL)")

        do {
            // Добавляем timeout для health check
            let response: APIHealthResponse = try await Self.withTimeout(seconds: 5) {
                try await self.performGetRequest(endpoint: "/health")
            }

            // Обновляем UI в главном потоке
            await MainActor.run {
                self.isConnected = response.status == "healthy"
                self.lastError = nil
            }

            APIConfig.log("API Health: \(response.status) - Agents: \(response.agents)", level: .success)
            return response.status == "healthy"
        } catch {
            // Обновляем UI в главном потоке
            await MainActor.run {
                self.isConnected = false
                self.lastError = error.localizedDescription
            }

            APIConfig.log("Health check failed: \(error.localizedDescription)", level: .error)
            return false
        }
    }

    // Helper function for timeout
    private static func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw APIError.timeout
            }

            guard let result = try await group.next() else {
                throw APIError.timeout
            }

            group.cancelAll()
            return result
        }
    }
    
    // MARK: - Server Testing

    func testServerConnectivity() async {
        print("🧪🧪🧪 TESTING SERVER CONNECTIVITY 🧪🧪🧪")
        print("🌐 Server URL: \(baseURL)")

        // Тест 1: Специальный test endpoint
        do {
            print("1️⃣ Testing /test endpoint...")
            let testResponse = try await testConnection()
            print("✅ Test endpoint SUCCESS!")
            print("📄 Status: \(testResponse.status)")
            print("📄 Message: \(testResponse.message)")
            print("📄 Timestamp: \(testResponse.timestamp)")
            print("📄 CORS: \(testResponse.cors)")
        } catch {
            print("❌ Test endpoint failed: \(error)")
        }

        // Тест 2: Examples endpoint
        do {
            print("2️⃣ Testing /examples endpoint...")
            let examples = try await getExamples()
            print("✅ Examples endpoint SUCCESS!")
            print("📄 Textual examples: \(examples.textualExamples.count)")
            print("📄 Visual examples: \(examples.visualExamples.count)")
            if let note = examples.note {
                print("📄 Note: \(note)")
            }
        } catch {
            print("❌ Examples endpoint failed: \(error)")
        }

        // Тест 3: Health endpoint
        print("3️⃣ Testing /health endpoint...")
        let healthResponse = await checkAPIHealth()
        print("✅ Health endpoint result: \(healthResponse)")

        // Тест 4: Generate-sticker endpoint (OPTIONS для проверки CORS)
        do {
            let generateURL = URL(string: baseURL + "/generate-sticker")!
            print("4️⃣ Testing /generate-sticker OPTIONS: \(generateURL)")
            var request = URLRequest(url: generateURL)
            request.httpMethod = "OPTIONS"
            for (key, value) in APIConfig.defaultHeaders() {
                request.setValue(value, forHTTPHeaderField: key)
            }
            let (_, optionsResponse) = try await session.data(for: request)
            if let httpResponse = optionsResponse as? HTTPURLResponse {
                print("✅ Generate-sticker OPTIONS: HTTP \(httpResponse.statusCode)")
                if let corsHeaders = httpResponse.value(forHTTPHeaderField: "Access-Control-Allow-Origin") {
                    print("📋 CORS Origin: \(corsHeaders)")
                }
                if let corsMethods = httpResponse.value(forHTTPHeaderField: "Access-Control-Allow-Methods") {
                    print("📋 CORS Methods: \(corsMethods)")
                }
            }
        } catch {
            print("❌ Generate-sticker OPTIONS failed: \(error)")
        }

        print("🧪🧪🧪 SERVER CONNECTIVITY TEST COMPLETE 🧪🧪🧪")
    }

    // MARK: - Async Sticker Generation

    /// Запускает асинхронную генерацию стикера и отслеживает прогресс
    func generateStickerAsync(phrase: String, username: String = "ios_user", progressCallback: @escaping (TaskStatusResponse) -> Void = { _ in }) async throws -> (imageData: Data, analysis: StickerAnalysis) {
        APIConfig.log("🚀 Starting async sticker generation for phrase: '\(phrase)'", level: .info)

        // 1. Запускаем генерацию и получаем task_id
        let taskResponse = try await startStickerGeneration(phrase: phrase, username: username)
        let taskId = taskResponse.taskId

        APIConfig.log("📋 Task started with ID: \(taskId)", level: .info)

        // 2. Отслеживаем прогресс до завершения
        let result = try await pollTaskUntilComplete(taskId: taskId, progressCallback: progressCallback)

        APIConfig.log("✅ Async sticker generation completed", level: .success)
        return result
    }

    /// Запускает генерацию стикера и возвращает task_id
    private func startStickerGeneration(phrase: String, username: String) async throws -> StickerTaskResponse {
        print("🚀 Starting sticker generation request...")
        print("📝 Phrase: '\(phrase)'")
        print("👤 Username: '\(username)'")
        print("🔗 Endpoint: \(baseURL)/generate-sticker")

        let request = StickerGenerationRequest(phrase: phrase, username: username)

        let response: StickerTaskResponse = try await performPostRequest(endpoint: "/generate-sticker", body: request)

        print("✅ Generation request successful!")
        print("📋 Task ID: \(response.taskId)")
        print("📊 Success: \(response.success)")
        print("📄 Message: \(response.message)")

        return response
    }

    /// Получает статус задачи
    func getTaskStatus(taskId: String) async throws -> TaskStatusResponse {
        print("📊 Checking task status for ID: \(taskId)")
        print("🔗 Status URL: \(baseURL)/task-status/\(taskId)")

        let response: TaskStatusResponse = try await performGetRequest(endpoint: "/task-status/\(taskId)")

        print("📊 Status response:")
        print("   - status: \(response.status.rawValue)")
        print("   - progress: \(response.progress)%")
        print("   - currentStep: \(response.currentStep)")
        print("   - errorMessage: \(response.errorMessage ?? "nil")")

        return response
    }

    /// Получает результат завершенной задачи
    private func getTaskResult(taskId: String) async throws -> StickerGenerationResponse {
        print("📋 Getting task result for ID: \(taskId)")
        print("🔗 Request URL: \(baseURL)/task-result/\(taskId)")

        let result: StickerGenerationResponse = try await performGetRequest(endpoint: "/task-result/\(taskId)")

        print("📋 Task result received successfully")
        print("📊 Result preview:")
        print("   - success: \(result.success)")
        print("   - message: \(result.message)")
        print("   - imageUrl: \(result.imageUrl ?? "nil")")

        return result
    }

    /// Отменяет задачу
    func cancelTask(taskId: String) async throws {
        let url = URL(string: baseURL + "/task/\(taskId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.timeoutInterval = 10.0

        for (key, value) in APIConfig.defaultHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        APIConfig.log("Task \(taskId) cancelled successfully", level: .info)
    }

    /// Отслеживает задачу до завершения с периодическими обновлениями прогресса
    private func pollTaskUntilComplete(taskId: String, progressCallback: @escaping (TaskStatusResponse) -> Void) async throws -> (imageData: Data, analysis: StickerAnalysis) {
        let maxAttempts = 120 // 2 минуты при проверке каждую секунду
        var attempts = 0
        var consecutiveErrors = 0
        let maxConsecutiveErrors = 5

        while attempts < maxAttempts {
            do {
                let status = try await getTaskStatus(taskId: taskId)
                consecutiveErrors = 0 // Сбрасываем счетчик ошибок при успешном запросе

                // Вызываем callback для обновления UI
                progressCallback(status)

                print("📊 Task status check (attempt \(attempts + 1)/\(maxAttempts)):")
                print("   - taskId: \(taskId)")
                print("   - status: \(status.status.rawValue)")
                print("   - progress: \(status.progress)%")
                print("   - currentStep: \(status.currentStep)")
                print("   - errorMessage: \(status.errorMessage ?? "nil")")

                switch status.status {
                case .completed:
                    print("✅ Task completed! Getting final result...")
                    // Получаем результат
                    let result = try await getTaskResult(taskId: taskId)
                    print("📦 Final result obtained, processing...")
                    return try await processCompletedTask(result: result)

                case .failed:
                    let errorMessage = status.errorMessage ?? "Unknown error"
                    print("❌ Task failed with error: \(errorMessage)")
                    throw APIError.generationFailed(errorMessage)

                case .pending, .processing:
                    print("⏳ Task still in progress, waiting 1 second...")
                    // Продолжаем ожидание
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 секунда
                    attempts += 1

                    APIConfig.log("📋 Task \(taskId) status: \(status.status.rawValue) (\(status.progress)%) - \(status.currentStep)", level: .info)
                }

            } catch {
                consecutiveErrors += 1
                APIConfig.log("⚠️ Error polling task status (attempt \(consecutiveErrors)/\(maxConsecutiveErrors)): \(error)", level: .warning)

                if consecutiveErrors >= maxConsecutiveErrors {
                    APIConfig.log("❌ Too many consecutive errors, giving up", level: .error)
                    throw APIError.networkError(error)
                }

                // Увеличиваем задержку при ошибках
                let backoffDelay = min(consecutiveErrors * 2, 10) // Максимум 10 секунд
                try await Task.sleep(nanoseconds: UInt64(backoffDelay * 1_000_000_000))
                attempts += 1
            }
        }

        throw APIError.timeout
    }

    /// Обрабатывает завершенную задачу и возвращает данные стикера
    private func processCompletedTask(result: StickerGenerationResponse) async throws -> (imageData: Data, analysis: StickerAnalysis) {
        print("🔍 Processing completed task result...")
        print("📊 Result success: \(result.success)")
        print("📊 Result message: \(result.message)")
        print("📊 Result imageUrl: \(result.imageUrl ?? "nil")")
        print("📊 Result analysis: \(result.analysis != nil ? "present" : "nil")")

        // Детальное логирование всего объекта ответа
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(result)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📋 FULL RESULT JSON:")
                print(jsonString)
            }
        } catch {
            print("⚠️ Could not serialize result to JSON: \(error)")
        }

        guard result.success else {
            print("❌ Task result indicates failure: \(result.message)")
            throw APIError.generationFailed(result.message)
        }

        guard let imageUrl = result.imageUrl else {
            print("❌ No image URL in completed task result")
            print("📊 Available fields in result:")
            print("   - success: \(result.success)")
            print("   - message: \(result.message)")
            print("   - imageUrl: \(result.imageUrl ?? "nil")")
            print("   - analysis: \(result.analysis != nil ? "present" : "nil")")
            throw APIError.noImageURL
        }

        guard let analysisData = result.analysis else {
            print("❌ No analysis data in completed task result")
            throw APIError.decodingError(NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing analysis data"]))
        }

        print("✅ Task result validation passed")
        print("🔗 Image URL: \(imageUrl)")

        // Загружаем изображение
        print("📥 Downloading image from URL...")
        let imageData = try await downloadImage(from: imageUrl)
        print("✅ Image downloaded successfully: \(imageData.count) bytes")

        // Конвертируем анализ
        let analysis = StickerAnalysis(
            contentType: analysisData.contentType,
            meaning: analysisData.meaning,
            emotion: analysisData.emotion,
            context: analysisData.context
        )

        print("✅ Task processing completed successfully")
        return (imageData, analysis)
    }

    // MARK: - Legacy Sync Method (Deprecated)
    func generateSticker(phrase: String, username: String = "ios_user") async throws -> (imageData: Data, analysis: StickerAnalysis) {
        print("🚀🚀🚀 STARTING STICKER GENERATION 🚀🚀🚀")
        print("📝 Input phrase: '\(phrase)'")
        print("👤 Username: '\(username)'")
        print("🌐 Base URL: \(baseURL)")
        print("🔧 Full endpoint URL: \(baseURL)/generate-sticker")
        print("⏰ Timeout: \(timeout) seconds")
        print("📱 User Agent: \(APIConfig.defaultHeaders()["User-Agent"] ?? "Unknown")")
        APIConfig.log("🚀 Starting sticker generation for phrase: '\(phrase)'", level: .info)
        APIConfig.log("🌐 Using serverphrase    String    : \(baseURL)", level: .info)

        var response: StickerGenerationResponse!
        do {
            print("🌐 Making request to: \(baseURL)")

            // Детальная проверка доступности сервера
            print("🔍 Detailed server connectivity check...")
            print("🌐 Testing connection to: \(baseURL)")

            do {
                let testResponse = try await testConnection()
                print("✅ Server is accessible!")
                print("📄 Server message: \(testResponse.message)")
                print("📄 CORS status: \(testResponse.cors)")
                print("📄 Server status: \(testResponse.status)")

                // Дополнительная проверка /generate-sticker endpoint через OPTIONS
                print("🔍 Testing /generate-sticker endpoint availability...")
                let generateURL = URL(string: baseURL + "/generate-sticker")!
                var optionsRequest = URLRequest(url: generateURL)
                optionsRequest.httpMethod = "OPTIONS"
                optionsRequest.timeoutInterval = 10.0

                do {
                    let (_, optionsResponse) = try await session.data(for: optionsRequest)
                    if let httpResponse = optionsResponse as? HTTPURLResponse {
                        print("✅ /generate-sticker endpoint responds with status: \(httpResponse.statusCode)")
                    }
                } catch {
                    print("⚠️ /generate-sticker OPTIONS request failed: \(error)")
                }

            } catch {
                print("❌ Server test failed: \(error)")
                print("🔧 Troubleshooting info:")
                print("   - Base URL: \(baseURL)")
                print("   - Full test URL: \(baseURL)/test")
                print("   - Timeout: \(timeout) seconds")
                print("   - Error details: \(error.localizedDescription)")

                // Пробуем базовую проверку доступности
                print("🔍 Trying basic connectivity test...")
                let basicURL = URL(string: baseURL)!
                var basicRequest = URLRequest(url: basicURL)
                basicRequest.httpMethod = "GET"
                basicRequest.timeoutInterval = 10.0

                do {
                    let (_, basicResponse) = try await session.data(for: basicRequest)
                    if let httpResponse = basicResponse as? HTTPURLResponse {
                        print("✅ Basic server connection works, status: \(httpResponse.statusCode)")
                    }
                } catch {
                    print("❌ Basic server connection failed: \(error)")
                    throw APIError.networkError(error)
                }
            }

            // Используем правильную структуру запроса согласно API документации
            print("🔄 Using documented API structure with /generate-sticker endpoint")
            let request = StickerGenerationRequest(phrase: phrase, username: username)

            // Логируем запрос
            if let requestData = try? JSONEncoder().encode(request),
               let requestString = String(data: requestData, encoding: .utf8) {
                print("📤 Request body: \(requestString)")
            }

            // Попытка генерации с retry логикой
            var lastError: Error?
            let maxRetries = 3

            for attempt in 1...maxRetries {
                print("🔄 Generation attempt \(attempt)/\(maxRetries)")

                do {
                    response = try await performPostRequest(endpoint: "/generate-sticker", body: request)
                    print("✅ Success with /generate-sticker endpoint on attempt \(attempt)")
                    break
                } catch {
                    lastError = error
                    print("❌ Attempt \(attempt) failed: \(error)")

                    if attempt < maxRetries {
                        print("⏳ Waiting 2 seconds before retry...")
                        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                    } else {
                        print("❌ All \(maxRetries) attempts failed")
                        throw lastError ?? error
                    }
                }
            }

            // Логируем полученный ответ
            if let responseData = try? JSONEncoder().encode(response),
               let responseString = String(data: responseData, encoding: .utf8) {
                print("📥 Response: \(responseString)")
            }


        } catch APIError.decodingError {
            // Если не удалось декодировать как StickerGenerationResponse,
            // попробуем декодировать как простую ошибку
            APIConfig.log("Failed to decode as StickerGenerationResponse, trying as error response", level: .warning)
            throw APIError.generationFailed("Server returned invalid response format")
        }

        guard response.success else {
            APIConfig.log("Generation failed: \(response.message)", level: .error)

            // Проверяем на перегруженность сервера по сообщению
            if response.message.lowercased().contains("перегружен") ||
               response.message.lowercased().contains("overloaded") ||
               response.message.lowercased().contains("busy") ||
               response.message.lowercased().contains("попробуйте позже") ||
               response.message.lowercased().contains("try again later") {
                throw APIError.serverOverloaded
            }

            throw APIError.generationFailed(response.message)
        }

        guard let imageUrl = response.imageUrl else {
            APIConfig.log("No image URL in response", level: .error)
            throw APIError.noImageURL
        }

        guard let analysisData = response.analysis else {
            APIConfig.log("No analysis data in response", level: .error)
            throw APIError.decodingError(NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing analysis data"]))
        }

        // Загружаем изображение
        APIConfig.log("Downloading image from: \(imageUrl)")
        print("🔗 Image URL: \(imageUrl)")
        let imageData = try await downloadImage(from: imageUrl)
        print("📸 Downloaded image size: \(imageData.count) bytes")

        // Конвертируем анализ
        let analysis = StickerAnalysis(
            contentType: analysisData.contentType,
            meaning: analysisData.meaning,
            emotion: analysisData.emotion,
            context: analysisData.context
        )

        let generationTimeValue = response.generationTime ?? 0.0
        print("🎉 STICKER GENERATION SUCCESSFUL!")
        print("⏱️ Generation time: \(String(format: "%.2f", generationTimeValue))s")
        print("📸 Image size: \(imageData.count) bytes")
        print("🎨 Content type: \(analysis.contentType)")
        APIConfig.log("Sticker generated successfully in \(String(format: "%.2f", generationTimeValue))s", level: .success)
        return (imageData, analysis)
    }
    
    // MARK: - Get Examples
    func getExamples() async throws -> APIExamplesResponse {
        return try await performGetRequest(endpoint: "/examples")
    }

    // MARK: - Test Connection
    func testConnection() async throws -> APITestResponse {
        return try await performGetRequest(endpoint: "/test")
    }
    
    // MARK: - Private Methods
    private func performGetRequest<U: Codable>(
        endpoint: String
    ) async throws -> U {
        return try await performRequest(endpoint: endpoint, method: "GET", body: nil as EmptyBody?)
    }

    private func performPostRequest<T: Codable, U: Codable>(
        endpoint: String,
        body: T
    ) async throws -> U {
        return try await performRequest(endpoint: endpoint, method: "POST", body: body)
    }

    private func performRequest<T: Codable, U: Codable>(
        endpoint: String,
        method: String,
        body: T?
    ) async throws -> U {
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = timeout

        // Добавляем заголовки из конфигурации
        for (key, value) in APIConfig.defaultHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Логируем заголовки запроса
        APIConfig.log("📋 Request headers:", level: .info)
        for (key, value) in request.allHTTPHeaderFields ?? [:] {
            APIConfig.log("   \(key): \(value)", level: .info)
        }
        
        // Добавляем тело запроса если есть
        if let body = body {
            do {
                let jsonData = try JSONEncoder().encode(body)
                request.httpBody = jsonData

                // Логируем тело запроса
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    APIConfig.log("📤 Request body: \(jsonString)", level: .info)
                }
            } catch {
                throw APIError.encodingError(error)
            }
        }

        // Выполняем запрос
        APIConfig.log("→ \(method) \(url.absoluteString)")

        do {
            print("🌐 Making HTTP request to: \(url.absoluteString)")
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw APIError.invalidResponse
            }

            print("📥 HTTP response: \(httpResponse.statusCode) (\(data.count) bytes)")
            APIConfig.log("← \(httpResponse.statusCode) for \(endpoint) (\(data.count) bytes)")

            // Логируем заголовки ответа
            if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") {
                APIConfig.log("📋 Content-Type: \(contentType)", level: .info)
            }

            // Логируем содержимое ответа для отладки
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw response content:")
                print(responseString)

                // Проверяем, не HTML ли это
                if responseString.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("<") {
                    print("⚠️ Received HTML response instead of JSON")
                    APIConfig.log("📄 Response appears to be HTML (server error page)", level: .warning)
                    APIConfig.log("📄 HTML Response: \(String(responseString.prefix(200)))...", level: .info)
                } else {
                    APIConfig.log("📄 Response body: \(responseString)", level: .info)
                }
            } else {
                APIConfig.log("📄 Response body: [Binary data, \(data.count) bytes]", level: .warning)
            }

            // Проверяем статус код
            switch httpResponse.statusCode {
            case 200...299:
                // Проверяем, что данные не пустые
                guard !data.isEmpty else {
                    APIConfig.log("❌ Empty response data", level: .error)
                    throw APIError.invalidResponse
                }

                // Проверяем, что это не HTML ответ
                if let responseString = String(data: data, encoding: .utf8),
                   responseString.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("<") {
                    APIConfig.log("❌ Server returned HTML instead of JSON", level: .error)
                    throw APIError.invalidResponse
                }

                // Успешный ответ
                do {
                    let result = try createJSONDecoder().decode(U.self, from: data)
                    APIConfig.log("✅ Successfully decoded response", level: .success)
                    return result
                } catch {
                    APIConfig.log("❌ JSON Decode Error: \(error)", level: .error)
                    APIConfig.log("📄 Raw Response Data: \(String(data: data, encoding: .utf8) ?? "nil")", level: .error)

                    // Дополнительная диагностика
                    if let decodingError = error as? DecodingError {
                        APIConfig.log("🔍 Decoding Error Details: \(decodingError.localizedDescription)", level: .error)
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            APIConfig.log("🔍 Missing key: \(key.stringValue) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))", level: .error)
                        case .typeMismatch(let type, let context):
                            APIConfig.log("🔍 Type mismatch for type: \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))", level: .error)
                        case .valueNotFound(let type, let context):
                            APIConfig.log("🔍 Value not found for type: \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))", level: .error)
                        case .dataCorrupted(let context):
                            APIConfig.log("🔍 Data corrupted at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))", level: .error)
                        @unknown default:
                            APIConfig.log("🔍 Unknown decoding error", level: .error)
                        }
                    }

                    // Попытка fallback декодирования для диагностики
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                        APIConfig.log("🔍 JSON structure: \(jsonObject)", level: .info)
                    } catch {
                        APIConfig.log("🔍 Failed to parse as JSON: \(error)", level: .error)
                    }

                    throw APIError.decodingError(error)
                }
                
            case 400:
                // Ошибка валидации
                if let errorResponse = try? createJSONDecoder().decode(APIErrorResponse.self, from: data) {
                    throw APIError.validationError(errorResponse.errorMessage)
                } else {
                    throw APIError.badRequest
                }

            case 429, 503:
                // Сервер перегружен или слишком много запросов
                throw APIError.serverOverloaded

            case 500:
                // Внутренняя ошибка сервера
                if let errorResponse = try? createJSONDecoder().decode(APIErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.errorMessage)
                } else {
                    throw APIError.internalServerError
                }

            default:
                throw APIError.httpError(httpResponse.statusCode)
            }
            
        } catch {
            // Детальная диагностика сетевых ошибок
            APIConfig.log("❌ Network request failed: \(error)", level: .error)
            APIConfig.log("🔧 Request details:", level: .error)
            APIConfig.log("   URL: \(url.absoluteString)", level: .error)
            APIConfig.log("   Method: \(method)", level: .error)
            APIConfig.log("   Timeout: \(timeout)s", level: .error)

            if let urlError = error as? URLError {
                APIConfig.log("🔍 URLError details:", level: .error)
                APIConfig.log("   Code: \(urlError.code.rawValue)", level: .error)
                APIConfig.log("   Description: \(urlError.localizedDescription)", level: .error)

                switch urlError.code {
                case .timedOut:
                    APIConfig.log("⏰ Request timed out - server may be slow or unreachable", level: .error)
                case .cannotConnectToHost:
                    APIConfig.log("🚫 Cannot connect to host - server may be down", level: .error)
                case .networkConnectionLost:
                    APIConfig.log("📡 Network connection lost", level: .error)
                case .notConnectedToInternet:
                    APIConfig.log("🌐 No internet connection", level: .error)
                case .cannotFindHost:
                    APIConfig.log("🔍 Cannot find host - check URL", level: .error)
                default:
                    APIConfig.log("❓ Other network error: \(urlError.localizedDescription)", level: .error)
                }
            }

            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error)
            }
        }
    }
    
    private func downloadImage(from urlString: String) async throws -> Data {
        print("🔍 Starting image download from: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid image URL: \(urlString)")
            throw APIError.invalidImageURL
        }

        print("✅ URL is valid, starting download...")

        do {
            let (data, response) = try await session.data(from: url)

            print("📥 Download response received:")
            print("   - Data size: \(data.count) bytes")
            print("   - Response type: \(type(of: response))")

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Response is not HTTPURLResponse")
                throw APIError.imageDownloadFailed
            }

            print("   - HTTP Status Code: \(httpResponse.statusCode)")
            print("   - Content-Type: \(httpResponse.value(forHTTPHeaderField: "Content-Type") ?? "unknown")")

            guard httpResponse.statusCode == 200 else {
                print("❌ HTTP error: \(httpResponse.statusCode)")
                throw APIError.imageDownloadFailed
            }

            // Проверяем, что это действительно изображение
            guard UIImage(data: data) != nil else {
                print("❌ Downloaded data is not a valid image")
                print("   - First 100 bytes: \(data.prefix(100))")
                throw APIError.invalidImageData
            }

            print("✅ Image downloaded and validated: \(data.count) bytes")
            return data

        } catch {
            print("❌ Image download failed with error: \(error)")
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.imageDownloadFailed
            }
        }
    }

    // MARK: - Helper Methods

    private func createJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()

        // Настраиваем декодер для более гибкой обработки
        decoder.dateDecodingStrategy = .iso8601

        // Не используем convertFromSnakeCase, так как у нас есть кастомные CodingKeys
        // decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }
}

// MARK: - API Errors
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case encodingError(Error)
    case decodingError(Error)
    case validationError(String)
    case badRequest
    case serverError(String)
    case internalServerError
    case httpError(Int)
    case generationFailed(String)
    case noImageURL
    case invalidImageURL
    case imageDownloadFailed
    case invalidImageData
    case serverOverloaded
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL API"
        case .invalidResponse:
            return "Неверный ответ сервера"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Ошибка кодирования: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Ошибка декодирования: \(error.localizedDescription)"
        case .validationError(let message):
            return "Ошибка валидации: \(message)"
        case .badRequest:
            return "Неверный запрос"
        case .serverError(let message):
            return "Ошибка сервера: \(message)"
        case .internalServerError:
            return "Внутренняя ошибка сервера"
        case .httpError(let code):
            return "HTTP ошибка: \(code)"
        case .generationFailed(let message):
            return "Не удалось создать стикер: \(message)"
        case .noImageURL:
            return "Сервер не вернул URL изображения"
        case .invalidImageURL:
            return "Неверный URL изображения"
        case .imageDownloadFailed:
            return "Не удалось загрузить изображение"
        case .invalidImageData:
            return "Неверные данные изображения"
        case .serverOverloaded:
            return NSLocalizedString("sticker_server_overloaded", comment: "")
        case .timeout:
            return "Превышено время ожидания ответа от сервера"
        }
    }
}
