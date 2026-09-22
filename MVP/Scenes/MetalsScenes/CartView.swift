//
//  CartView.swift
//  MSA
//
//  السلة وإتمام الطلب، وشاشة «طلباتي».
//  نفس الشاشات في أندرويد (CartScreen.kt / OrdersScreen.kt).
//
//  السلة نفسها في **السيرفر** مش في التطبيق: كده الإجمالي اللي العميل
//  شايفه هو نفسه اللي بيتسجّل في الطلب، ومفيش فرصة إن جهازين يحسبوا
//  نتيجتين مختلفتين.
//

import SwiftUI
import CoreLocation

// MARK: - السلة وإتمام الطلب

struct CartView: View {

    @State private var cart: APICart?
    @State private var info: APIShopInfo?
    @State private var branches: [APIBranch] = []
    @State private var selectedBranch: Int?

    @State private var mode = "deposit"
    @State private var note = ""

    @State private var isLoading = true
    @State private var isPlacing = false
    @State private var message: String?
    @State private var showMessage = false

    @StateObject private var location = UserLocationProvider()

    var onBack: (() -> Void)?
    var onOrderPlaced: ((Int) -> Void)?
    var onBrowseProducts: (() -> Void)?

    /**
     الطريقة متاحة لكل المنتجات اللي في السلة؟

     المشرف بيقدر يقفل «بعربون» على منتج معيّن، والسيرفر بيرفض الطلب
     كله ساعتها — فالأحسن نخفي الاختيار من الأول بدل ما المستخدم
     يملا البيانات وياخد رفض.
     */
    private var depositAllowed: Bool {
        guard let items = cart?.items, !items.isEmpty else { return false }
        return items.allSatisfy { $0.product?.allow_deposit ?? false }
    }

    private var onArrivalAllowed: Bool {
        guard let items = cart?.items, !items.isEmpty else { return false }
        return items.allSatisfy { $0.product?.allow_on_arrival ?? false }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {

                headerView(title: "cart_title".localized, isBackShow: true) {
                    onBack?()
                }

                if isLoading {
                    Spacer()
                    ProgressView().tint(Color("MainColor"))
                    Spacer()
                } else if cart?.isEmpty != false {
                    emptyState
                } else {
                    content
                }
            }

            if cart?.isEmpty == false, !isLoading {
                placeBar
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

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()

            Text("cart_empty".localized)
                .font(.msa(15))
                .foregroundColor(.white)

            Button("cart_browse_products".localized) { onBrowseProducts?() }
                .font(.msa(15, weight: .bold))
                .foregroundColor(Color("MainColor"))

            Spacer()
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                if cart?.prices?.is_stale == true {
                    StaleNoticeView()
                }

                ForEach(cart?.items ?? []) { item in
                    if let product = item.product {
                        cartLine(item: item, product: product)
                    }
                }

                totals
                modePicker

                // تعليمات دفع العربون بتتكتب من اللوحة، فبتتغيّر من غير
                // تحديث للتطبيق
                if mode == "deposit",
                   let instructions = info?.deposit_instructions?.value,
                   !instructions.isEmpty {
                    Text(instructions)
                        .font(.msa(13))
                        .foregroundColor(Color(white: 0.8))
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .shopCard()
                }

                branchPicker
                noteField

                if let terms = info?.terms?.value, !terms.isEmpty {
                    Text(terms)
                        .font(.msa(11))
                        .foregroundColor(Color(white: 0.62))
                        .lineSpacing(3)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 150)
        }
    }

    private func cartLine(item: APICartItem, product: APIProduct) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                ProductThumb(url: product.listImage, size: 64)

                VStack(alignment: .leading, spacing: 3) {
                    Text(product.title)
                        .font(.msa(14, weight: .bold))
                        .foregroundColor(.white)

                    SpecLineView(product: product)

                    Text(ShopFormat.amount(item.line_total))
                        .font(.msa(15, weight: .bold))
                        .foregroundColor(Color("MainColor"))
                }

