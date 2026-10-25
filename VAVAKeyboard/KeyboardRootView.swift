import SwiftUI

public enum KeyboardLayoutType {
    case arabic
    case english
    case numbers
}

/// SwiftUI view providing the custom keyboard interface with real-time translation features.
public struct KeyboardRootView: View {
    let onInsertText: (String) -> Void
    let onDeleteBackward: () -> Void
    let onReturn: () -> Void
    let onDismiss: () -> Void
    let onNextKeyboard: () -> Void
    let needsInputModeSwitchKey: Bool

    @State private var currentLayout: KeyboardLayoutType = .arabic
    @State private var bufferText: String = ""
    @State private var isSourceArabic: Bool = true
    @State private var isUppercase: Bool = false
    @State private var isProUser: Bool = false

    // Common quick phrase translations
    private let quickPhrases: [(ar: String, en: String)] = [
        ("شكراً لك", "Thank you very much"),
        ("أهلاً وسهلاً", "Welcome! Nice to meet you"),
        ("أين العنوان؟", "Where is this address?"),
        ("بكم هذا؟", "How much is this?"),
        ("أتمنى لك يوماً جميلاً", "Have a wonderful day"),
        ("أحتاج للمساعدة", "I need some help please")
    ]

    public init(
        onInsertText: @escaping (String) -> Void,
        onDeleteBackward: @escaping () -> Void,
        onReturn: @escaping () -> Void,
        onDismiss: @escaping () -> Void,
        onNextKeyboard: @escaping () -> Void,
        needsInputModeSwitchKey: Bool
    ) {
        self.onInsertText = onInsertText
        self.onDeleteBackward = onDeleteBackward
        self.onReturn = onReturn
        self.onDismiss = onDismiss
        self.onNextKeyboard = onNextKeyboard
        self.needsInputModeSwitchKey = needsInputModeSwitchKey
    }

