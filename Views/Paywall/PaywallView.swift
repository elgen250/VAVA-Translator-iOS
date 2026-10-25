import SwiftUI
import StoreKit

/// StoreKit 2 Subscription Paywall for VAVA Pro.
public struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var storeKit = StoreKitManager.shared
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var isPurchasing = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Close button
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Hero Graphic & Title
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient.vavaHero.opacity(0.15))
                                .frame(width: 90, height: 90)
                            Image(systemName: "crown.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(LinearGradient.vavaHero)
                        }

                        Text("VAVA Pro")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundStyle(.primary)

                        Text("افتح قوة الترجمة العصبية الكاملة على جهازك")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    // Feature List
                    VStack(alignment: .leading, spacing: 14) {
                        featureRow(icon: "sparkles", text: "ترجمة فورية عصبية بلا حدود لـ 20 لغة")
                        featureRow(icon: "camera.viewfinder", text: "ترجمة حية ومباشرة بالكاميرا للوثائق واللافتات")
                        featureRow(icon: "keyboard.fill", text: "لوحة مفاتيح مترجمة في كل تطبيقات iOS")
                        featureRow(icon: "bubble.left.and.bubble.right.fill", text: "محادثة صوتية ثنائية بدون إنترنت")
                        featureRow(icon: "person.crop.circle.badge.checkmark", text: "تدريب ومحادثات غير محدودة مع المدرب James")
                    }
                    .padding(20)
                    .background(Color.vavaCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.vavaBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)

                    // Subscription Plans Selector
                    VStack(spacing: 12) {
                        // Yearly Plan (Best Value)
                        planCard(
                            plan: .yearly,
                            title: "الاشتراك السنوي",
                            priceText: "$39.99 / سنة",
                            badgeText: "الأفضل قيمة • $0.77 / أسبوع",
                            isBadgeHero: true
                        )

                        // Weekly Plan (Most Popular)
                        planCard(
                            plan: .weekly,
                            title: "الاشتراك الأسبوعي",
                            priceText: "$4.99 / أسبوع",
                            badgeText: "الأكثر شيوعاً",
                            isBadgeHero: false
                        )
                    }
                    .padding(.horizontal)

                    // Call to Action Button
                    Button {
                        handleSubscribe()
                    } label: {
                        HStack {
                            if isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("بدء تجربة مجانية لمدة 3 أيام")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient.vavaHero)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.vavaPrimary.opacity(0.35), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(.plain)
                    .disabled(isPurchasing)
                    .padding(.horizontal)

                    // Footer links
                    HStack(spacing: 24) {
                        Button("استعادة المشتريات") {
                            Task { await storeKit.restorePurchases() }
                        }
                        Text("•").foregroundStyle(.tertiary)
                        Button("شروط الخدمة") {}
                        Text("•").foregroundStyle(.tertiary)
                        Button("سياسة الخصوصية") {}
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.vavaScreenBackground.ignoresSafeArea())
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.vavaPrimary)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }

    private func planCard(plan: SubscriptionPlan, title: String, priceText: String, badgeText: String, isBadgeHero: Bool) -> some View {
        let isSelected = selectedPlan == plan

        return Button {
            selectedPlan = plan
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.bold)
                        Text(badgeText)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(isBadgeHero ? .white : Color.vavaPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(isBadgeHero ? Color.vavaPrimary : Color.vavaPrimary.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    Text("3 أيام تجربة مجانية، ثم \(priceText)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.vavaPrimary : Color.secondary.opacity(0.4))
            }
            .padding(16)
            .background(Color.vavaCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.vavaPrimary : Color.vavaBorder, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func handleSubscribe() {
        isPurchasing = true
        Task {
            let product = selectedPlan == .yearly ? storeKit.yearlyProduct : storeKit.weeklyProduct
            if let product {
                _ = await storeKit.purchase(product)
            }
            isPurchasing = false
            if storeKit.isProUser {
                dismiss()
            }
        }
    }
}

public enum SubscriptionPlan {
    case yearly
    case weekly
}
