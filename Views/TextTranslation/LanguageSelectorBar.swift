import SwiftUI

/// Top navigation bar for selecting and swapping source and target languages.
public struct LanguageSelectorBar: View {
    @Bindable var appState: AppState

    @State private var showingSourceSheet = false
    @State private var showingTargetSheet = false
    @State private var swapRotation: Double = 0

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Source Language Button
            Button {
                showingSourceSheet = true
            } label: {
                HStack(spacing: 6) {
                    Text(appState.sourceLanguage.flag)
                        .font(.title3)
                    Text(appState.sourceLanguage.nativeName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color.vavaCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.vavaBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            // Swap Languages Button
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    swapRotation += 180
                    appState.swapLanguages()
                }
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(appState.sourceLanguage.isAutoDetect ? Color.secondary.opacity(0.4) : Color.vavaPrimary)
                    .rotationEffect(.degrees(swapRotation))
                    .frame(width: 38, height: 38)
                    .background(Color.vavaCardBackground)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.vavaBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(appState.sourceLanguage.isAutoDetect)

            // Target Language Button
            Button {
                showingTargetSheet = true
            } label: {
                HStack(spacing: 6) {
                    Text(appState.targetLanguage.flag)
                        .font(.title3)
                    Text(appState.targetLanguage.nativeName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color.vavaCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.vavaBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingSourceSheet) {
            LanguagePickerSheet(
                title: "اختر لغة المصدر",
                languages: SupportedLanguage.sourceChoices,
                selectedLanguage: $appState.sourceLanguage
            )
        }
        .sheet(isPresented: $showingTargetSheet) {
            LanguagePickerSheet(
                title: "اختر لغة الهدف",
                languages: SupportedLanguage.targetChoices,
                selectedLanguage: $appState.targetLanguage
            )
        }
    }
}

/// Modal picker sheet to browse and choose a language.
public struct LanguagePickerSheet: View {
    let title: String
    let languages: [SupportedLanguage]
    @Binding var selectedLanguage: SupportedLanguage
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""

    var filteredLanguages: [SupportedLanguage] {
        if searchText.isEmpty { return languages }
        return languages.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.nativeName.localizedCaseInsensitiveContains(searchText) ||
            $0.code.localizedCaseInsensitiveContains(searchText)
        }
    }

    public var body: some View {
        NavigationStack {
            List(filteredLanguages) { lang in
                Button {
                    selectedLanguage = lang
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Text(lang.flag)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(lang.nativeName)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            Text(lang.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if lang.code == selectedLanguage.code {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.vavaPrimary)
                                .font(.headline)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
            .searchable(text: $searchText, prompt: "ابحث عن لغة...")
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إغلاق") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
