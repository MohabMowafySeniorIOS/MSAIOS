//
//  ShopView.swift
//  MSA
//
//  سبائك ومشغولات — القايمة وتفاصيل المنتج.
//  نفس الشاشات في أندرويد (ProductsScreen.kt / ProductDetailsScreen.kt).
//
//  **الأسعار المعروضة جاية محسوبة من السيرفر** — مش بنضرب سعر الجرام
//  × الوزن هنا. السيرفر بيقرا نفس مستندات Firestore اللي الرئيسية
//  بتقرا منها، فالرقم اللي العميل شايفه هو نفسه اللي بيتسجّل في الطلب.
//

import SwiftUI

// MARK: - تنسيق الأرقام

enum ShopFormat {

    private static let money: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        f.locale = Locale(identifier: "en_US")   // أرقام لاتينية زي باقي الشاشات
        return f
    }()

    static func amount(_ value: Double) -> String {
        money.string(from: NSNumber(value: value)) ?? "0.00"
    }

    /**
     الوزن من غير أصفار زايدة: ٢٥٫٥ مش ٢٥٫٥٠٠، و١٠ مش ١٠٫٠٠٠.

     الوزن بيتخزّن بـ٣ خانات عشرية عشان القطع الصغيرة، بس عرض
     «١٠٫٠٠٠ جرام» لسبيكة عشرة جرام بيبان غريب.
     */
    static func grams(_ value: Double) -> String {
        var text = String(format: "%.3f", value)

        while text.hasSuffix("0") { text.removeLast() }
        if text.hasSuffix(".") { text.removeLast() }

        return text
    }
}

// MARK: - المتجر

@MainActor
final class ShopStore: ObservableObject {

    static let shared = ShopStore()
    private init() {}

    @Published private(set) var products: [APIProduct] = []
    @Published private(set) var prices: APIShopPrices?
    @Published private(set) var info: APIShopInfo?
    @Published private(set) var isLoading = false
    @Published private(set) var failed = false

    @Published var kind: String?          // nil = الكل
    @Published private(set) var cartCount = 0

    /**
     مفيش كاش للمنتجات — عكس `BranchStore`.

     الفروع مبتتغيّرش فالكاش عشر دقايق منطقي. هنا السعر بيتغيّر مع
     السوق، والكاش معناه إن العميل يشوف رقم ويطلب برقم تاني. السيرفر
     نفسه بيكاش ٤٥ ثانية وده كفاية.
     */
    func load() async {
        isLoading = products.isEmpty
        failed = false

        do {
            let (list, shopPrices) = try await ShopAPI.products(kind: kind)
            products = list
            prices = shopPrices
            failed = false
        } catch {
            print("ShopStore: تعذّر تحميل المنتجات — \(error)")
            failed = products.isEmpty
        }

        // الإعدادات مش حرجة — فشلها مبيوقّفش الشاشة
        info = try? await ShopAPI.shopInfo()

        isLoading = false

        await refreshCartCount()
    }

    func setKind(_ value: String?) async {
        guard kind != value else { return }

        kind = value
        products = []
        await load()
    }

    /// بيتحدّث من رد السيرفر مش بزيادة محلية: لو السيرفر رفض، العدّاد
    /// لازم يفضل زي ما هو
    func refreshCartCount() async {
        guard AuthSession.shared.token != nil else {
            cartCount = 0
            return
        }

        cartCount = (try? await ShopAPI.cart())?.count ?? cartCount
    }

    func noteCartCount(_ value: Int) { cartCount = value }
}

// MARK: - قايمة المنتجات

struct ShopView: View {

    @StateObject private var store = ShopStore.shared

    @State private var message: String?
    @State private var showMessage = false

