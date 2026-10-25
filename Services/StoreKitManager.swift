import Foundation
import StoreKit
import Observation

/// StoreKit 2 Subscription and In-App Purchase Manager.
/// Keeps Pro entitlement synchronized across App Groups for Keyboard & Widget.
@MainActor
@Observable
public final class StoreKitManager {
    public static let shared = StoreKitManager()

    // Product identifiers
    public static let yearlyProductID = "com.vava.translator.yearly"
    public static let weeklyProductID = "com.vava.translator.weekly"

    public var isProUser: Bool = false
    public var yearlyProduct: Product? = nil
    public var weeklyProduct: Product? = nil
    public var isLoadingProducts: Bool = false
    public var purchaseErrorMessage: String? = nil

    private var updatesTask: Task<Void, Never>? = nil
    private let sharedDefaults = UserDefaults(suiteName: "group.com.vava.translator") ?? UserDefaults.standard

    public init() {
        // Read cached Pro status from App Group
        self.isProUser = sharedDefaults.bool(forKey: "vava_is_pro_user")
        listenForTransactions()
        Task {
            await loadProducts()
            await refreshCustomerEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    /// Listens for real-time App Store transaction updates (renewals, revocations, family sharing).
    private func listenForTransactions() {
        updatesTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                if let transaction = try? self?.checkVerified(result) {
                    await self?.updateProStatus(true)
                    await transaction.finish()
                }
            }
        }
    }

    /// Loads products from App Store.
    public func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            let products = try await Product.products(for: [Self.yearlyProductID, Self.weeklyProductID])
            for product in products {
                if product.id == Self.yearlyProductID {
                    self.yearlyProduct = product
                } else if product.id == Self.weeklyProductID {
                    self.weeklyProduct = product
                }
            }
        } catch {
            print("Failed to load StoreKit products: \(error)")
        }
    }

    /// Purchases the selected subscription product.
    public func purchase(_ product: Product) async -> Bool {
        purchaseErrorMessage = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updateProStatus(true)
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            purchaseErrorMessage = error.localizedDescription
            return false
        }
    }

    /// Restores prior purchases.
    public func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshCustomerEntitlements()
        } catch {
            purchaseErrorMessage = error.localizedDescription
        }
    }

    /// Refreshes current entitlements.
    public func refreshCustomerEntitlements() async {
        var hasActiveEntitlement = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result), transaction.revocationDate == nil {
                hasActiveEntitlement = true
                break
            }
        }
        await updateProStatus(hasActiveEntitlement)
    }

    private func updateProStatus(_ status: Bool) async {
        self.isProUser = status
        sharedDefaults.set(status, forKey: "vava_is_pro_user")
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}
