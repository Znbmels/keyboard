//
//  StickerGeneratorView.swift
//  Keyboard
//
//  Created by Zainab on 10.07.2025.
//

import SwiftUI

struct StickerGeneratorView: View {
    @ObservedObject private var stickerManager = StickerManager.shared
    @State private var inputText = ""
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var generationTask: Task<Void, Never>?
    @State private var selectedStickersForKeyboard: Set<String> = []
    @State private var stickersEnabledInKeyboard = true
    @State private var showSaveSuccess = false
    @State private var isTestingConnection = false
    @State private var connectionTestResult: String?

    // Async generation progress tracking
    @State private var generationProgress: Int = 0
    @State private var currentStep: String = ""
    @State private var taskId: String?
    @State private var estimatedTimeRemaining: Int?

    private let apiService = StickerAPIService.shared

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 30) {
                    // Header with development warning
                    VStack(spacing: 8) {
                        HStack {
                            Text("Sticker Generator")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Spacer()

                            // Development warning badge
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text("В разработке")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                        }

                        Text("⚠️ Функция находится в стадии разработки. Возможны ошибки и сбои.")
                            .font(.caption)
                            .foregroundColor(.yellow)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                    // Input Section
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Enter Islamic phrase or text...", text: $inputText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                                .disabled(isGenerating)

                            if !isGenerating {
                                Text("💡 Example: \"Alhamdulillah\", \"Bismillah\", \"SubhanAllah\"")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 4)

                                // Async generation info
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 12))
                                    Text("Real-time progress tracking • ~30s generation time")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal, 4)
                                .padding(.top, 2)
                            }
                        }

                        // Generate Button with Progress
                        Button(action: generateSticker) {
                            VStack(spacing: 8) {
                                HStack {
                                    if isGenerating {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Generating Sticker...")
                                                .font(.system(size: 16, weight: .medium))
                                            if !currentStep.isEmpty {
                                                Text(currentStep)
                                                    .font(.system(size: 12))
                                                    .opacity(0.8)
                                            }
                                        }
                                    } else {
                                        Image(systemName: "wand.and.stars")
                                            .font(.system(size: 16))
                                        Text("Generate Sticker")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                }

                                // Progress bar and details
                                if isGenerating {
                                    VStack(spacing: 4) {
                                        // Progress bar
                                        ProgressView(value: Double(generationProgress), total: 100.0)
                                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                                            .scaleEffect(y: 0.5)

                                        // Progress details
                                        HStack {
                                            Text("\(generationProgress)%")
                                                .font(.system(size: 11))
                                                .opacity(0.8)

                                            Spacer()

                                            if let timeRemaining = estimatedTimeRemaining {
                                                Text("~\(timeRemaining)s remaining")
                                                    .font(.system(size: 11))
                                                    .opacity(0.8)
                                            }
                                        }
                                    }
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, isGenerating ? 12 : 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(inputText.isEmpty || isGenerating ? Color.gray : Color.islamicGreen)
                            )
                        }
                        .disabled(inputText.isEmpty || isGenerating)

                        // Cancel Button (only show during generation)
                        if isGenerating, let currentTaskId = taskId {
                            Button(action: {
                                cancelGeneration(taskId: currentTaskId)
                            }) {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                        .font(.system(size: 16))
                                    Text("Cancel Generation")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                            }
                        }

                        // Test Connection Button
                        Button(action: testServerConnection) {
                            HStack {
                                if isTestingConnection {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Testing...")
                                } else {
                                    Image(systemName: "network")
                                    Text("Test Server Connection")
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isTestingConnection ? Color.gray : Color.blue)
                            )
                        }
                        .disabled(isTestingConnection || isGenerating)
                    }
                    .padding(.horizontal, 20)

                    // Success Message
                    if let successMessage = successMessage {
                        Text(successMessage)
                            .foregroundColor(.islamicGreen)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.islamicGreen.opacity(0.1))
                            )
                            .padding(.horizontal, 20)
                            .transition(.opacity.combined(with: .scale))
                            .animation(.easeInOut(duration: 0.3), value: successMessage)
                    }

                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.1))
                            )
                            .padding(.horizontal, 20)
                            .transition(.opacity.combined(with: .scale))
                            .animation(.easeInOut(duration: 0.3), value: errorMessage)
                    }

                    // Connection Test Result
                    if let connectionTestResult = connectionTestResult {
                        Text(connectionTestResult)
                            .foregroundColor(connectionTestResult.contains("✅") ? .green : .red)
                            .font(.caption)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                    }

                    // Stickers Library
                    if !stickerManager.savedStickers.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Generated Stickers")
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    Spacer()

                                    // Enable/Disable toggle
                                    Toggle("", isOn: $stickersEnabledInKeyboard)
                                        .labelsHidden()
                                        .onChange(of: stickersEnabledInKeyboard) { _, enabled in
                                            UserDefaults.standard.set(enabled, forKey: "stickers_enabled_in_keyboard")
                                            syncWithKeyboard()
                                        }
                                }

                                // Quick selection buttons
                                HStack(spacing: 12) {
                                    Button("Выбрать все") {
                                        selectedStickersForKeyboard = Set(stickerManager.savedStickers.map { $0.id })
                                    }
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                    .background(Color.blue)
                                    .cornerRadius(6)

                                    Button("Снять все") {
                                        selectedStickersForKeyboard.removeAll()
                                    }
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                    .background(Color.red)
                                    .cornerRadius(6)
                                }
                                .padding(.horizontal, 20)

                                // Save button
                                Button(action: {
                                    saveSelectedStickers()
                                    syncWithKeyboard()
                                    showSaveSuccess = true

                                    // Скрываем сообщение через 2 секунды
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showSaveSuccess = false
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: showSaveSuccess ? "checkmark.circle.fill" : "square.and.arrow.down")
                                        Text(showSaveSuccess ? "Сохранено!" : "Сохранить выбор")
                                    }
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(showSaveSuccess ? Color.green : Color.islamicGreen)
                                    .cornerRadius(8)
                                    .animation(.easeInOut(duration: 0.3), value: showSaveSuccess)
                                }
                                .padding(.horizontal, 20)
                            }

                            // Selection info
                            HStack {
                                Text("Выбрано: \(selectedStickersForKeyboard.count) из \(stickerManager.savedStickers.count)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.horizontal, 20)

                            // Stickers Grid
                            ScrollView {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                                    ForEach(stickerManager.savedStickers, id: \.id) { sticker in
                                        StickerGridItem(
                                            sticker: sticker,
                                            isSelected: selectedStickersForKeyboard.contains(sticker.id),
                                            onToggle: { toggleStickerSelection(sticker.id) }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    Spacer()
                }
            }
        }
        .onAppear {
            loadSelectedStickers()
            // Add demo stickers if empty
            if stickerManager.savedStickers.isEmpty {
                stickerManager.addDemoStickers()
            }
        }
    }

    // MARK: - Functions

    private func generateSticker() {
        guard !inputText.isEmpty else {
            print("⚠️ Empty input text, aborting generation")
            return
        }

        let promptText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !promptText.isEmpty else {
            print("⚠️ Input text is only whitespace, aborting generation")
            return
        }

        print("🎨 Generating sticker for: '\(promptText)'")
        print("🔧 API Base URL: \(apiService.baseURL)")

        print("🎬 === STARTING STICKER GENERATION PROCESS ===")
        print("📝 Input phrase: '\(promptText)'")
        print("⏰ Timestamp: \(Date())")

        generationTask?.cancel()
        generationTask = Task { @MainActor in
            print("🔄 Setting up generation state...")
            isGenerating = true
            errorMessage = nil
            successMessage = nil
            generationProgress = 0
            currentStep = "Initializing..."
            taskId = nil
            estimatedTimeRemaining = 30
            print("✅ Generation state initialized")

            // Проверяем подключение к API перед началом
            print("🔍 Checking API health before generation...")
            print("🌐 API Service base URL: \(apiService.baseURL)")
            let isHealthy = await apiService.checkAPIHealth()
            if !isHealthy {
                print("❌ API health check failed")
                print("🔧 Setting error state...")
                errorMessage = "Server is not available. Please try again later."
                isGenerating = false
                generationProgress = 0
                currentStep = ""
                taskId = nil
                estimatedTimeRemaining = nil
                print("❌ Generation aborted due to health check failure")
                return
            }
            print("✅ API health check passed - proceeding with generation")

            do {
                print("🚀 Starting async sticker generation...")
                print("🔧 API Base URL: \(apiService.baseURL)")
                print("🔧 Full generate URL: \(apiService.baseURL)/generate-sticker")

                let result = try await apiService.generateStickerAsync(
                    phrase: promptText,
                    progressCallback: { status in
                        Task { @MainActor in
                            print("📊 Progress callback received:")
                            print("   - taskId: \(status.taskId)")
                            print("   - status: \(status.status.rawValue)")
                            print("   - progress: \(status.progress)%")
                            print("   - currentStep: \(status.currentStep)")
                            print("   - errorMessage: \(status.errorMessage ?? "nil")")
                            print("   - estimatedRemaining: \(status.estimatedRemaining ?? 0)s")

                            self.generationProgress = status.progress
                            self.currentStep = status.currentStep
                            self.taskId = status.taskId
                            self.estimatedTimeRemaining = status.estimatedRemaining

                            print("📋 UI Updated - Progress: \(status.progress)% - \(status.currentStep)")
                        }
                    }
                )

                print("✅ Async sticker generation completed!")
                print("📦 Generation result received:")
                print("   - imageData size: \(result.imageData.count) bytes")
                print("   - analysis.contentType: \(result.analysis.contentType)")
                print("   - analysis.meaning: \(result.analysis.meaning)")
                print("   - analysis.emotion: \(result.analysis.emotion)")
                print("   - analysis.context: \(result.analysis.context)")

                // Save sticker - convert StickerAnalysis to StickerAnalysisData
                print("🔄 Converting analysis data...")
                let analysisData = StickerAnalysisData(
                    contentType: result.analysis.contentType,
                    meaning: result.analysis.meaning,
                    emotion: result.analysis.emotion,
                    context: result.analysis.context,
                    recommendedStyle: "default",
                    recommendedColors: [],
                    hasUserColorRequest: false
                )

                print("💾 Saving sticker to database...")
                stickerManager.saveSticker(
                    prompt: promptText,
                    contentType: result.analysis.contentType,
                    imageData: result.imageData,
                    analysis: analysisData
                )
                print("✅ Sticker saved successfully!")
                print("📊 Total stickers after save: \(stickerManager.savedStickers.count)")

                // Force UI update on main thread
                DispatchQueue.main.async {
                    // Stop generation state
                    isGenerating = false
                    generationProgress = 0
                    currentStep = ""
                    taskId = nil
                    estimatedTimeRemaining = nil

                    // Clear input only after successful generation and save
                    inputText = ""

                    // Show success message
                    successMessage = "✅ Sticker generated and saved successfully!"

                    print("🔄 UI updated - generation stopped, input cleared, success message shown")
                    print("📊 UI sees \(stickerManager.savedStickers.count) stickers")
                }

                // Clear success message after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    successMessage = nil
                }

                print("🎉 Async sticker generation process completed successfully!")

            } catch {
                print("❌ === ASYNC STICKER GENERATION FAILED ===")
                print("🔍 Error type: \(type(of: error))")
                print("📄 Error description: \(error.localizedDescription)")
                print("🔧 Full error: \(error)")

                if let apiError = error as? APIError {
                    print("🚨 APIError detected: \(apiError)")
                }

                // Более понятные сообщения об ошибках для пользователя
                let userFriendlyMessage: String
                if let apiError = error as? APIError {
                    print("🔍 Processing APIError...")
                    switch apiError {
                    case .noImageURL:
                        print("🔍 Specific error: noImageURL")
                        userFriendlyMessage = "Server did not return image URL. Please try again."
                    case .networkError:
                        print("🔍 Specific error: networkError")
                        userFriendlyMessage = "Network connection error. Please check your internet connection."
                    case .timeout:
                        print("🔍 Specific error: timeout")
                        userFriendlyMessage = "Request timed out. Please try again."
                    case .serverOverloaded:
                        print("🔍 Specific error: serverOverloaded")
                        userFriendlyMessage = "Server is busy. Please try again in a few moments."
                    case .generationFailed(let message):
                        print("🔍 Specific error: generationFailed with message: \(message)")
                        userFriendlyMessage = "Generation failed: \(message)"
                    default:
                        print("🔍 Other APIError: \(apiError)")
                        userFriendlyMessage = error.localizedDescription
                    }
                } else {
                    print("🔍 Non-APIError: \(error)")
                    userFriendlyMessage = error.localizedDescription
                }

                print("🔄 Setting error message: \(userFriendlyMessage)")

                // Update UI on main thread
                DispatchQueue.main.async {
                    // Reset progress state
                    isGenerating = false
                    generationProgress = 0
                    currentStep = ""
                    taskId = nil
                    estimatedTimeRemaining = nil

                    // Set error message
                    errorMessage = userFriendlyMessage

                    print("❌ Error state set - generation stopped, error message shown")
                }
                // Don't clear input on error so user can try again
            }
        }
    }

    private func cancelGeneration(taskId: String) {
        print("🚫 === CANCELLING GENERATION ===")
        print("📋 Task ID: \(taskId)")
        print("⏰ Cancel timestamp: \(Date())")

        // Cancel the current generation task
        print("🔄 Cancelling local generation task...")
        generationTask?.cancel()
        print("✅ Local generation task cancelled")

        // Try to cancel the server task
        Task {
            do {
                print("🌐 Sending cancel request to server...")
                try await apiService.cancelTask(taskId: taskId)
                print("✅ Server task cancelled successfully")
            } catch {
                print("⚠️ Failed to cancel server task: \(error)")
                print("🔍 Cancel error type: \(type(of: error))")
                // Continue with local cancellation even if server cancellation fails
            }

            await MainActor.run {
                print("🔄 Resetting UI state after cancellation...")
                isGenerating = false
                generationProgress = 0
                currentStep = ""
                self.taskId = nil
                estimatedTimeRemaining = nil
                errorMessage = "Generation cancelled by user"
                print("✅ UI state reset after cancellation")

                // Clear error message after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    errorMessage = nil
                }
            }
        }
    }

    private func testServerConnection() {
        Task { @MainActor in
            isTestingConnection = true
            connectionTestResult = nil

            do {
                print("🧪 Starting server connection test...")

                // Тест 1: Базовая проверка /test endpoint
                let testResponse = try await apiService.testConnection()
                let testResult = "✅ Server accessible\n📄 Status: \(testResponse.status)\n📄 Message: \(testResponse.message)\n⏱️ Generation time: ~26s"

                // Тест 2: Проверка /generate-sticker endpoint через OPTIONS
                let generateURL = URL(string: apiService.baseURL + "/generate-sticker")!
                var optionsRequest = URLRequest(url: generateURL)
                optionsRequest.httpMethod = "OPTIONS"
                optionsRequest.timeoutInterval = 10.0

                let session = URLSession.shared
                let (_, optionsResponse) = try await session.data(for: optionsRequest)

                if let httpResponse = optionsResponse as? HTTPURLResponse {
                    let endpointResult = "✅ /generate-sticker endpoint: HTTP \(httpResponse.statusCode)"
                    connectionTestResult = testResult + "\n" + endpointResult
                } else {
                    connectionTestResult = testResult + "\n⚠️ /generate-sticker endpoint check failed"
                }

                print("✅ Connection test successful")

            } catch {
                print("❌ Connection test failed: \(error)")
                connectionTestResult = "❌ Connection failed\n🔧 Error: \(error.localizedDescription)\n🌐 Server: http://207.154.222.27"
            }

            isTestingConnection = false

            // Скрываем результат через 10 секунд
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                connectionTestResult = nil
            }
        }
    }

    private func toggleStickerSelection(_ stickerId: String) {
        if selectedStickersForKeyboard.contains(stickerId) {
            selectedStickersForKeyboard.remove(stickerId)
        } else {
            selectedStickersForKeyboard.insert(stickerId)
        }
        // Не сохраняем автоматически - только при нажатии кнопки "Сохранить"
    }

    private func loadSelectedStickers() {
        print("🎨 Loading selected stickers...")
        print("🎨 Total available stickers: \(stickerManager.savedStickers.count)")

        // Используем App Groups для синхронизации
        let userDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard

        if let data = userDefaults.data(forKey: "selected_stickers_for_keyboard"),
           let selected = try? JSONDecoder().decode(Set<String>.self, from: data) {
            selectedStickersForKeyboard = selected
            print("🎨 Loaded \(selected.count) selected stickers from App Groups UserDefaults")
        } else {
            // Select all by default
            selectedStickersForKeyboard = Set(stickerManager.savedStickers.map { $0.id })
            print("🎨 No saved selection found, selecting all \(selectedStickersForKeyboard.count) stickers by default")
        }

        stickersEnabledInKeyboard = userDefaults.object(forKey: "stickers_enabled_in_keyboard") as? Bool ?? true
        print("🎨 Stickers enabled in keyboard: \(stickersEnabledInKeyboard)")
    }

    private func saveSelectedStickers() {
        print("🎨 Saving selected stickers: \(selectedStickersForKeyboard.count)")
        print("🎨 Selected IDs: \(Array(selectedStickersForKeyboard))")

        // Используем App Groups для синхронизации
        let userDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard

        if let data = try? JSONEncoder().encode(selectedStickersForKeyboard) {
            userDefaults.set(data, forKey: "selected_stickers_for_keyboard")
            userDefaults.synchronize()
            print("🎨 Selected stickers saved successfully to App Groups")

            // Проверяем, что данные сохранились
            if let savedData = userDefaults.data(forKey: "selected_stickers_for_keyboard"),
               let savedIds = try? JSONDecoder().decode(Set<String>.self, from: savedData) {
                print("🎨 Verification: Saved \(savedIds.count) selected stickers to App Groups")
            }

            // Показываем сообщение об успешном сохранении
            errorMessage = nil
        } else {
            print("❌ Failed to encode selected stickers")
            errorMessage = "Ошибка сохранения выбора стикеров"
        }
    }

    private func syncWithKeyboard() {
        // Используем App Groups для синхронизации
        let userDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard

        userDefaults.set(stickersEnabledInKeyboard, forKey: "stickers_enabled_in_keyboard")
        userDefaults.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name("StickerSettingsChanged"), object: nil)
        print("🎨 Synced with keyboard via App Groups: enabled=\(stickersEnabledInKeyboard), selected=\(selectedStickersForKeyboard.count)")

        // Показываем сообщение об успешной синхронизации
        errorMessage = nil
    }
}

// MARK: - Supporting Views

struct StickerGridItem: View {
    let sticker: SavedSticker
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            // Sticker Image
            if let uiImage = UIImage(data: sticker.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 80)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }

            // Prompt text
            Text(sticker.prompt)
                .font(.caption)
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            // Selection checkbox
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .islamicGreen : .gray)
                    .font(.title3)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .stroke(isSelected ? Color.islamicGreen : Color.clear, lineWidth: 2)
        )
    }
}

struct StickerAnalysis: Codable {
    let contentType: String
    let meaning: String
    let emotion: String
    let context: String
}

