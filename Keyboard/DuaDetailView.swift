//
//  DuaDetailView.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

struct DuaDetailView: View {
    let dua: Dua
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var duaManager = DuaManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Icon and Title
                        VStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.islamicGreen)
                                    .frame(width: 80, height: 80)

                                Image(systemName: dua.icon)
                                    .font(.system(size: 40, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 20)

                            Text(dua.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Arabic Text
                        VStack(spacing: 8) {
                            Text("dua_arabic")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .textCase(.uppercase)
                            
                            Text(dua.arabicText)
                                .font(.custom("AmiriQuran", size: 32))
                                .foregroundColor(.islamicGreen)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .lineLimit(nil)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                            .padding(.horizontal)
                        
                        // Translation
                        VStack(spacing: 12) {
                            Text("dua_translation")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .textCase(.uppercase)
                            
                            Text(dua.translation)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .lineLimit(nil)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                            .padding(.horizontal)
                        
                        // Usage
                        VStack(spacing: 12) {
                            Text("dua_usage")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .textCase(.uppercase)
                            
                            Text(dua.usage)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .padding(.horizontal)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            // Copy Full Dua Button
                            Button(action: {
                                copyToClipboard()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.on.doc.fill")
                                        .font(.title3)
                                    Text("copy_dua")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.islamicGreen)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }

                            // Add to Keyboard Button
                            Button(action: {
                                toggleDuaForKeyboard()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: dua.isSelected ? "checkmark.square.fill" : "square")
                                        .font(.title3)
                                    Text(dua.isSelected ? "remove_from_keyboard" : "add_to_keyboard")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(dua.isSelected ? .white : .black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(dua.isSelected ? Color.red.opacity(0.8) : Color.islamicGreen)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 16)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.islamicGreen)
                }
                
                ToolbarItem(placement: .principal) {
                    Text(dua.title)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func copyToClipboard() {
        let textToCopy = dua.insertText
        UIPasteboard.general.string = textToCopy

        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }

    private func toggleDuaForKeyboard() {
        duaManager.toggleDuaSelection(dua)

        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

struct DuaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DuaDetailView(dua: Dua(
            key: "success",
            icon: "🙏",
            englishTitle: "Wish Success",
            russianTitle: "Пожелать удачи",
            arabicText: "اللهم وفقه لما تحب وترضى",
            englishTranslation: "O Allah, grant him success in what You love and are pleased with",
            russianTranslation: "О Аллах, даруй ему успех в том, что Ты любишь и чем доволен",
            englishUsage: "When wishing someone success in their endeavors",
            russianUsage: "Когда желаете кому-то успеха в делах"
        ))
    }
}