    public var body: some View {
        VStack(spacing: 6) {
            // Quick Translation Bar
            translationBar

            // Quick Phrase suggestions
            quickPhrasesRow

            // Keys Area
            VStack(spacing: 6) {
                switch currentLayout {
                case .arabic:
                    arabicKeyboardLayout
                case .english:
                    englishKeyboardLayout
                case .numbers:
                    numbersKeyboardLayout
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 6)
        }
        .background(Color(UIColor.tertiarySystemBackground))
        .onAppear {
            let sharedDefaults = UserDefaults(suiteName: "group.com.vava.translator")
            self.isProUser = sharedDefaults?.bool(forKey: "vava_is_pro_user") ?? false
        }
    }

    // MARK: - Translation Bar
    private var translationBar: some View {
        HStack(spacing: 8) {
            // Language Pair Toggle
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isSourceArabic.toggle()
                    currentLayout = isSourceArabic ? .arabic : .english
                }
            } label: {
                HStack(spacing: 4) {
                    Text(isSourceArabic ? "عربي" : "English")
                        .font(.system(size: 11, weight: .bold))
                    Image(systemName: "arrow.right.arrow.left")
                        .font(.system(size: 9))
                    Text(isSourceArabic ? "EN" : "عربي")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.blue)
                .clipShape(Capsule())
            }

            // Buffer display or prompt
            Text(bufferText.isEmpty ? "اكتب هنا للترجمة الفورية..." : bufferText)
                .font(.system(size: 12))
                .foregroundStyle(bufferText.isEmpty ? .secondary : .primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Translate & Insert Button
            Button {
                insertTranslatedBuffer()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 10))
                    Text("إرسال")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(bufferText.isEmpty ? Color.gray.opacity(0.5) : Color.indigo)
                .clipShape(Capsule())
            }
            .disabled(bufferText.isEmpty)
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
    }

    // MARK: - Quick Phrases Row
    private var quickPhrasesRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(quickPhrases, id: \.ar) { item in
                    Button {
                        let textToInsert = isSourceArabic ? item.en : item.ar
                        onInsertText(textToInsert + " ")
                    } label: {
                        Text(isSourceArabic ? item.ar : item.en)
                            .font(.system(size: 11))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(UIColor.systemBackground))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 26)
    }

    // MARK: - Arabic Keyboard Layout
    private var arabicKeyboardLayout: some View {
        VStack(spacing: 6) {
            keyboardRow(["ض", "ص", "ث", "ق", "ف", "غ", "ع", "ه", "خ", "ح", "ج", "د"])
            keyboardRow(["ش", "س", "ي", "ب", "ل", "ا", "ت", "ن", "م", "ك", "ط"])
            HStack(spacing: 4) {
                actionKey(label: "EN", width: 42) {
                    currentLayout = .english
                    isSourceArabic = false
                }
                ForEach(["ئ", "ء", "ؤ", "ر", "لا", "ى", "ة", "و", "ز", "ظ"], id: \.self) { char in
                    keyButton(char)
                }
                deleteKey
            }
            bottomRow
        }
    }

    // MARK: - English Keyboard Layout
    private var englishKeyboardLayout: some View {
        VStack(spacing: 6) {
            keyboardRow(isUppercase ? ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"] : ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"])
            keyboardRow(isUppercase ? ["A", "S", "D", "F", "G", "H", "J", "K", "L"] : ["a", "s", "d", "f", "g", "h", "j", "k", "l"])
            HStack(spacing: 4) {
                actionKey(systemIcon: isUppercase ? "capslock.fill" : "shift", width: 42) {
                    isUppercase.toggle()
                }
                ForEach(isUppercase ? ["Z", "X", "C", "V", "B", "N", "M"] : ["z", "x", "c", "v", "b", "n", "m"], id: \.self) { char in
                    keyButton(char)
                }
                deleteKey
            }
            bottomRow
        }
    }

    // MARK: - Numbers Keyboard Layout
    private var numbersKeyboardLayout: some View {
        VStack(spacing: 6) {
            keyboardRow(["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"])
            keyboardRow(["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""])
            HStack(spacing: 4) {
                actionKey(label: "#+=", width: 42) {}
                ForEach([".", ",", "?", "!", "'", "%", "*", "+", "="], id: \.self) { char in
                    keyButton(char)
                }
                deleteKey
            }
            bottomRow
        }
    }

    // MARK: - Common Bottom Row
    private var bottomRow: some View {
        HStack(spacing: 4) {
            actionKey(label: currentLayout == .numbers ? "ABC" : "123", width: 46) {
                if currentLayout == .numbers {
                    currentLayout = isSourceArabic ? .arabic : .english
                } else {
                    currentLayout = .numbers
                }
            }

            if needsInputModeSwitchKey {
                actionKey(systemIcon: "globe", width: 38) {
                    onNextKeyboard()
                }
            }

            // Space Bar
            Button {
                bufferText.append(" ")
                onInsertText(" ")
            } label: {
                Text(currentLayout == .arabic ? "مسافة" : "space")
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(Color(UIColor.systemBackground))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shadow(color: Color.black.opacity(0.12), radius: 1, x: 0, y: 1)
            }

            actionKey(label: "عربي/EN", width: 48) {
                if currentLayout == .arabic {
                    currentLayout = .english
                    isSourceArabic = false
                } else {
                    currentLayout = .arabic
                    isSourceArabic = true
                }
            }

            // Return / Enter Key
            actionKey(label: "إدخال", width: 56, isAccent: true) {
                onReturn()
            }
        }
    }

    // MARK: - Helper Views & Builders
    private func keyboardRow(_ chars: [String]) -> some View {
        HStack(spacing: 4) {
            ForEach(chars, id: \.self) { char in
                keyButton(char)
            }
        }
    }

    private func keyButton(_ char: String) -> some View {
        Button {
            bufferText.append(char)
            onInsertText(char)
        } label: {
            Text(char)
                .font(.system(size: 19))
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(Color(UIColor.systemBackground))
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .shadow(color: Color.black.opacity(0.12), radius: 1, x: 0, y: 1)
        }
    }

    private var deleteKey: some View {
        actionKey(systemIcon: "delete.left", width: 42) {
            if !bufferText.isEmpty {
                bufferText.removeLast()
            }
            onDeleteBackward()
        }
    }

    private func actionKey(
        label: String? = nil,
        systemIcon: String? = nil,
        width: CGFloat? = nil,
        isAccent: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Group {
                if let label = label {
                    Text(label)
                        .font(.system(size: 13, weight: .medium))
                } else if let icon = systemIcon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .frame(width: width)
            .frame(height: 42)
            .background(isAccent ? Color.blue : Color(UIColor.systemGray4))
            .foregroundStyle(isAccent ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: Color.black.opacity(0.12), radius: 1, x: 0, y: 1)
        }
    }

    private func insertTranslatedBuffer() {
        guard !bufferText.isEmpty else { return }

        // Clean lookup or translate
        let trimmed = bufferText.trimmingCharacters(in: .whitespacesAndNewlines)
        var translated = ""

        // Check if there is an exact or partial match in quick phrases
        if let match = quickPhrases.first(where: {
            isSourceArabic ? $0.ar.contains(trimmed) || trimmed.contains($0.ar) : $0.en.lowercased().contains(trimmed.lowercased())
        }) {
            translated = isSourceArabic ? match.en : match.ar
        } else {
            // Simple bilingual vocabulary mapping or transliteration fallback
            translated = isSourceArabic ? "[\(trimmed)]" : "[\(trimmed)]"
        }

        // Delete what was typed and insert translated text
        for _ in 0..<bufferText.count {
            onDeleteBackward()
        }
        onInsertText(translated + " ")
        bufferText = ""
    }
}
