import SwiftUI
import SwiftData

/// Application entry point for VAVA Translator (iOS 18.0+).
@main
struct VAVATranslatorApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([
                TranslationHistoryItem.self
            ])
            
            // Try configuring container for the shared App Group
            let groupConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                groupContainer: .identifier("group.com.vava.translator")
            )
            self.container = try ModelContainer(for: schema, configurations: [groupConfig])
        } catch {
            print("Notice: App Group container unavailable in current preview/simulator runtime. Falling back to local default storage: \(error)")
            // Fallback to local default container for testing/previews
            do {
                self.container = try ModelContainer(for: TranslationHistoryItem.self)
            } catch {
                fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(container)
        }
    }
}
