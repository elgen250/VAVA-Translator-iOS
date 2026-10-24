import SwiftUI
import SwiftData

/// History and Favorites Tab View leveraging SwiftData.
public struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TranslationHistoryItem.timestamp, order: .reverse)
    private var allHistoryItems: [TranslationHistoryItem]

    @State private var selectedFilter: HistoryFilter = .all
    @State private var searchText: String = ""
    @State private var showingClearConfirmation = false

    private let playbackService = AudioPlaybackService.shared

    public init() {}

    private var filteredItems: [TranslationHistoryItem] {
        allHistoryItems.filter { item in
            let matchesFilter = (selectedFilter == .all) || (selectedFilter == .favorites && item.isFavorite)
            let matchesSearch = searchText.isEmpty ||
                item.sourceText.localizedCaseInsensitiveContains(searchText) ||
                item.translatedText.localizedCaseInsensitiveContains(searchText)
            return matchesFilter && matchesSearch
        }
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Segmented Control
                Picker("التصفية", selection: $selectedFilter) {
                    ForEach(HistoryFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // Content List
                if filteredItems.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            HistoryRowView(
                                item: item,
                                onToggleFavorite: {
                                    item.isFavorite.toggle()
                                    try? modelContext.save()
                                },
                                onPlayAudio: {
                                    playbackService.speak(
                                        text: item.translatedText,
                                        languageCode: item.targetLanguageCode
                                    )
                                }
                            )
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    modelContext.delete(item)
                                    try? modelContext.save()
                                } label: {
                                    Label("حذف", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.vavaScreenBackground.ignoresSafeArea())
            .navigationTitle("السجل والمفضلة")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "بحث في الترجمات السابقة...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !allHistoryItems.isEmpty {
                        Button {
                            showingClearConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .confirmationDialog(
                "هل أنت متأكد من رغبتك في مسح كافة عناصر السجل؟",
                isPresented: $showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("مسح السجل بالكامل", role: .destructive) {
                    clearAllHistory()
                }
                Button("إلغاء", role: .cancel) {}
            }
        }
    }

    // MARK: - Subviews

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: selectedFilter == .favorites ? "star.slash" : "clock.arrow.circlepath")
                .font(.system(size: 54))
                .foregroundStyle(Color.secondary.opacity(0.4))

            Text(selectedFilter == .favorites ? "لا توجد ترجمات مفضلة بعد" : "سجل الترجمات فارغ")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("ستظهر جميع عمليات الترجمة النصية والصوتية والمصورة هنا تلقائياً.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    // MARK: - Actions

    private func clearAllHistory() {
        for item in allHistoryItems {
            modelContext.delete(item)
        }
        try? modelContext.save()
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }
}

public enum HistoryFilter: String, CaseIterable, Identifiable {
    case all = "الكل"
    case favorites = "المفضلة"

    public var id: String { rawValue }
    public var title: String { rawValue }
}
