import SwiftUI
import SwiftData

/// Application entry point for VAVA Translator (iOS 18.0+).
@main
struct VAVATranslatorApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([
            TranslationHistoryItem.self,
            PhraseItem.self,
            LessonProgress.self
        ])

        // First attempt App Group shared container for extension synchronization
        do {
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                groupContainer: .identifier("group.com.vava.translator")
            )
            self.container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Fallback to local default container if App Group is unavailable in testing/sim
            do {
                let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                self.container = try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(container)
                .task {
                    seedInitialDataIfNeeded(context: container.mainContext)
                }
        }
    }

    @MainActor
    private func seedInitialDataIfNeeded(context: ModelContext) {
        var fetchDescriptor = FetchDescriptor<PhraseItem>()
        fetchDescriptor.fetchLimit = 1
        if let count = try? context.fetchCount(fetchDescriptor), count == 0 {
            SampleData.populate(context: context)
        }
    }
}