    var onBack: (() -> Void)?
    var onOpenProduct: ((Int) -> Void)?
    var onOpenCart: (() -> Void)?
    var onNeedsLogin: (() -> Void)?

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {

                headerView(title: "shop_title".localized, isBackShow: true) {
                    onBack?()
                }

                if store.isLoading {
                    Spacer()
                    ProgressView().tint(Color("MainColor"))
                    Spacer()
                } else if store.failed {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("shop_load_failed".localized)
                            .font(.msa(15))
                            .foregroundColor(.white)

                        Button("retry".localized) { Task { await store.load() } }
                            .font(.msa(15, weight: .bold))
                            .foregroundColor(Color("MainColor"))
                    }
                    Spacer()
                } else {
                    list
                }
            }

            if store.cartCount > 0 {
                cartButton
            }
        }
        .background(BGSwiftUIView())
        .task { await store.load() }
        .alert("", isPresented: $showMessage) {
            Button("موافق".localized, role: .cancel) {}
        } message: {
            Text(message ?? "")
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 10) {

                kindFilter

                if store.prices?.is_stale == true {
                    StaleNoticeView()
                }

                // المتجر مقفول من اللوحة — المنتجات بتفضل معروضة بس
                // الطلب متوقّف
                if store.info?.is_enabled == false {
                    Text("shop_disabled".localized)
                        .font(.msa(13))
                        .foregroundColor(Color(red: 1, green: 0.62, blue: 0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if store.products.isEmpty {
                    Text("shop_empty".localized)
                        .font(.msa(14))
                        .foregroundColor(Color(white: 0.8))
                        .padding(.vertical, 40)
                }

                ForEach(store.products) { product in
                    ProductRowView(
                        product: product,
                        canOrder: store.info?.is_enabled != false,
                        onOpen: { onOpenProduct?(product.id) },
                        onAdd: { Task { await add(product) } }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 110)
        }
        .refreshable { await store.load() }
    }

    private var kindFilter: some View {
        HStack(spacing: 8) {
            chip("shop_kind_all".localized, active: store.kind == nil) {
                Task { await store.setKind(nil) }
            }
            chip("shop_kind_bullion".localized, active: store.kind == "bullion") {
                Task { await store.setKind("bullion") }
            }
            chip("shop_kind_jewellery".localized, active: store.kind == "jewellery") {
                Task { await store.setKind("jewellery") }
            }
            Spacer()
        }
        .padding(.top, 4)
    }

    private func chip(_ label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.msa(13, weight: active ? .bold : .regular))
                .foregroundColor(active ? Color("MainColor") : Color(white: 0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(
                    Capsule().fill(Color("MainColor").opacity(active ? 0.18 : 0.05))
                )
                .overlay(
                    Capsule().stroke(Color("MainColor").opacity(active ? 0.7 : 0.3), lineWidth: 1)
                )
        }
    }

    private var cartButton: some View {
        Button {
            onOpenCart?()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "cart.fill")
                Text(String(format: "shop_view_cart".localized, "\(store.cartCount)"))
                    .font(.msa(14, weight: .bold))
            }
            .foregroundColor(Color(red: 0.25, green: 0.18, blue: 0.17))
            .padding(.horizontal, 22)
            .padding(.vertical, 13)
            .background(Capsule().fill(Color("MainColor")))
        }
        .padding(.bottom, 28)
    }

    private func add(_ product: APIProduct) async {
        do {
            let cart = try await ShopAPI.addToCart(productId: product.id)
            store.noteCartCount(cart.count)
            message = "shop_added_to_cart".localized
            showMessage = true
        } catch let error as ShopAPIError {
            // مش مسجّل دخول — نودّيه لشاشة الدخول بدل رسالة
            if error.isUnauthorized {
                onNeedsLogin?()
            } else {
                message = error.displayMessage
                showMessage = true
            }
        } catch {
            message = "حصل خطأ، جرّب تاني"
            showMessage = true
        }
    }
}

// MARK: - كارت المنتج

struct ProductRowView: View {

