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
    @State private var showingInstructions = false
    @State private var isTestingConnection = false
    @State private var connectionTestResult: String?
    @State private var isSyncing = false

    // Async generation progress tracking
    @State private var generationProgress: Int = 0
    @State private var currentStep: String = ""
    @State private var taskId: String?
    @State private var estimatedTimeRemaining: Int?
    @State private var generationStartTime: Date?
    @State private var elapsedTime: Int = 0

    private let apiService = StickerAPIService.shared

    // Computed property to check if all stickers are selected
    private var allStickersSelected: Bool {
        !stickerManager.savedStickers.isEmpty &&
        stickerManager.savedStickers.allSatisfy { selectedStickersForKeyboard.contains($0.id) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 40) {
                    // Clean Header with Instructions Button
                    VStack(spacing: 12) {
                        Text(NSLocalizedString("sticker_generator", comment: "Sticker Generator"))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        // Instructions Button
                        Button(action: {
                            showingInstructions = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 16))
                                Text("sticker_read_instructions")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.islamicGreen)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.islamicGreen, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.top, 20)

                    // Input Section
                    VStack(spacing: 20) {
                        TextField(NSLocalizedString("enter_sticker_text", comment: "Enter sticker text"), text: $inputText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16))
                            .padding(.horizontal, 20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.green, lineWidth: 2)
                                    .padding(.horizontal, 20)
                            )

                        // Generate Button
                        Button(action: generateSticker) {
                            HStack {
                                if isGenerating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text(isGenerating ? NSLocalizedString("generating", comment: "Generating...") : NSLocalizedString("create_sticker", comment: "Create Sticker"))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green)
                            )
                        }
                        .disabled(isGenerating || inputText.isEmpty)
                        .padding(.horizontal, 20)

                        // Progress Section
                        if isGenerating {
                            VStack(spacing: 12) {
                                ProgressView(value: Double(generationProgress), total: 100)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                    .padding(.horizontal, 20)

                                Text(currentStep.isEmpty ? "Сейчас произойдет чудо... ✨" : currentStep)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))

                                if elapsedTime > 0 {
                                    Text("Прошло времени: \(elapsedTime)с")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                        }

                        // Messages
                        if let error = errorMessage {
                            Text(getUserFriendlyErrorMessage(error))
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }

                        if let success = successMessage {
                            Text(success)
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                                .padding(.horizontal, 20)
                        }
                    }

                    // Sticker Library
                    if !stickerManager.savedStickers.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(NSLocalizedString("sticker_library", comment: "Sticker Library"))
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Spacer()

                                // Select All Button
                                Button(action: toggleSelectAll) {
                                    HStack(spacing: 4) {
                                        Image(systemName: allStickersSelected ? "checkmark.square.fill" : "square")
                                            .foregroundColor(allStickersSelected ? .green : .white)
                                            .font(.system(size: 14))
                                        Text(NSLocalizedString("select_all", comment: "Select All"))
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)

                            ScrollView {
                                LazyVGrid(
                                    columns: [
                                        GridItem(.flexible(), spacing: 8),
                                        GridItem(.flexible(), spacing: 8),
                                        GridItem(.flexible(), spacing: 8)
                                    ],
                                    spacing: 12,
                                    pinnedViews: []
                                ) {
                                    ForEach(stickerManager.savedStickers.reversed()) { sticker in
                                        StickerGridItem(
                                            sticker: sticker,
                                            isSelected: selectedStickersForKeyboard.contains(sticker.id),
                                            onToggleSelection: {
                                                if selectedStickersForKeyboard.contains(sticker.id) {
                                                    selectedStickersForKeyboard.remove(sticker.id)
                                                } else {
                                                    selectedStickersForKeyboard.insert(sticker.id)
                                                }
                                                syncSelectedStickers()
                                            },
                                            onDelete: {
                                                stickerManager.deleteSticker(id: sticker.id)
                                                selectedStickersForKeyboard.remove(sticker.id)
                                                syncSelectedStickers()
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }

                            // Save Button
                            if !stickerManager.savedStickers.isEmpty {
                                Button(action: {
                                    syncSelectedStickers()
                                    showSaveSuccess = true

                                    // Hide success message after 2 seconds
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showSaveSuccess = false
                                    }
                                }) {
                                    HStack {
                                        if showSaveSuccess {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16))
                                        }
                                        Text(showSaveSuccess ? NSLocalizedString("saved", comment: "Saved") : NSLocalizedString("save_selection", comment: "Save Selection"))
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(showSaveSuccess ? Color.green : Color.islamicGreen)
                                    )
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("sticker_generator_title")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: Button(action: {
                showingInstructions = true
            }) {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.islamicGreen)
                    .font(.title2)
            }
        )
        .sheet(isPresented: $showingInstructions) {
            StickerInstructionsView()
        }
        .onAppear {
            loadSelectedStickers()

            // Проверяем целостность библиотеки стикеров
            let validation = stickerManager.validateStickerLibrary()
            if !validation.isValid {
                print("⚠️ Sticker library validation failed with \(validation.issues.count) issues")
                for issue in validation.issues {
                    print("   - \(issue)")
                }
            }

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
            do {
                isGenerating = true
                errorMessage = nil
                successMessage = nil
                generationProgress = 0
                currentStep = "Инициализация..."
                generationStartTime = Date()
                elapsedTime = 0

                // Start elapsed time tracking
                startElapsedTimeTracking()

                print("🚀 Starting sticker generation...")
                currentStep = "Создание задачи генерации..."
                generationProgress = 10

                // Step 1: Start generation and get task ID
                let taskResponse = try await apiService.startStickerGeneration(phrase: promptText, username: "ios_user")
                taskId = taskResponse.taskId
                print("✅ Task created with ID: \(taskResponse.taskId)")

                currentStep = "Обработка запроса..."
                generationProgress = 30

                // Step 2: Poll for completion with shorter intervals
                var attempts = 0
                let maxAttempts = 120 // 2 minutes max (checking every 1 second)

                while attempts < maxAttempts {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    attempts += 1

                    currentStep = "Генерация стикера... (\(attempts)с)"
                    generationProgress = min(30 + (attempts * 60 / maxAttempts), 90)

                    let statusResponse = try await apiService.getTaskStatus(taskId: taskResponse.taskId)
                    print("📊 Task status: \(statusResponse.status) - Progress: \(statusResponse.progress)%")

                    // Update progress from server
                    generationProgress = max(generationProgress, statusResponse.progress)
                    if !statusResponse.currentStep.isEmpty {
                        currentStep = statusResponse.currentStep
                    }

                    if statusResponse.status == .completed {
                        print("🎉 Generation completed!")
                        currentStep = "Получение результата..."
                        generationProgress = 95

                        // Get the final result
                        let result = try await apiService.getTaskResult(taskId: taskResponse.taskId)

                        guard result.success, let imageUrl = result.imageUrl else {
                            throw NSError(domain: "StickerGeneration", code: -1, userInfo: [NSLocalizedDescriptionKey: result.message])
                        }

                        // Download image
                        let imageData = try await apiService.downloadImage(from: imageUrl)

                        currentStep = "Сохранение стикера..."

                        // Save the sticker
                        stickerManager.saveSticker(
                            prompt: promptText,
                            contentType: result.analysis?.contentType ?? "TEXTUAL",
                            imageData: imageData,
                            analysis: nil
                        )

                        generationProgress = 100
                        currentStep = "Готово!"
                        successMessage = "Альхамдуллилях, ваш стикер готов! 🎉"
                        inputText = ""

                        print("✅ Sticker saved successfully")
                        break

                    } else if statusResponse.status == .failed {
                        let errorMsg = statusResponse.errorMessage ?? "Generation failed"
                        throw NSError(domain: "StickerGeneration", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])
                    }
                }

                if attempts >= maxAttempts {
                    throw NSError(domain: "StickerGeneration", code: -2, userInfo: [NSLocalizedDescriptionKey: "Generation timed out after \(maxAttempts) seconds"])
                }

            } catch {
                print("❌ Generation failed: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                currentStep = ""
                generationProgress = 0
            }

            isGenerating = false
            taskId = nil
        }
    }

    private func loadSelectedStickers() {
        // Используем App Groups UserDefaults для синхронизации с клавиатурой
        let userDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard

        if let data = userDefaults.data(forKey: "selected_stickers_for_keyboard"),
           let selected = try? JSONDecoder().decode(Set<String>.self, from: data) {
            selectedStickersForKeyboard = selected
            print("🎨 Loaded \(selected.count) selected stickers from App Groups")
        } else {
            print("🎨 No selected stickers found in App Groups")
        }

        stickersEnabledInKeyboard = userDefaults.bool(forKey: "stickers_enabled_in_keyboard")
    }

    private func syncSelectedStickers() {
        // Используем App Groups UserDefaults для синхронизации с клавиатурой
        let userDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard

        if let data = try? JSONEncoder().encode(selectedStickersForKeyboard) {
            userDefaults.set(data, forKey: "selected_stickers_for_keyboard")
            userDefaults.synchronize()
            print("🎨 Synced \(selectedStickersForKeyboard.count) selected stickers to App Groups")

            // Отправляем уведомление об изменении выбора стикеров
            NotificationCenter.default.post(name: NSNotification.Name("StickerSelectionChanged"), object: nil)
        }
    }

    private func toggleSelectAll() {
        if allStickersSelected {
            // Deselect all
            selectedStickersForKeyboard.removeAll()
        } else {
            // Select all
            selectedStickersForKeyboard = Set(stickerManager.savedStickers.map { $0.id })
        }
        syncSelectedStickers()
    }

    private func getUserFriendlyErrorMessage(_ error: String) -> String {
        return "Извините, сейчас эта страница только проходит тестирование... Попробуйте снова и обратитесь к поддержке 🛠️"
    }

    private func startElapsedTimeTracking() {
        guard let startTime = generationStartTime else { return }

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if !isGenerating {
                timer.invalidate()
                return
            }

            DispatchQueue.main.async {
                self.elapsedTime = Int(Date().timeIntervalSince(startTime))
            }
        }
    }
}

// MARK: - Sticker Grid Item Component
struct StickerGridItem: View {
    let sticker: SavedSticker
    let isSelected: Bool
    let onToggleSelection: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ZStack {
            // Sticker Image
            if let uiImage = UIImage(data: sticker.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.system(size: 24))
                    )
            }

            // Selection indicator
            VStack {
                HStack {
                    Spacer()
                    Button(action: onToggleSelection) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .green : .white)
                            .font(.system(size: 20))
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.5))
                                    .frame(width: 24, height: 24)
                            )
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    Button(action: onDelete) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 16))
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.7))
                                    .frame(width: 24, height: 24)
                            )
                    }
                }
            }
            .padding(6)
        }
        .frame(width: 100, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
        )
    }
}

struct StickerAnalysis: Codable {
    let contentType: String
    let meaning: String
    let emotion: String
    let context: String
}

// MARK: - Timeout Helper
func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
    return try await withThrowingTaskGroup(of: T.self) { group in
        // Add the main operation
        group.addTask {
            return try await operation()
        }

        // Add timeout task
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError()
        }

        // Return the first completed task and cancel others
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

struct TimeoutError: Error, LocalizedError {
    var errorDescription: String? {
        return "Operation timed out"
    }
}
