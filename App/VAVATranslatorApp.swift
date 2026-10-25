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

        // Safely check if App Group container is actually provisioned and accessible on this device
        let appGroupIdentifier = "group.com.vava.translator"
        let isAppGroupAccessible = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) != nil

        if isAppGroupAccessible {
            do {
                let config = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    groupContainer: .identifier(appGroupIdentifier)
                )
                self.container = try ModelContainer(for: schema, configurations: [config])
                return
            } catch {
                print("App Group container failed to load, falling back to local: \(error)")
            }
        }

        // Standard local sandbox container (used during sideloading or free Apple ID signing)
        do {
            let localConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.container = try ModelContainer(for: schema, configurations: [localConfig])
        } catch {
            print("Local container creation failed: \(error). Falling back to in-memory container.")
            do {
                let memoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                self.container = try ModelContainer(for: schema, configurations: [memoryConfig])
            } catch {
                print("In-memory container creation failed: \(error). Using empty fallback container.")
                let fallbackSchema = Schema([])
                let fallbackConfig = ModelConfiguration(schema: fallbackSchema, isStoredInMemoryOnly: true)
                self.container = (try? ModelContainer(for: fallbackSchema, configurations: [fallbackConfig])) ?? {
                    fatalError("Fatal: SwiftData runtime failure: \(error)")
                }()
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