    let product: APIProduct
    let canOrder: Bool
    var onOpen: () -> Void
    var onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Button(action: onOpen) {
                HStack(alignment: .top, spacing: 12) {
                    ProductThumb(url: product.listImage, size: 84)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.title)
                            .font(.msa(15, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)

                        SpecLineView(product: product)

                        if product.manufacturingPerGram > 0 {
                            Text(String(format: "shop_manufacturing_per_gram".localized,
                                        ShopFormat.amount(product.manufacturingPerGram)))
                                .font(.msa(11))
                                .foregroundColor(Color(white: 0.62))
                        }

                        PriceLabelView(product: product)
                    }

                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)

            HStack {
                stockLabel

                Spacer()

                Button(action: onAdd) {
                    Text("shop_add_to_cart".localized)
                        .font(.msa(13, weight: .bold))
                        .foregroundColor(Color(red: 0.25, green: 0.18, blue: 0.17))
                        .frame(width: 140, height: 40)
                        .background(Capsule().fill(Color("MainColor")))
                }
                // الزرار بيتقفل لو المخزون خلص أو المتجر مقفول أو
                // السعر لسه ما وصلش — إضافة من غير سعر معناها سلة
                // بإجمالي صفر
                .disabled(!canOrder || !product.in_stock || !product.hasPrice)
                .opacity((!canOrder || !product.in_stock || !product.hasPrice) ? 0.5 : 1)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.4)))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainColor").opacity(0.45), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var stockLabel: some View {
        if !product.in_stock {
            Text("shop_out_of_stock".localized)
                .font(.msa(12, weight: .medium))
                .foregroundColor(Color(red: 1, green: 0.62, blue: 0.6))
        } else if let stock = product.stock, stock <= 5 {
            // بنعرض الكمية بس لما تقلّ — «متاح ٢» بتستعجل القرار،
            // «متاح ٥٠٠» مالهاش أي معنى للعميل
            Text(String(format: "shop_stock_left".localized, "\(stock)"))
                .font(.msa(12))
                .foregroundColor(Color("MainColor"))
        } else {
            EmptyView()
        }
    }
}

// MARK: - عناصر مشتركة

struct ProductThumb: View {
    let url: String?
    var size: CGFloat

    var body: some View {
        AsyncImage(url: URL(string: url ?? "")) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Color.white.opacity(0.08)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

/// «١٠ جرام · عيار ٢٤ · ذهب»
struct SpecLineView: View {
    let product: APIProduct

    var body: some View {
        Text(String(format: "shop_spec_line".localized,
                    ShopFormat.grams(product.weight_grams),
                    "\(product.karat)",
                    (product.isGold ? "metal_gold" : "metal_silver").localized))
            .font(.msa(12))
            .foregroundColor(Color(white: 0.8))
    }
}

/**
 السعر — أو «جاري تحميل السعر» لو لسه ما وصلش.

 ده مش تفصيلة شكلية: لو عرضنا صفر جنيه لما Firestore يتأخّر، العميل
 هيفتكر إن المنتج ببلاش. الرئيسية بتعمل نفس الحاجة بالظبط.
 */
struct PriceLabelView: View {
    let product: APIProduct
    var big: Bool = false

    var body: some View {
        if let price = product.price, price.priced {
            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(ShopFormat.amount(price.total))
                        .font(.msa(big ? 24 : 16, weight: .bold))
                        .foregroundColor(Color("MainColor"))

                    Text("currency_egp".localized)
                        .font(.msa(big ? 14 : 11))
                        .foregroundColor(Color("MainColor").opacity(0.8))
                }

                // سعر الجرام تحت الإجمالي — العميل يقدر يراجع الحساب
                Text(String(format: "shop_gram_price".localized,
                            ShopFormat.amount(price.gram_price)))
                    .font(.msa(big ? 12 : 11))
                    .foregroundColor(Color(white: 0.62))
            }
        } else {
            Text("shop_price_loading".localized)
                .font(.msa(big ? 15 : 13))
                .foregroundColor(Color(white: 0.62))
        }
    }
}

