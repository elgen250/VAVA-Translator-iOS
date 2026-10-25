import SwiftUI

/// Main root container for VAVA Translator presenting the bottom tab bar navigation.
public struct MainTabView: View {
    @State private var appState = AppState.shared
    @State private var storeKit = StoreKitManager.shared
    @State private var selectedTab: TabDestination = .text
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Text Translation
            TextTranslationView(appState: appState)
                .tabItem {
                    Label("ترجمة نصوص", systemImage: "character.bubble.fill")
                }
                .tag(TabDestination.text)

            // Tab 2: Talk & Live Conversation
            TalkConversationView(appState: appState)
                .tabItem {
                    Label("محادثة صوتية", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(TabDestination.talk)

            // Tab 3: Camera & Photo OCR
            CameraOCRView(appState: appState)
                .tabItem {
                    Label("الكاميرا", systemImage: "camera.viewfinder")
                }
                .tag(TabDestination.camera)

            // Tab 4: AI Coach James
            CoachJamesView()
                .tabItem {
                    Label("المدرب James", systemImage: "person.crop.circle.badge.checkmark")
                }
                .tag(TabDestination.coach)

            // Tab 5: History & Favorites
            HistoryView()
                .tabItem {
                    Label("السجل", systemImage: "clock.arrow.circlepath")
                }
                .tag(TabDestination.history)
        }
        .tint(Color.vavaPrimary)
        .overlay(alignment: .topTrailing) {
            topControlBar
        }
        .sheet(isPresented: $showingSettings) {
            SettingsSheetView()
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .fullScreenCover(isPresented: Binding(
            get: { !hasCompletedOnboarding },
            set: { _ in }
        )) {
            OnboardingView(isPresented: Binding(
                get: { !hasCompletedOnboarding },
                set: { hasCompletedOnboarding = !$0 }
            ))
        }
    }

    // Top buttons for Pro status and Settings
    private var topControlBar: some View {
        HStack(spacing: 8) {
            if !storeKit.isProUser {
                Button {
                    showingPaywall = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.yellow)
                        Text("PRO")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color.vavaPrimary, Color.vavaSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.vavaPrimary.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }

            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .padding(8)
                    .background(Color.vavaCardBackground.opacity(0.85))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.vavaBorder, lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.trailing, 16)
        .padding(.top, 54)
    }
}

public enum TabDestination: Hashable {
    case text
    case talk
    case camera
    case coach
    case history
}