                Spacer(minLength: 0)

                Button("cart_remove".localized) {
                    Task { await setQuantity(product.id, 0) }
                }
                .font(.msa(12))
                .foregroundColor(Color(red: 1, green: 0.62, blue: 0.6))
            }

            HStack {
                Spacer()
                QuantityStepperView(quantity: item.quantity) { value in
                    Task { await setQuantity(product.id, value) }
                }
            }
        }
        .shopCard()
    }

    private var totals: some View {
        VStack(alignment: .leading, spacing: 8) {
            let t = cart?.totals

            ShopSummaryRow(label: "shop_metal_value".localized,
                           value: ShopFormat.amount(t?.metal_total ?? 0))

            if (t?.manufacturing_total ?? 0) > 0 {
                ShopSummaryRow(label: "shop_manufacturing".localized,
                               value: ShopFormat.amount(t?.manufacturing_total ?? 0))
            }

            if (t?.tax_total ?? 0) > 0 {
                ShopSummaryRow(label: "shop_tax".localized,
                               value: ShopFormat.amount(t?.tax_total ?? 0))
            }

            Divider().background(Color("MainColor").opacity(0.2))

            ShopSummaryRow(label: "shop_total".localized,
                           value: ShopFormat.amount(t?.total ?? 0),
                           bold: true)

            /*
             في «التسعير عند الاستلام» الرقم ده تقديري — السعر بيتحسب
             تاني وقت ما العميل يوصل الفرع. لازم يعرف ده قبل ما يطلب،
             مش لما يتفاجئ في الفرع.
             */
            if mode == "on_arrival" {
                Text("cart_estimate_note".localized)
                    .font(.msa(11))
                    .foregroundColor(Color("MainColor"))
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .shopCard()
    }

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("cart_how_to_order".localized)
                .font(.msa(15, weight: .bold))
                .foregroundColor(.white)

            if depositAllowed {
                optionRow(
                    selected: mode == "deposit",
                    title: "shop_mode_deposit".localized,
                    detail: String(format: "cart_deposit_detail".localized,
                                   ShopFormat.amount(cart?.totals?.deposit_amount ?? 0),
                                   "\(Int(info?.deposit_percent ?? 0))",
                                   "\(info?.lock_hours ?? 24)")
                ) { mode = "deposit" }
            }

            if onArrivalAllowed {
                optionRow(
                    selected: mode == "on_arrival",
                    title: "shop_mode_on_arrival".localized,
                    detail: "shop_mode_on_arrival_hint".localized
                ) { mode = "on_arrival" }
            }
        }
        .shopCard()
    }

    private func optionRow(selected: Bool, title: String, detail: String,
                           action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 10) {
                radioDot(selected)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.msa(14, weight: .bold))
                        .foregroundColor(selected ? Color("MainColor") : .white)
                        .multilineTextAlignment(.leading)

                    Text(detail)
                        .font(.msa(12))
                        .foregroundColor(Color(white: 0.8))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(3)
                }

                Spacer(minLength: 0)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("MainColor").opacity(selected ? 0.12 : 0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("MainColor").opacity(selected ? 0.7 : 0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func radioDot(_ selected: Bool) -> some View {
        Circle()
            .stroke(Color("MainColor").opacity(selected ? 1 : 0.4), lineWidth: 1.5)
            .frame(width: 18, height: 18)
            .overlay(
                Circle()
                    .fill(Color("MainColor"))
                    .frame(width: 9, height: 9)
                    .opacity(selected ? 1 : 0)
            )
    }

    /**
     اختيار فرع الاستلام.

     القايمة جاية مرتّبة بالأقرب من السيرفر لو الموقع متاح، وأول فرع
     بيبقى مختار تلقائياً — ده المتوقّع في أغلب الحالات.
     */
    private var branchPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("cart_pickup_branch".localized)
                .font(.msa(15, weight: .bold))
                .foregroundColor(.white)

            if branches.isEmpty {
                Text("branches_empty".localized)
                    .font(.msa(13))
                    .foregroundColor(Color(white: 0.8))
            }

            ForEach(branches) { branch in
                Button {
                    selectedBranch = branch.id
                } label: {
                    HStack(spacing: 10) {
                        radioDot(branch.id == selectedBranch)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(branch.name)
                                .font(.msa(14, weight: .medium))
                                .foregroundColor(branch.id == selectedBranch
                                                 ? Color("MainColor") : .white)

                            if let address = branch.address {
                                Text(address)
                                    .font(.msa(11))
                                    .foregroundColor(Color(white: 0.62))
                                    .multilineTextAlignment(.leading)
                            }
                        }

                        Spacer(minLength: 0)

                        if let km = branch.distance_km {
                            Text(String(format: "branch_distance_km".localized,
                                        ShopFormat.amount(km)))
                                .font(.msa(11))
                                .foregroundColor(Color("MainColor").opacity(0.8))
                        }
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .shopCard()
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("cart_note".localized)
                .font(.msa(14, weight: .bold))
                .foregroundColor(.white)

            TextField("cart_note_hint".localized, text: $note, axis: .vertical)
                .font(.msa(13))
                .foregroundColor(.white)
                .lineLimit(3, reservesSpace: true)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.25)))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("MainColor").opacity(0.25), lineWidth: 1)
                )
                .onChange(of: note) { value in
                    if value.count > 1000 { note = String(value.prefix(1000)) }
                }
        }
        .shopCard()
    }

    private var placeBar: some View {
        VStack(spacing: 8) {
            Button {
                Task { await place() }
            } label: {
                Group {
                    if isPlacing {
                        ProgressView().tint(Color(red: 0.25, green: 0.18, blue: 0.17))
                    } else {
                        Text((mode == "deposit"
                              ? "cart_place_with_deposit"
                              : "cart_place_on_arrival").localized)
                            .font(.msa(16, weight: .bold))
                            .foregroundColor(Color(red: 0.25, green: 0.18, blue: 0.17))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Capsule().fill(Color("MainColor")))
            }
            // الطلب من غير سعر معناه إجمالي صفر، والسيرفر هيرفضه برضه
            .disabled(!canPlace || isPlacing)
            .opacity(canPlace ? 1 : 0.5)

            if selectedBranch == nil {
                Text("cart_pick_branch_first".localized)
                    .font(.msa(12))
                    .foregroundColor(Color(red: 1, green: 0.62, blue: 0.6))
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.8))
    }

    private var canPlace: Bool {
        (cart?.totals?.priced ?? false)
            && (info?.is_enabled ?? true)
            && selectedBranch != nil
    }

    // MARK: العمليات

    private func load() async {
        isLoading = true

        cart = try? await ShopAPI.cart()
        info = try? await ShopAPI.shopInfo()

        pickDefaultMode()

        // بنبعت الموقع لو متاح عشان السيرفر يرتّب بالأقرب — نفس شاشة
        // الفروع. مش بنطلب الإذن من هنا: لو المستخدم رفضه قبل كده،
        // القايمة بتيجي بترتيب اللوحة وهو يختار بنفسه.
        location.refreshAccess()
        let coordinate = location.access == .granted ? await location.current() : nil

        await BranchStore.shared.load(coordinate: coordinate)
        branches = BranchStore.shared.branches

        if selectedBranch == nil { selectedBranch = branches.first?.id }

        isLoading = false
    }

    /// أول طريقة متاحة بتبقى المختارة — بدل ما الشاشة تفتح على اختيار مرفوض
    private func pickDefaultMode() {
        if depositAllowed { mode = "deposit" }
        else if onArrivalAllowed { mode = "on_arrival" }
    }

    private func setQuantity(_ productId: Int, _ quantity: Int) async {
        do {
            cart = try await ShopAPI.setQuantity(productId: productId, quantity: quantity)
            ShopStore.shared.noteCartCount(cart?.count ?? 0)
            pickDefaultMode()
        } catch let error as ShopAPIError {
            message = error.displayMessage
            showMessage = true
        } catch {
            message = "حصل خطأ، جرّب تاني"
            showMessage = true
        }
    }

    private func place() async {
        isPlacing = true

        do {
            let order = try await ShopAPI.placeOrder(
                mode: mode,
                branchId: selectedBranch,
                note: note
            )

            // السلة بتتفضّى في السيرفر مع نجاح الطلب
            cart = nil
            ShopStore.shared.noteCartCount(0)
            isPlacing = false

            onOrderPlaced?(order.id)
        } catch let error as ShopAPIError {
            isPlacing = false
            message = error.displayMessage
            showMessage = true
        } catch {
            isPlacing = false
            message = "حصل خطأ، جرّب تاني"
            showMessage = true
        }
    }
}

