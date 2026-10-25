import SwiftUI
import SwiftData

/// Application entry point for VAVA Translator (iOS 18.0+).
@main
struct VAVATranslatorApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([TranslationHistoryItem.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.container = try ModelContainer(for: schema, configurations: [config])
        } catch {
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
