import Foundation
import Observation

/// Model representing a single conversation turn in Coach James training.
public struct CoachTurn: Identifiable, Hashable, Sendable {
    public let id: Int
    public let promptEn: String
    public let promptAr: String
    public let expectedResponse: String
    public let hintText: String

    public init(id: Int, promptEn: String, promptAr: String, expectedResponse: String, hintText: String) {
        self.id = id
        self.promptEn = promptEn
        self.promptAr = promptAr
        self.expectedResponse = expectedResponse
        self.hintText = hintText
    }
}

/// Scenario definition for interactive language training.
public struct CoachScenario: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let titleAr: String
    public let category: String
    public let iconName: String
    public let turns: [CoachTurn]

    public init(id: String, title: String, titleAr: String, category: String, iconName: String, turns: [CoachTurn]) {
        self.id = id
        self.title = title
        self.titleAr = titleAr
        self.category = category
        self.iconName = iconName
        self.turns = turns
    }
}

/// Interactive AI Coach James learning coordinator.
@Observable
public final class CoachJamesService {
    public static let shared = CoachJamesService()

    public static let sampleScenarios: [CoachScenario] = [
        CoachScenario(
            id: "airport_arrival",
            title: "Airport & Customs",
            titleAr: "الوصول إلى المطار والجوازات",
            category: "سفر",
            iconName: "airplane.arrival",
            turns: [
                CoachTurn(id: 1, promptEn: "Hello! May I see your passport and boarding pass?", promptAr: "مرحباً! هل يمكنني رؤية جواز سفرك وبطاقة صعود الطائرة؟", expectedResponse: "Here is my passport and boarding pass", hintText: "تفضل جواز سفري وتذكرة الصعود"),
                CoachTurn(id: 2, promptEn: "What is the purpose of your visit today?", promptAr: "ما هو الغرض من زيارتك اليوم؟", expectedResponse: "I am here for tourism and vacation", hintText: "أنا هنا للسياحة وقضاء عطلة"),
                CoachTurn(id: 3, promptEn: "How long do you plan to stay in the country?", promptAr: "كم المدة التي تخطط للبقاء فيها؟", expectedResponse: "I will stay for two weeks", hintText: "سأبقى لمدة أسبوعين")
            ]
        ),
        CoachScenario(
            id: "hotel_checkin",
            title: "Hotel Check-In",
            titleAr: "تسجيل الدخول في الفندق",
            category: "إقامة",
            iconName: "bed.double.fill",
            turns: [
                CoachTurn(id: 1, promptEn: "Good afternoon, welcome to Grand Palace Hotel. How can I help you?", promptAr: "مساء الخير، مرحباً بك في فندق جراند بالاس. كيف يمكنني مساعدتك؟", expectedResponse: "I have a reservation under the name Hasan", hintText: "لدي حجز مسبق باسم حسن"),
                CoachTurn(id: 2, promptEn: "Could you please fill out this registration card?", promptAr: "هل يمكنك التكرم بملء بطاقة التسجيل هذه؟", expectedResponse: "Sure, is breakfast included?", hintText: "بالتأكيد، هل الإفطار مشمول؟")
            ]
        ),
        CoachScenario(
            id: "restaurant_order",
            title: "Ordering at a Café",
            titleAr: "طلب القهوة في المقهى",
            category: "يوميات",
            iconName: "cup.and.saucer.fill",
            turns: [
                CoachTurn(id: 1, promptEn: "Hi there! What can I get started for you today?", promptAr: "أهلاً بك! ماذا تود أن تطلب اليوم؟", expectedResponse: "I would like a large latte and a croissant please", hintText: "أود كوب لاتيه كبير وقطعة كرواسون من فضلك"),
                CoachTurn(id: 2, promptEn: "Would you like that for here or to go?", promptAr: "هل تفضل تناوله هنا أم سفري؟", expectedResponse: "To go, please. Do you accept card payment?", hintText: "سفري من فضلك. هل تقبلون الدفع بالبطاقة؟")
            ]
        )
    ]
}