// MARK: - طلباتي

struct OrdersView: View {

    @State private var orders: [APIOrder] = []
    @State private var isLoading = true
    @State private var failed = false
    @State private var expanded: Set<Int> = []
    @State private var confirmingCancel: Int?
    @State private var message: String?
    @State private var showMessage = false

    /// الطلب اللي لسه اتعمل بيتفتح مفتوح عشان العميل يشوف الكود على طول
    var highlightOrderId: Int?

    var onBack: (() -> Void)?
    var onBrowseProducts: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {

            headerView(title: "orders_title".localized, isBackShow: true) {
                onBack?()
            }

            if isLoading {
                Spacer()
                ProgressView().tint(Color("MainColor"))
                Spacer()
            } else if failed {
                Spacer()
                VStack(spacing: 12) {
                    Text("shop_load_failed".localized)
                        .font(.msa(15))
                        .foregroundColor(.white)

                    Button("retry".localized) { Task { await load() } }
                        .font(.msa(15, weight: .bold))
                        .foregroundColor(Color("MainColor"))
                }
                Spacer()
            } else if orders.isEmpty {
                Spacer()
                VStack(spacing: 14) {
                    Text("orders_empty".localized)
                        .font(.msa(15))
                        .foregroundColor(.white)

                    Button("cart_browse_products".localized) { onBrowseProducts?() }
                        .font(.msa(15, weight: .bold))
                        .foregroundColor(Color("MainColor"))
                }
                Spacer()
            } else {
                list
            }
        }
        .background(BGSwiftUIView())
        .task {
            if let highlightOrderId { expanded.insert(highlightOrderId) }
            await load()
        }
        .alert("", isPresented: $showMessage) {
            Button("موافق".localized, role: .cancel) {}
        } message: {
            Text(message ?? "")
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(orders) { order in
                    orderCard(order)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private func orderCard(_ order: APIOrder) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            Button {
                if expanded.contains(order.id) { expanded.remove(order.id) }
                else { expanded.insert(order.id) }
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(order.code)
                                .font(.msa(16, weight: .bold))
                                .foregroundColor(Color("MainColor"))

                            Text(order.shortDate)
                                .font(.msa(11))
                                .foregroundColor(Color(white: 0.62))
                        }

                        Spacer()

                        statusBadge(order)
                    }

                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(ShopFormat.amount(order.total))
                                .font(.msa(18, weight: .bold))
                                .foregroundColor(.white)

                            Text((order.isEstimate
                                  ? "orders_estimate_label"
                                  : "orders_locked_label").localized)
                                .font(.msa(11))
                                .foregroundColor(order.isEstimate
                                                 ? Color("MainColor")
                                                 : Color(red: 0.48, green: 0.83, blue: 0.56))
                        }

