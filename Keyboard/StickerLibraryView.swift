//
//  StickerLibraryView.swift
//  Keyboard
//
//  Created by Zainab on 10.07.2025.
//

import SwiftUI

struct StickerLibraryView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var stickerManager = StickerManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var stickerToDelete: SavedSticker?
    @State private var showingClearAllAlert = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                if stickerManager.savedStickers.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "photo.stack")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.3))
                        
                        Text("sticker_library_empty_title")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("sticker_library_empty_subtitle")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("sticker_library_create_first")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.islamicGreen)
                                .cornerRadius(25)
                        }
                    }
                } else {
                    // Sticker Grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(stickerManager.savedStickers.reversed()) { sticker in
                                StickerLibraryCard(
                                    sticker: sticker,
                                    onDelete: {
                                        stickerToDelete = sticker
                                        showingDeleteAlert = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("sticker_library_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                }
                
                if !stickerManager.savedStickers.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: {
                                showingClearAllAlert = true
                            }) {
                                Label("sticker_library_clear_all", systemImage: "trash")
                            }
                            
                            Button(action: {
                                shareLibraryStatistics()
                            }) {
                                Label("sticker_library_statistics", systemImage: "chart.bar")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .environmentLanguage(languageManager.currentLanguage)
        .alert("sticker_library_delete_title", isPresented: $showingDeleteAlert) {
            Button("cancel", role: .cancel) { }
            Button("delete", role: .destructive) {
                if let sticker = stickerToDelete {
                    stickerManager.deleteSticker(id: sticker.id)
                }
            }
        } message: {
            Text("sticker_library_delete_message")
        }
        .alert("sticker_library_clear_all_title", isPresented: $showingClearAllAlert) {
            Button("cancel", role: .cancel) { }
            Button("sticker_library_clear_all", role: .destructive) {
                stickerManager.clearAllStickers()
            }
        } message: {
            Text("sticker_library_clear_all_message")
        }
    }
    
    private func shareLibraryStatistics() {
        let stats = stickerManager.getStatistics()
        let message = """
        📊 Моя коллекция стикеров:
        
        🎨 Всего стикеров: \(stats.count)
        💾 Общий размер: \(stats.totalSize)
        
        📝 Текстовых: \(stats.types["TEXTUAL"] ?? 0)
        🖼️ Визуальных: \(stats.types["VISUAL"] ?? 0)
        
        #MuslimAIKeyboard
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

struct StickerLibraryCard: View {
    let sticker: SavedSticker
    let onDelete: () -> Void
    
    @State private var showingDetails = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Sticker Image
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 100)
                
                if let image = UIImage(data: sticker.imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 80, maxHeight: 80)
                        .cornerRadius(8)
                } else {
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.3))
                }
                
                // Delete Button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onDelete) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                                .background(Color.white, in: Circle())
                        }
                    }
                    Spacer()
                }
                .padding(8)
            }
            
            // Sticker Info
            VStack(spacing: 4) {
                Text(sticker.prompt)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 4) {
                    Image(systemName: sticker.contentType == "TEXTUAL" ? "textformat" : "paintbrush")
                        .font(.caption2)
                        .foregroundColor(.islamicGreen)
                    
                    Text(sticker.contentType)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .onTapGesture {
            showingDetails = true
        }
        .sheet(isPresented: $showingDetails) {
            StickerDetailView(sticker: sticker)
        }
    }
}

struct StickerDetailView: View {
    let sticker: SavedSticker
    @Environment(\.dismiss) private var dismiss
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Large Sticker Image
                        if let image = UIImage(data: sticker.imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 300)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        
                        // Sticker Details
                        VStack(alignment: .leading, spacing: 16) {
                            DetailRow(title: "sticker_detail_prompt", value: sticker.prompt)
                            DetailRow(title: "sticker_detail_type", value: sticker.contentType)
                            DetailRow(title: "sticker_detail_created", value: formatDate(sticker.createdAt))
                            
                            if let analysis = sticker.analysis {
                                DetailRow(title: "sticker_detail_style", value: analysis.recommendedStyle)
                                DetailRow(title: "sticker_detail_colors", value: analysis.recommendedColors.joined(separator: ", "))
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        
                        // Share Button
                        Button(action: {
                            shareSticker()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2)
                                
                                Text("sticker_share_button")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("sticker_detail_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("done")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.islamicGreen)
                }
            }
        }
        .environmentLanguage(languageManager.currentLanguage)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func shareSticker() {
        guard let image = UIImage(data: sticker.imageData) else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [image, sticker.prompt],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(NSLocalizedString(title, comment: ""))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.islamicGreen)
                .textCase(.uppercase)
            
            Text(value)
                .font(.body)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    StickerLibraryView()
}
