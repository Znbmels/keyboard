//
//  StickerManager.swift
//  Keyboard
//
//  Created by Zainab on 10.07.2025.
//

import Foundation
import UIKit

// MARK: - Sticker Model
struct SavedSticker: Codable, Identifiable {
    let id: String
    let prompt: String
    let contentType: String
    let imageData: Data
    let createdAt: Date
    let analysis: StickerAnalysisData?
    
    init(id: String = UUID().uuidString, prompt: String, contentType: String, imageData: Data, analysis: StickerAnalysisData? = nil) {
        self.id = id
        self.prompt = prompt
        self.contentType = contentType
        self.imageData = imageData
        self.createdAt = Date()
        self.analysis = analysis
    }
}

struct StickerAnalysisData: Codable {
    let contentType: String
    let meaning: String
    let emotion: String
    let context: String
    let recommendedStyle: String
    let recommendedColors: [String]
    let hasUserColorRequest: Bool
}

// MARK: - Sticker Manager
class StickerManager: ObservableObject {
    static let shared = StickerManager()
    
    @Published var savedStickers: [SavedSticker] = []
    
    private let userDefaults: UserDefaults
    private let stickersKey = "saved_stickers"
    private let maxStickers = 50 // Лимит стикеров для экономии места
    
    private init() {
        // Используем App Groups для синхронизации между приложением и клавиатурой
        self.userDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard
        loadStickers()
    }
    
    // MARK: - Public Methods
    
    /// Сохранить новый стикер
    func saveSticker(prompt: String, contentType: String, imageData: Data, analysis: StickerAnalysisData? = nil) {
        print("🎨 === STICKER MANAGER SAVE PROCESS STARTED ===")
        print("📝 Prompt: '\(prompt)'")
        print("📊 Content Type: '\(contentType)'")
        print("📦 Image Data Size: \(imageData.count) bytes")
        print("🔍 Analysis: \(analysis != nil ? "present" : "nil")")
        print("📊 Current stickers count before save: \(savedStickers.count)")

        let sticker = SavedSticker(
            prompt: prompt,
            contentType: contentType,
            imageData: imageData,
            analysis: analysis
        )

        print("🆔 Generated sticker ID: \(sticker.id)")
        print("⏰ Created at: \(sticker.createdAt)")

        // Verify image data is valid before saving
        if imageData.isEmpty {
            print("❌ CRITICAL ERROR: Cannot save sticker - image data is empty!")
            print("🎨 === STICKER MANAGER SAVE PROCESS FAILED ===")
            return
        }

        if UIImage(data: imageData) == nil {
            print("❌ CRITICAL ERROR: Cannot save sticker - image data is corrupted!")
            print("🎨 === STICKER MANAGER SAVE PROCESS FAILED ===")
            return
        }

        print("✅ Image data validation passed in StickerManager")

        // Ensure UI updates happen on main thread
        DispatchQueue.main.async {
            print("🔄 Executing on main thread...")
            print("🎨 Adding sticker to savedStickers array...")
            print("🎨 Array count before insert: \(self.savedStickers.count)")

            // Добавляем в начало списка (последние сверху)
            self.savedStickers.insert(sticker, at: 0)
            print("🎨 Sticker inserted at index 0")
            print("🎨 Array count after insert: \(self.savedStickers.count)")

            // Ограничиваем количество стикеров
            if self.savedStickers.count > self.maxStickers {
                let oldCount = self.savedStickers.count
                self.savedStickers = Array(self.savedStickers.prefix(self.maxStickers))
                print("🎨 Trimmed from \(oldCount) to max \(self.maxStickers) stickers")
            }

            print("🎨 Final array count: \(self.savedStickers.count)")
            print("🎨 First sticker prompt: '\(self.savedStickers.first?.prompt ?? "none")'")
            print("🎨 First sticker ID: '\(self.savedStickers.first?.id ?? "none")'")

            // Force UI refresh by triggering objectWillChange
            print("🔄 Triggering UI update...")
            self.objectWillChange.send()
            print("✅ UI update triggered")
        }

        // Сохраняем в UserDefaults
        print("💾 Saving to UserDefaults...")
        saveStickers()

        // Автоматически добавляем новый стикер в выбранные для клавиатуры
        print("🎯 Adding sticker to keyboard selection...")
        addStickerToKeyboardSelection(sticker.id)

        print("🎨 === STICKER MANAGER SAVE PROCESS COMPLETED ===")
        print("✅ Стикер сохранен: '\(prompt)' (\(formatFileSize(imageData.count)))")
        print("📊 Final stickers count: \(savedStickers.count)")
        print("🎯 Sticker automatically added to keyboard selection")
    }
    
    /// Удалить стикер
    func deleteSticker(id: String) {
        savedStickers.removeAll { $0.id == id }
        saveStickers()

        print("🗑️ Стикер удален: \(id)")
    }