                        Spacer()

                        if let branch = order.branch {
                            Text(branch.name)
                                .font(.msa(12))
                                .foregroundColor(Color(white: 0.8))
                        }
                    }

                    // العربون أهم سطر في الكارت لما يكون مستنّي دفع
                    if let deposit = order.deposit, deposit.exists {
                        HStack {
                            Text("orders_deposit".localized)
                                .font(.msa(12))
                                .foregroundColor(Color(white: 0.8))

                            Spacer()

                            Text("\(ShopFormat.amount(deposit.amount)) · \(deposit.text)")
                                .font(.msa(12, weight: .medium))
                                .foregroundColor(deposit.isPaid
                                                 ? Color(red: 0.48, green: 0.83, blue: 0.56)
                                                 : Color("MainColor"))
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            if expanded.contains(order.id) {
                Divider().background(Color("MainColor").opacity(0.2))

                ForEach(order.lines) { line in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(line.title)
                                .font(.msa(13))
                                .foregroundColor(.white)

                            Text("\(ShopFormat.grams(line.weight_grams))g · \(line.karat) · ×\(line.quantity)")
                                .font(.msa(11))
                                .foregroundColor(Color(white: 0.62))
                        }

                        Spacer()

                        Text(ShopFormat.amount(line.line_total))
                            .font(.msa(13))
                            .foregroundColor(Color("MainColor"))
                    }
                }

                /*
                 تثبيت السعر انتهى — الطلب بقى بيتسعّر وقت الاستلام.
                 ده تغيير جوهري في شروط الطلب فلازم يبان بوضوح.
                 */
                if order.isDeposit, order.price_lock_expired {
                    Text("orders_lock_expired".localized)
                        .font(.msa(12))
                        .foregroundColor(Color(red: 1, green: 0.62, blue: 0.6))
                        .lineSpacing(3)
                }

                if let note = order.note, !note.isEmpty {
                    Text(note)
                        .font(.msa(12))
                        .foregroundColor(Color(white: 0.62))
                }

                if order.can_cancel {
                    Divider().background(Color("MainColor").opacity(0.2))

                    if confirmingCancel == order.id {
                        HStack(spacing: 10) {
                            Button("orders_cancel_confirm".localized) {
                                confirmingCancel = nil
                                Task { await cancel(order.id) }
                            }
                            .font(.msa(13, weight: .bold))
                            .foregroundColor(Color(red: 1, green: 0.62, blue: 0.6))

                            Button("orders_cancel_keep".localized) {
                                confirmingCancel = nil
                            }
                            .font(.msa(13))
                            .foregroundColor(Color(white: 0.8))
                        }
                    } else {
                        Button("orders_cancel".localized) {
                            confirmingCancel = order.id
                        }
                        .font(.msa(13))
                        .foregroundColor(Color(red: 1, green: 0.62, blue: 0.6))
                    }
                }
            }
        }
        .shopCard()
    }

    private func statusBadge(_ order: APIOrder) -> some View {
        let value = order.status?.value ?? "pending"

        let color: Color = {
            switch value {
            case "completed": return Color(red: 0.48, green: 0.83, blue: 0.56)
            case "ready", "confirmed": return Color("MainColor")
            case "cancelled", "expired": return Color(red: 1, green: 0.62, blue: 0.6)
            default: return Color(white: 0.8)
            }
        }()

        return Text(order.status?.text ?? "")
            .font(.msa(11, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Capsule().fill(color.opacity(0.15)))
    }

    private func load() async {
        isLoading = orders.isEmpty
        failed = false

        do {
            orders = try await ShopAPI.orders()
        } catch {
            failed = orders.isEmpty
        }

        isLoading = false
    }

    private func cancel(_ id: Int) async {
        do {
            _ = try await ShopAPI.cancelOrder(id: id)
            await load()
        } catch let error as ShopAPIError {
            message = error.displayMessage
            showMessage = true
        } catch {
            message = "حصل خطأ، جرّب تاني"
            showMessage = true
        }
    }
}
