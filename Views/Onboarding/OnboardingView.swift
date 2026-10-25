import SwiftUI

/// Multi-step onboarding experience welcoming the user to VAVA Translator.
public struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    @State private var showingPaywall = false

    private let steps: [OnboardingStep] = [
        OnboardingStep(
            icon: "globe.europe.africa.fill",
            title: "عالمك بلا حواجز لغوية",
            subtitle: "ترجمة عصبية فورية لأكثر من 20 لغة عالمية، تعمل مباشرة على شريحة هاتفك بأعلى معايير الخصوصية والسرعة."
        ),
        OnboardingStep(
            icon: "camera.viewfinder",
            title: "ترجمة بصرية فائقة الدقة",
            subtitle: "وجّه الكاميرا نحو أي لافتة، قائمة طعام، أو وثيقة، وشاهد الترجمة العربية تظهر فوراً فوق النص الأصلي."
        ),
        OnboardingStep(
            icon: "bolt.horizontal.icloud.fill",
            title: "حرية كاملة بدون إنترنت",
            subtitle: "سافر واعمل دون القلق بشأن باقة البيانات. نزّل حزم اللغات لمرة واحدة وترجم في أي مكان حول العالم."
        ),
        OnboardingStep(
            icon: "person.crop.circle.badge.checkmark",
            title: "تعلّم وتحدّث بثقة مع James",
            subtitle: "مدربك اللغوي التفاعلي يساعدك على ممارسة المحادثات اليومية في المطار، الفندق، والمطاعم بنطق سليم."
        )
    ]

    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    public var body: some View {
        ZStack {
            Color.vavaScreenBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Skip Button
                HStack {
                    Spacer()
                    Button("تخطي") {
                        completeOnboarding()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                }

                Spacer()

                // Step Carousel
                TabView(selection: $currentStep) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        stepCard(steps[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(maxHeight: 460)

                Spacer()

                // Bottom Action Button
                VStack(spacing: 16) {
                    Button {
                        if currentStep < steps.count - 1 {
                            withAnimation { currentStep += 1 }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        Text(currentStep == steps.count - 1 ? "ابدأ الآن" : "متابعة")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(LinearGradient.vavaHero)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: Color.vavaPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .onDisappear {
                    isPresented = false
                }
        }
    }

    private func stepCard(_ step: OnboardingStep) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.vavaPrimary.opacity(0.12))
                    .frame(width: 120, height: 120)
                Image(systemName: step.icon)
                    .font(.system(size: 54))
                    .foregroundStyle(LinearGradient.vavaHero)
            }

            VStack(spacing: 12) {
                Text(step.title)
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(step.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.horizontal)
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "vava_has_completed_onboarding")
        showingPaywall = true
    }
}

private struct OnboardingStep {
    let icon: String
    let title: String
    let subtitle: String
}