/// تنبيه إن السعر من نسخة محفوظة — Firestore مش راد
struct StaleNoticeView: View {
    var body: some View {
        Text("shop_price_stale".localized)
            .font(.msa(12))
            .foregroundColor(Color(red: 1, green: 0.62, blue: 0.6))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.18))
            )
    }
}

/// صف في ملخّص الحساب
struct ShopSummaryRow: View {
    let label: String
    let value: String
    var bold: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.msa(bold ? 15 : 13, weight: bold ? .bold : .regular))
                .foregroundColor(bold ? .white : Color(white: 0.8))

            Spacer()

            Text(value)
                .font(.msa(bold ? 17 : 13, weight: bold ? .bold : .medium))
                .foregroundColor(bold ? Color("MainColor") : .white)
        }
    }
}

struct ShopCardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.4)))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color("MainColor").opacity(0.45), lineWidth: 1)
            )
    }
}

extension View {
    func shopCard() -> some View { modifier(ShopCardBackground()) }
}

/// عدّاد الكمية — ناقص / رقم / زائد
struct QuantityStepperView: View {
    let quantity: Int
    var enabled: Bool = true
    var onChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 16) {
            stepButton("−", enabled: enabled && quantity > 1) { onChange(quantity - 1) }

            Text("\(quantity)")
                .font(.msa(16, weight: .bold))
                .foregroundColor(.white)
                .frame(minWidth: 24)

            stepButton("+", enabled: enabled) { onChange(quantity + 1) }
        }
    }

    private func stepButton(_ label: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.msa(18, weight: .bold))
                .foregroundColor(Color("MainColor").opacity(enabled ? 1 : 0.35))
                .frame(width: 32, height: 32)
                .background(
                    Circle().fill(Color("MainColor").opacity(enabled ? 0.15 : 0.05))
                )
                .overlay(
                    Circle().stroke(Color("MainColor").opacity(enabled ? 0.5 : 0.15), lineWidth: 1)
                )
        }
        .disabled(!enabled)
    }
}

// MARK: - تفاصيل المنتج

struct ProductDetailsView: View {

    let productId: Int

    @State private var product: APIProduct?
    @State private var quantity = 1
    @State private var isLoading = true
    @State private var failed = false
    @State private var isAdding = false
    @State private var message: String?
    @State private var showMessage = false

    var onBack: (() -> Void)?
    var onOpenCart: (() -> Void)?
    var onNeedsLogin: (() -> Void)?

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {

                headerView(title: "shop_product_details".localized, isBackShow: true) {
                    onBack?()
                }

                if isLoading {
                    Spacer()
                    ProgressView().tint(Color("MainColor"))
                    Spacer()
                } else if failed || product == nil {
                    Spacer()
                    Text("shop_load_failed".localized)
                        .font(.msa(15))
                        .foregroundColor(.white)
                    Spacer()
                } else {
                    details(product!)
                }
            }

