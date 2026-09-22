//
//  WalletViewModel.swift
//  MSA
//

import Foundation

/// نتيجة زكاة المحفظة — بتتحسب من القطع المسجّلة، فالمستخدم
/// مش محتاج يدخل الأوزان تاني في شاشة الحاسبة.
struct WalletZakat {
    let metal: PortfolioMetal
    let pureGrams: Double
    let nisab: Double
    let isDue: Bool
    let zakatGrams: Double
    let zakatValue: Double
}

@MainActor
final class WalletViewModel: ObservableObject {

    @Published private(set) var loading = true
    @Published private(set) var error: String?
    @Published private(set) var summary = PortfolioSummary.empty
    @Published private(set) var items: [PortfolioItem] = []

    /// الأسعار الحالية — بتتبعت للسيرفر مع كل طلب
    @Published var gold21: Double = 0
    @Published var silver999: Double = 0

    var isLoggedIn: Bool { AuthSession.shared.isLoggedIn }
    var isEmpty: Bool { !loading && isLoggedIn && items.isEmpty }

    func refresh() {
        guard isLoggedIn else {
            loading = false
            items = []
            summary = .empty
            return
        }
        Task {
            loading = true
            error = nil
            do {
                let result = try await PortfolioAPI.load(gold21: gold21, silver999: silver999)
                summary = result.summary
                items = result.items
            } catch let e as AuthAPIError {
                error = e.displayMessage
            } catch {
                self.error = AuthAPIError.network.displayMessage
            }
            loading = false
        }
    }

    func delete(_ item: PortfolioItem) {
        Task {
            do {
                try await PortfolioAPI.delete(id: item.id)
                refresh()
            } catch let e as AuthAPIError {
                error = e.displayMessage
            } catch {
                self.error = AuthAPIError.network.displayMessage
            }
        }
    }

    /// سعر الجرام الحالي للعيار المختار — بيملا الحقل تلقائياً
    func currentGramPrice(metal: PortfolioMetal, karat: String) -> Double {
        guard let k = Double(karat) else { return 0 }
        return metal == .gold ? gold21 * (k / 21) : silver999 * (k / 999)
    }

    /**
     زكاة المحفظة لمعدن واحد.

     بنعمّم معادلة النقاء بدل ما نعدّد العيارات — كده عيار 14
     الموجود في المحفظة بيتحسب صح من غير حالة خاصة.
     */
    func zakat(for metal: PortfolioMetal) -> WalletZakat {
        let owned = items.filter { $0.metalKind == metal }

        let pure = owned.reduce(0.0) { total, item in
            let karat = Double(item.karat) ?? 0
            return total + item.weight * (karat / metal.purityScale)
        }

        let due = pure >= metal.nisab
        let grams = due ? pure * 0.025 : 0

        // سعر الجرام الخالص: عيار 24 للذهب، وعيار 999 للفضة
        let purePrice = metal == .gold ? gold21 * (24.0 / 21.0) : silver999

        return WalletZakat(
            metal: metal, pureGrams: pure, nisab: metal.nisab,
            isDue: due, zakatGrams: grams, zakatValue: grams * purePrice
        )
    }
}

@MainActor
final class WalletEditorViewModel: ObservableObject {

    @Published var busy = false
    @Published var error: String?
    @Published var saved = false

    func clearError() { error = nil }

    func save(_ draft: PortfolioDraft, existingId: Int?) {
        Task {
            busy = true
            error = nil
            do {
                try await PortfolioAPI.save(draft, existingId: existingId)
                busy = false
                saved = true
            } catch let e as AuthAPIError {
                busy = false
                error = e.displayMessage
            } catch {
                busy = false
                self.error = AuthAPIError.network.displayMessage
            }
        }
    }
}

// MARK: - تنسيق الأرقام

enum WalletFormat {
    /// أرقام إنجليزية بفاصلة آلاف — الجداول تفضل متساوية العرض في اللغتين
    static func money(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: "en_US_POSIX")
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: value)) ?? "0.00"
    }

    static func grams(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: "en_US_POSIX")
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: value)) ?? "0"
    }
}