    /// Добавить стикер в выбранные для клавиатуры
    private func addStickerToKeyboardSelection(_ stickerId: String) {
        var selectedStickers: Set<String> = []

        // Загружаем текущие выбранные стикеры
        if let data = userDefaults.data(forKey: "selected_stickers_for_keyboard"),
           let existing = try? JSONDecoder().decode(Set<String>.self, from: data) {
            selectedStickers = existing
        }

        // Добавляем новый стикер
        selectedStickers.insert(stickerId)

        // Сохраняем обновленный список
        do {
            let data = try JSONEncoder().encode(selectedStickers)
            userDefaults.set(data, forKey: "selected_stickers_for_keyboard")
            userDefaults.synchronize()
            print("🎨 Sticker \(stickerId) added to keyboard selection")
        } catch {
            print("❌ Failed to save sticker selection: \(error)")
        }
    }
    
    /// Получить стикер по ID
    func getSticker(id: String) -> SavedSticker? {
        return savedStickers.first { $0.id == id }
    }
    
    /// Получить изображение стикера
    func getStickerImage(id: String) -> UIImage? {
        guard let sticker = getSticker(id: id) else { return nil }
        return UIImage(data: sticker.imageData)
    }
    
    /// Очистить все стикеры
    func clearAllStickers() {
        savedStickers.removeAll()
        saveStickers()
        
        print("🧹 Все стикеры удалены")
    }
    
    /// Получить статистику
    func getStatistics() -> (count: Int, totalSize: String, types: [String: Int]) {
        let totalBytes = savedStickers.reduce(0) { $0 + $1.imageData.count }
        let totalSize = formatFileSize(totalBytes)

        var types: [String: Int] = [:]
        for sticker in savedStickers {
            types[sticker.contentType, default: 0] += 1
        }

        return (savedStickers.count, totalSize, types)
    }

    /// Проверить целостность библиотеки стикеров
    func validateStickerLibrary() -> (isValid: Bool, issues: [String]) {
        print("🔍 === VALIDATING STICKER LIBRARY ===")
        var issues: [String] = []

        // Проверяем, что данные в UserDefaults соответствуют массиву в памяти
        if let data = userDefaults.data(forKey: stickersKey) {
            do {
                let savedStickersFromDefaults = try JSONDecoder().decode([SavedSticker].self, from: data)
                if savedStickersFromDefaults.count != savedStickers.count {
                    let issue = "Mismatch between memory (\(savedStickers.count)) and UserDefaults (\(savedStickersFromDefaults.count))"
                    issues.append(issue)
                    print("❌ \(issue)")
                }

                // Проверяем каждый стикер на валидность
                for (index, sticker) in savedStickers.enumerated() {
                    if sticker.imageData.isEmpty {
                        let issue = "Sticker at index \(index) has empty image data"
                        issues.append(issue)
                        print("❌ \(issue)")
                    }

                    if UIImage(data: sticker.imageData) == nil {
                        let issue = "Sticker at index \(index) has corrupted image data"
                        issues.append(issue)
                        print("❌ \(issue)")
                    }

                    if sticker.prompt.isEmpty {
                        let issue = "Sticker at index \(index) has empty prompt"
                        issues.append(issue)
                        print("❌ \(issue)")
                    }
                }

            } catch {
                let issue = "Failed to decode stickers from UserDefaults: \(error)"
                issues.append(issue)
                print("❌ \(issue)")
            }
        } else {
            if !savedStickers.isEmpty {
                let issue = "No data in UserDefaults but \(savedStickers.count) stickers in memory"
                issues.append(issue)
                print("❌ \(issue)")
            }
        }

        let isValid = issues.isEmpty
        print("🔍 Library validation result: \(isValid ? "VALID" : "INVALID")")
        if !isValid {
            print("🔍 Issues found: \(issues.count)")
            for issue in issues {
                print("   - \(issue)")
            }
        }
        print("🔍 === VALIDATION COMPLETED ===")

        return (isValid, issues)
    }
    
    // MARK: - Private Methods
    
    private func loadStickers() {
        guard let data = userDefaults.data(forKey: stickersKey) else {
            print("📱 Нет сохраненных стикеров")
            return
        }
        
        do {
            savedStickers = try JSONDecoder().decode([SavedSticker].self, from: data)
            print("📱 Загружено стикеров: \(savedStickers.count)")
        } catch {
            print("❌ Ошибка загрузки стикеров: \(error)")
            savedStickers = []
        }
    }
    