            if let product, !isLoading {
                addButton(product)
            }
        }
        .background(BGSwiftUIView())
        .task { await load() }
        .alert("", isPresented: $showMessage) {
            Button("موافق".localized, role: .cancel) {}
        } message: {
            Text(message ?? "")
        }
    }

    private func details(_ product: APIProduct) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                AsyncImage(url: URL(string: product.media_url ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.white.opacity(0.08)
                }
                .frame(height: 230)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(product.title)
                    .font(.msa(20, weight: .bold))
                    .foregroundColor(.white)

                SpecLineView(product: product)

                if let details = product.details {
                    Text(details)
                        .font(.msa(14))
                        .foregroundColor(Color(white: 0.8))
                        .lineSpacing(5)
                }

                breakdown(product)
                modes(product)

                HStack {
                    Text("shop_quantity".localized)
                        .font(.msa(15))
                        .foregroundColor(.white)

                    Spacer()

                    QuantityStepperView(
                        quantity: quantity,
                        enabled: product.in_stock
                    ) { value in
                        // المخزون المفتوح (`nil`) سقفه ٩٩ عشان ما يبقاش
                        // في رقم مفتوح على الآخر في خانة الكمية
                        let max = product.stock ?? 99
                        quantity = min(Swift.max(1, value), Swift.max(1, max))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 130)
        }
    }

    /**
     تفصيل الحساب.

     الأرقام هنا للقطعة الواحدة (زي ما السيرفر رجّعها) مضروبة في
     الكمية **للعرض بس** — السيرفر بيعيد الحساب كامل وقت الإضافة
     للسلة ووقت الطلب، فالرقم النهائي دايماً بتاعه.
     */
    @ViewBuilder
    private func breakdown(_ product: APIProduct) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let price = product.price, price.priced {
                ShopSummaryRow(label: "shop_gram_price_label".localized,
                               value: ShopFormat.amount(price.gram_price))
                ShopSummaryRow(label: "shop_metal_value".localized,
                               value: ShopFormat.amount(price.metal_value * Double(quantity)))

                if price.manufacturing_total > 0 {
                    ShopSummaryRow(label: "shop_manufacturing".localized,
                                   value: ShopFormat.amount(price.manufacturing_total * Double(quantity)))
                }

                if price.tax_amount > 0 {
                    ShopSummaryRow(label: "shop_tax".localized,
                                   value: ShopFormat.amount(price.tax_amount * Double(quantity)))
                }

                Divider().background(Color("MainColor").opacity(0.2))

                ShopSummaryRow(label: "shop_total".localized,
                               value: ShopFormat.amount(price.total * Double(quantity)),
                               bold: true)
            } else {
                Text("shop_price_loading".localized)
                    .font(.msa(14))
                    .foregroundColor(Color(white: 0.62))
            }
        }
        .shopCard()
    }

    private func modes(_ product: APIProduct) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("shop_order_methods".localized)
                .font(.msa(14, weight: .bold))
                .foregroundColor(.white)

            if product.allow_deposit {
                modeLine("shop_mode_deposit".localized, "shop_mode_deposit_hint".localized)
            }

            if product.allow_on_arrival {
                modeLine("shop_mode_on_arrival".localized, "shop_mode_on_arrival_hint".localized)
            }
        }
        .shopCard()
    }

    private func modeLine(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("• \(title)")
                .font(.msa(13, weight: .medium))
                .foregroundColor(Color("MainColor"))

            Text(detail)
                .font(.msa(12))
                .foregroundColor(Color(white: 0.62))
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func addButton(_ product: APIProduct) -> some View {
        Button {
            Task { await add(product) }
        } label: {
            Group {
                if isAdding {
                    ProgressView().tint(Color(red: 0.25, green: 0.18, blue: 0.17))
                } else {
                    Text(product.in_stock
                         ? "shop_add_to_cart".localized
                         : "shop_out_of_stock".localized)
                        .font(.msa(16, weight: .bold))
                        .foregroundColor(Color(red: 0.25, green: 0.18, blue: 0.17))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Capsule().fill(Color("MainColor")))
        }
        .disabled(!product.in_stock || !product.hasPrice || isAdding)
        .opacity((!product.in_stock || !product.hasPrice) ? 0.5 : 1)
        .padding(16)
        .background(Color.black.opacity(0.8))
    }

    private func load() async {
        isLoading = true
        failed = false

        do {
            product = try await ShopAPI.product(id: productId)
        } catch {
            failed = true
        }

        isLoading = false
    }

    private func add(_ product: APIProduct) async {
        isAdding = true

        do {
            let cart = try await ShopAPI.addToCart(productId: product.id, quantity: quantity)
            ShopStore.shared.noteCartCount(cart.count)
            isAdding = false

            // الإضافة نجحت — بنودّيه للسلة على طول بدل ما يدوّر عليها
            onOpenCart?()
        } catch let error as ShopAPIError {
            isAdding = false

            if error.isUnauthorized {
                onNeedsLogin?()
            } else {
                message = error.displayMessage
                showMessage = true
            }
        } catch {
            isAdding = false
            message = "حصل خطأ، جرّب تاني"
            showMessage = true
        }
    }
}
