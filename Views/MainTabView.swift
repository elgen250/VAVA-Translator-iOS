import SwiftUI

/// Main root container for VAVA Translator presenting the bottom tab bar navigation.
public struct MainTabView: View {
    @State private var appState = AppState.shared
    @State private var selectedTab: TabDestination = .text
    @State private var showingSettings = false

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

            // Tab 4: History & Favorites
            HistoryView()
                .tabItem {
                    Label("السجل", systemImage: "clock.arrow.circlepath")
                }
                .tag(TabDestination.history)
        }
        .tint(Color.vavaPrimary)
        .overlay(alignment: .topTrailing) {
            // Global Settings Access Button
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .padding(10)
                    .background(Color.vavaCardBackground.opacity(0.85))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.vavaBorder, lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            }
            .padding(.trailing, 16)
            .padding(.top, 54) // Align nicely below status bar
        }
        .sheet(isPresented: $showingSettings) {
            SettingsSheetView()
        }
    }
}

public enum TabDestination: Hashable {
    case text
    case talk
    case camera
    case history
}