    private func saveStickers() {
        print("💾 === USERDEFAULTS SAVE PROCESS STARTED ===")
        print("📊 Attempting to save \(savedStickers.count) stickers")
        print("🔑 UserDefaults key: '\(stickersKey)'")
        print("🏢 UserDefaults suite: group.school.nfactorial.muslim.keyboard")

        do {
            print("🔄 Encoding stickers to JSON...")
            let data = try JSONEncoder().encode(savedStickers)
            print("📦 Encoded data size: \(data.count) bytes")

            print("💾 Setting data in UserDefaults...")
            userDefaults.set(data, forKey: stickersKey)

            print("🔄 Synchronizing UserDefaults...")
            let syncResult = userDefaults.synchronize()
            print("🔄 Synchronize result: \(syncResult)")

            print("✅ Стикеры сохранены: \(savedStickers.count)")

            // Проверяем, что данные действительно сохранились
            print("🔍 Verifying save...")
            if let savedData = userDefaults.data(forKey: stickersKey) {
                print("✅ Verification: Data saved successfully, size: \(savedData.count) bytes")

                // Дополнительная проверка - пытаемся декодировать
                do {
                    let decodedStickers = try JSONDecoder().decode([SavedSticker].self, from: savedData)
                    print("✅ Verification: Successfully decoded \(decodedStickers.count) stickers")
                    if let firstSticker = decodedStickers.first {
                        print("✅ Verification: First sticker prompt: '\(firstSticker.prompt)'")
                    }
                } catch {
                    print("❌ Verification: Failed to decode saved data: \(error)")
                }
            } else {
                print("❌ CRITICAL ERROR: No data found after save!")
            }

            print("💾 === USERDEFAULTS SAVE PROCESS COMPLETED ===")
        } catch {
            print("❌ === USERDEFAULTS SAVE PROCESS FAILED ===")
            print("❌ Ошибка сохранения стикеров: \(error)")
            print("🔍 Error type: \(type(of: error))")
            print("📄 Error description: \(error.localizedDescription)")
        }
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Extensions for Keyboard Extension

extension StickerManager {
    /// Специальный метод для клавиатуры - получить стикеры для отображения
    func getStickersForKeyboard() -> [SavedSticker] {
        print("🎨 getStickersForKeyboard called")
        print("🎨 Total saved stickers: \(savedStickers.count)")

        // Проверяем, включены ли стикеры в клавиатуре
        let stickersEnabled = userDefaults.object(forKey: "stickers_enabled_in_keyboard") as? Bool ?? true
        print("🎨 Stickers enabled in keyboard: \(stickersEnabled)")
        guard stickersEnabled else {
            print("🎨 Stickers disabled, returning empty array")
            return []
        }

        // Загружаем выбранные стикеры из App Groups UserDefaults
        if let data = userDefaults.data(forKey: "selected_stickers_for_keyboard"),
           let selectedIds = try? JSONDecoder().decode(Set<String>.self, from: data) {

            print("🎨 Found selected stickers data: \(selectedIds.count) IDs")
            print("🎨 Selected IDs: \(Array(selectedIds))")

            // Фильтруем только выбранные стикеры
            let selectedStickers = savedStickers.filter { selectedIds.contains($0.id) }
            print("🎨 Keyboard: Found \(selectedStickers.count) selected stickers out of \(savedStickers.count) total")

            // Выводим информацию о каждом выбранном стикере
            for (index, sticker) in selectedStickers.enumerated() {
                print("🎨 Selected sticker \(index): '\(sticker.prompt)' (ID: \(sticker.id))")
            }

            return selectedStickers
        } else {
            // Если нет сохраненного выбора, показываем все стикеры
            print("🎨 Keyboard: No selection found, showing all \(savedStickers.count) stickers")
            return savedStickers
        }
    }
    
    /// Создать превью стикера для клавиатуры
    func createStickerPreview(sticker: SavedSticker, size: CGSize = CGSize(width: 60, height: 60)) -> UIImage? {
        guard let originalImage = UIImage(data: sticker.imageData) else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Рисуем фон
            UIColor.systemBackground.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Рисуем изображение с отступами
            let imageRect = CGRect(
                x: 4,
                y: 4,
                width: size.width - 8,
                height: size.height - 8
            )
            originalImage.draw(in: imageRect)
            
            // Добавляем рамку
            UIColor.systemGray4.setStroke()
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 8)
            path.lineWidth = 1
            path.stroke()
        }
    }
}

// MARK: - Demo Data (для тестирования)
extension StickerManager {
    func addDemoStickers() {
        print("🎨 Starting to add demo stickers...")
        // Создаем демо-стикеры для тестирования
        let demoPrompts = [
            ("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", "TEXTUAL"),
            ("الْحَمْدُ لِلَّهِ", "TEXTUAL"),
            ("مسجد تحت القمر", "VISUAL"),
            ("الهلال والنجمة", "VISUAL")
        ]

        for (index, (prompt, type)) in demoPrompts.enumerated() {
            print("🎨 Creating demo sticker \(index + 1)/\(demoPrompts.count): \(prompt)")
            // Создаем простое изображение-заглушку
            let image = createDemoImage(text: prompt)
            if let imageData = image.pngData() {
                print("🎨 Image data created, size: \(imageData.count) bytes")
                let analysis = StickerAnalysisData(
                    contentType: type,
                    meaning: "Demo sticker",
                    emotion: "peaceful",
                    context: "demo",
                    recommendedStyle: "Clean",
                    recommendedColors: ["green", "gold"],
                    hasUserColorRequest: false
                )
                saveSticker(prompt: prompt, contentType: type, imageData: imageData, analysis: analysis)
            } else {
                print("❌ Failed to create image data for: \(prompt)")
            }
        }
        print("🎨 Finished adding demo stickers. Total stickers: \(savedStickers.count)")
    }
    
    private func createDemoImage(text: String) -> UIImage {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Фон
            UIColor.systemGreen.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Текст
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            let textSize = attributedText.size()
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            attributedText.draw(in: textRect)
        }
    }
}
