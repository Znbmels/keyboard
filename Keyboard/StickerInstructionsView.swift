import SwiftUI

struct StickerInstructionsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Заголовок
                    VStack(spacing: 8) {
                        Text("بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ")
                            .font(.custom("AmiriQuran", size: 18))
                            .foregroundColor(.islamicGreen)
                            .multilineTextAlignment(.center)
                        
                        Text("sticker_instructions_title")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)
                    
                    // Что можно генерировать
                    InstructionSection(
                        title: "sticker_what_can_generate",
                        items: [
                            "sticker_can_islamic_phrases",
                            "sticker_can_duas",
                            "sticker_can_quran_verses",
                            "sticker_can_islamic_art",
                            "sticker_can_mosque_images",
                            "sticker_can_calligraphy"
                        ]
                    )
                    
                    // Что нельзя генерировать
                    InstructionSection(
                        title: "sticker_what_cannot_generate",
                        items: [
                            "sticker_cannot_people",
                            "sticker_cannot_animals",
                            "sticker_cannot_inappropriate",
                            "sticker_cannot_non_islamic"
                        ],
                        isWarning: true
                    )
                    
                    // Примеры промптов
                    InstructionSection(
                        title: "sticker_prompt_examples",
                        items: [
                            "sticker_example_alhamdulillah",
                            "sticker_example_bismillah",
                            "sticker_example_mosque",
                            "sticker_example_ramadan",
                            "sticker_example_eid"
                        ]
                    )
                    
                    // Как использовать
                    InstructionSection(
                        title: "sticker_how_to_use",
                        items: [
                            "sticker_step_1_write_prompt",
                            "sticker_step_2_wait_generation",
                            "sticker_step_3_select_stickers",
                            "sticker_step_4_use_in_keyboard",
                            "sticker_step_5_tap_to_copy",
                            "sticker_step_6_paste_in_chat"
                        ]
                    )
                    
                    // Важные заметки
                    VStack(alignment: .leading, spacing: 12) {
                        Text("sticker_important_notes")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.islamicGreen)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ImportantNote(text: "sticker_note_beta_feature")
                            ImportantNote(text: "sticker_note_generation_time")
                            ImportantNote(text: "sticker_note_contact_support")
                            ImportantNote(text: "sticker_note_disable_feature")
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // Благодарность
                    VStack(spacing: 8) {
                        Text("جَزَاكَ اللَّهُ خَيْرًا")
                            .font(.custom("AmiriQuran", size: 16))
                            .foregroundColor(.islamicGreen)
                            .multilineTextAlignment(.center)
                        
                        Text("sticker_thanks_understanding")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle(LocalizedStringKey("sticker_instructions_nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(LocalizedStringKey("close")) {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.islamicGreen)
            )
        }
    }
}

struct InstructionSection: View {
    let title: String
    let items: [String]
    let isWarning: Bool
    
    init(title: String, items: [String], isWarning: Bool = false) {
        self.title = title
        self.items = items
        self.isWarning = isWarning
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey(title))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(isWarning ? .red : .islamicGreen)
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text(isWarning ? "⚠️" : "✅")
                            .font(.system(size: 14))
                        
                        Text(LocalizedStringKey(item))
                            .font(.body)
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

struct ImportantNote: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("💡")
                .font(.system(size: 14))
            
            Text(LocalizedStringKey(text))
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

#Preview {
    StickerInstructionsView()
}
