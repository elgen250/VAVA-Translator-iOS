import SwiftUI
import Translation

/// Settings and diagnostic sheet for the MVP version of VAVA Translator.
public struct SettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var arabicEnglishStatus: String = "جار الفحص..."
    @State private var arabicFrenchStatus: String = "جار الفحص..."
    @State private var arabicSpanishStatus: String = "جار الفحص..."

    private let translationService = TranslationService.shared

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                // Section 1: Engine & Architecture
                Section(header: Text("محرك المعالجة والذكاء الاصطناعي")) {
                    HStack(spacing: 12) {
                        Image(systemName: "cpu.fill")
                            .font(.title2)
                            .foregroundStyle(Color.vavaPrimary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Apple Translation Framework")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            Text("معالجة عصبية محلية 100% على الجهاز (iOS 18+)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    HStack {
                        Text("الخصوصية وحماية البيانات")
                        Spacer()
                        Text("محلية بالكامل")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.vavaSuccess)
                    }

                    HStack {
                        Text("حاوية النظام التشاركية")
                        Spacer()
                        Text("group.com.vava.translator")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                // Section 2: On-Device Language Packs Status
                Section(header: Text("حالة حزم اللغات دون اتصال (Offline Status)")) {
                    languageStatusRow(from: "العربية 🇸🇦", to: "English 🇺🇸", status: arabicEnglishStatus)
                    languageStatusRow(from: "العربية 🇸🇦", to: "Français 🇫🇷", status: arabicFrenchStatus)
                    languageStatusRow(from: "العربية 🇸🇦", to: "Español 🇪🇸", status: arabicSpanishStatus)
                }

                // Section 3: RTL & Arabic Support
                Section(header: Text("تخصيص اللغة العربية (RTL Engine)")) {
                    HStack {
                        Text("دعم الخطوط العربية")
                        Spacer()
                        Text("San Francisco Arabic")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("التخطيط والترقيم ثنائي الاتجاه (BiDi)")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.vavaSuccess)
                    }
                }

                // Section 4: App Info
                Section(header: Text("حول النسخة الأولية")) {
                    HStack {
                        Text("اسم التطبيق")
                        Spacer()
                        Text("VAVA Translator")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("الإصدار")
                        Spacer()
                        Text("1.0.0 (MVP Prototype)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("المعرف البرمجي")
                        Spacer()
                        Text("com.vava.translator")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("الإعدادات وحالة النظام")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("تم") { dismiss() }
                        .fontWeight(.bold)
                }
            }
            .task {
                await checkAllStatuses()
            }
        }
    }

    private func languageStatusRow(from: String, to: String, status: String) -> some View {
        HStack {
            Text("\(from) ➔ \(to)")
                .font(.subheadline)
            Spacer()
            Text(status)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(status == "مثبت محلياً" ? Color.vavaSuccess : Color.vavaPrimary)
        }
    }

    private func checkAllStatuses() async {
        let status1 = await translationService.checkAvailability(from: .arabic, to: .english)
        let status2 = await translationService.checkAvailability(from: .arabic, to: SupportedLanguage.from(code: "fr"))
        let status3 = await translationService.checkAvailability(from: .arabic, to: SupportedLanguage.from(code: "es"))

        await MainActor.run {
            self.arabicEnglishStatus = formatStatus(status1)
            self.arabicFrenchStatus = formatStatus(status2)
            self.arabicSpanishStatus = formatStatus(status3)
        }
    }

    private func formatStatus(_ status: LanguageAvailability.Status) -> String {
        switch status {
        case .installed: return "مثبت محلياً"
        case .supported: return "مدعوم للتنزيل"
        case .unsupported: return "غير مدعوم"
        @unknown default: return "غير معروف"
        }
    }
}
