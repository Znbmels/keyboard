//
//  OnboardingView.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    let onComplete: () -> Void
    
    private let onboardingPages = [
        OnboardingPage(
            title: LocalizedStringKey(AppConstants.Onboarding.page1Title),
            description: LocalizedStringKey(AppConstants.Onboarding.page1Description),
            icon: AppConstants.Onboarding.page1Icon
        ),
        OnboardingPage(
            title: LocalizedStringKey(AppConstants.Onboarding.page2Title),
            description: LocalizedStringKey(AppConstants.Onboarding.page2Description),
            icon: AppConstants.Onboarding.page2Icon
        ),
        OnboardingPage(
            title: LocalizedStringKey(AppConstants.Onboarding.page3Title),
            description: LocalizedStringKey(AppConstants.Onboarding.page3Description),
            icon: AppConstants.Onboarding.page3Icon
        )
    ]
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        OnboardingPageView(page: onboardingPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Page Indicators and Navigation
                VStack(spacing: 30) {
                    // Page Indicators
                    HStack(spacing: 8) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(currentPage == index ? Color.islamicGreen : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut, value: currentPage)
                        }
                    }
                    
                    // Next/Done Button
                    Button(action: {
                        if currentPage < onboardingPages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            // Отмечаем завершение онбординга для системы рейтинга
                            AppRatingManager.shared.markOnboardingCompleted()
                            onComplete()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(LocalizedStringKey(currentPage < onboardingPages.count - 1 ? AppConstants.ButtonTexts.next : AppConstants.ButtonTexts.done))
                                .font(.title3)
                                .fontWeight(.semibold)

                            if currentPage < onboardingPages.count - 1 {
                                Image(systemName: "arrow.right")
                                    .font(.title3)
                            }
                        }
                        .foregroundColor(.black)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.islamicGreen)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(.islamicGreen)
            
            // Content
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

struct OnboardingPage {
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let icon: String
}

#Preview {
    OnboardingView {
        print("Onboarding completed")
    }
}
