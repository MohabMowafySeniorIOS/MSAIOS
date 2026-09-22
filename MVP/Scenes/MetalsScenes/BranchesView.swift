//
//  BranchesView.swift
//  MSA
//
//  فروعنا — قايمة مرتّبة بالأقرب + تفاصيل الفرع بخريطة.
//  نفس الشاشات في أندرويد (BranchesScreen.kt).
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - الأفعال

/**
 الاتجاهات، الاتصال، الواتساب.

 كلها بتفتح تطبيقات خارجية، وكلها بتتأكد إن الرابط ينفتح قبل ما تحاول —
 `UIApplication.open` بيفشل بصمت لو مفيش تطبيق يتعامل مع الـ scheme،
 والمستخدم مكنش هيفهم ليه الزرار مش بيعمل حاجة.
 */
enum BranchActions {

    @MainActor
    static func openDirections(_ branch: APIBranch) {
        // Apple Maps هي الافتراضي على iOS. MKMapItem بيفتحها بالاتجاهات
        // جاهزة، وأوضح للمستخدم من رابط ويب لجوجل.
        if let coordinate = branch.coordinate {
            let item = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            item.name = branch.name
            item.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])

            return
        }

        // مفيش إحداثيات — نجرّب رابط الاتجاهات اللي السيرفر بناه
        if let raw = branch.directions_url, let url = URL(string: raw) {
            UIApplication.shared.open(url)
        }
    }

    @MainActor
    static func call(_ phone: String) {
        let digits = phone.filter { $0.isNumber || $0 == "+" }

        guard let url = URL(string: "tel://\(digits)"),
              UIApplication.shared.canOpenURL(url) else { return }

        UIApplication.shared.open(url)
    }

    @MainActor
    static func whatsapp(_ number: String) {
        // wa.me بيرفض أي رموز غير الأرقام
        let digits = number.filter { $0.isNumber }

        guard !digits.isEmpty else { return }

        // سكيم واتساب الأول (بيفتح التطبيق مباشرة)، وبعدين wa.me اللي
        // بيقع على المتصفح لو واتساب مش متثبّت
        if let appURL = URL(string: "whatsapp://send?phone=\(digits)"),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)

            return
        }

        if let webURL = URL(string: "https://wa.me/\(digits)") {
            UIApplication.shared.open(webURL)
        }
    }
}

// MARK: - قائمة الفروع

/**
 فروعنا.

 الشاشة بتطلب إذن الموقع لما تتفتح — هنا، مش عند فتح التطبيق: الطلب في
 سياقه («عايز أشوف أقرب فرع») نسبة قبوله أعلى بكتير.

 ولو المستخدم رفض، الشاشة **مبتفضاش**: بتعرض كل الفروع بترتيب اللوحة مع
 سطر بيوضّح إن الترتيب مش بالأقرب وزرار للتفعيل.
 */
struct BranchesView: View {

    @StateObject private var store = BranchStore.shared
    @StateObject private var location = UserLocationProvider()

    var onBack: (() -> Void)?
    var onOpenBranch: ((Int) -> Void)?

    var body: some View {
        VStack(spacing: 0) {

            headerView(title: "branches_title".localized, isBackShow: true) {
                onBack?()
            }

            if store.isLoading {
                Spacer()
                ProgressView().tint(Color("MainColor"))
                Spacer()
            } else if store.failed {
                Spacer()
                VStack(spacing: 12) {
                    Text("branches_load_failed".localized)
                        .font(.msa(15))
                        .foregroundColor(.white)

                    Button("retry".localized) {
                        Task { await reload(force: true) }
                    }
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
            await reload()

            // أول ما نعرف إن الإذن لسه ما اتطلبش، نطلبه مرة واحدة
            if location.access == .notDetermined {
                await requestLocation()
            }
        }
    }

    private func reload(force: Bool = false) async {
        location.refreshAccess()

        // بنجيب الموقع بس لو الإذن ممنوح — غير كده `current()` هتستنى
        // المهلة كاملة على الفاضي
        let coordinate = location.access == .granted ? await location.current() : nil

        await store.load(coordinate: coordinate, force: force)
    }

    private func requestLocation() async {
        location.requestPermission()

        // بننتظر رد النافذة. الـ delegate بيحدّث `access`، فبنراقبه بدل
        // ما نفترض مدة ثابتة.
        for _ in 0..<40 {
            try? await Task.sleep(nanoseconds: 250_000_000)

            if location.access != .notDetermined { break }
        }

        if location.access == .granted {
            // لازم force: مفتاح الكاش كان "no-location"
            await reload(force: true)
        }
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: 10) {

                sortNote

                if store.branches.isEmpty {
                    Text("branches_empty".localized)
                        .font(.msa(14))
                        .foregroundColor(Color(white: 0.78))
                        .padding(.vertical, 40)
                } else {
                    ForEach(store.branches) { branch in
                        Button {
                            onOpenBranch?(branch.id)
                        } label: {
                            BranchCard(branch: branch)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer(minLength: 90)
            }
            .padding(.horizontal, 16)
        }
        .refreshable { await reload(force: true) }
    }

    @ViewBuilder
    private var sortNote: some View {
        if store.sortedByDistance {
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color("MainColor"))

                Text("branches_sorted_by_distance".localized)
                    .font(.msa(12))
                    .foregroundColor(Color(white: 0.78))

                Spacer()
            }
            .padding(.vertical, 4)
        } else {
            VStack(alignment: .leading, spacing: 10) {
                // رسالتين مختلفتين: «الإذن مرفوض» غير «خدمة الموقع
                // مقفولة» — الحل مختلف في كل حالة والمستخدم لازم يعرف
                Text(location.access == .servicesOff
                     ? "branches_location_off".localized
                     : "branches_location_hint".localized)
                    .font(.msa(13))
                    .foregroundColor(.white)

                if location.access == .notDetermined {
                    Button("branches_enable_location".localized) {
                        Task { await requestLocation() }
                    }
                    .font(.msa(13, weight: .bold))
                    .foregroundColor(Color("MainColor"))
                } else if location.access == .denied {
                    // الإذن مرفوض خلاص — نافذة النظام مش هتظهر تاني،
                    // فالطريق الوحيد هو إعدادات التطبيق
                    Button("branches_open_settings".localized) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.msa(13, weight: .bold))
                    .foregroundColor(Color("MainColor"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.black.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color("MainColor").opacity(0.4), lineWidth: 1)
            )
        }
    }
}

private struct BranchCard: View {

    let branch: APIBranch

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(spacing: 12) {
                if let raw = branch.image_url, let url = URL(string: raw) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.white.opacity(0.06)
                    }
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(branch.name)
                        .font(.msa(16, weight: .bold))
                        .foregroundColor(.white)

                    if let city = branch.city {
                        Text(city)
                            .font(.msa(12))
                            .foregroundColor(Color(white: 0.78))
                    }
                }

                Spacer()

                // المسافة بتظهر بس لما الترتيب بالأقرب شغال
                if let distance = MSAFormat.distance(branch.distance_km) {
                    Text(distance)
                        .font(.msa(13, weight: .bold))
                        .foregroundColor(Color("MainColor"))
                }
            }

            if let address = branch.address {
                Text(address)
                    .font(.msa(13))
                    .foregroundColor(Color(white: 0.78))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let hours = branch.workingHours {
                Text(hours)
                    .font(.msa(12))
                    .foregroundColor(Color(white: 0.6))
            }

            HStack(spacing: 8) {
                if branch.hasLocation {
                    BranchQuickAction(
                        icon: "arrow.triangle.turn.up.right.diamond.fill",
                        title: "branch_directions".localized
                    ) {
                        BranchActions.openDirections(branch)
                    }
                }

                if let phone = branch.phone, !phone.isEmpty {
                    BranchQuickAction(icon: "phone.fill", title: "branch_call".localized) {
                        BranchActions.call(phone)
                    }
                }

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainColor").opacity(0.45), lineWidth: 1)
        )
    }
}

private struct BranchQuickAction: View {

    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 12))
                Text(title).font(.msa(12, weight: .medium))
            }
            .foregroundColor(Color("MainColor"))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color("MainColor").opacity(0.15))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color("MainColor").opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - تفاصيل الفرع

struct BranchDetailsView: View {

    let branchId: Int
    var onBack: (() -> Void)?

    @StateObject private var store = BranchStore.shared

    private var branch: APIBranch? { store.branch(id: branchId) }

    var body: some View {
        VStack(spacing: 0) {

            headerView(title: "branch_details_title".localized, isBackShow: true) {
                onBack?()
            }

            if let branch {
                details(branch)
            } else {
                Spacer()
                ProgressView().tint(Color("MainColor"))
                Spacer()
            }
        }
        .background(BGSwiftUIView())
    }

    private func details(_ branch: APIBranch) -> some View {
        ScrollView {
            VStack(spacing: 12) {

                if let raw = branch.image_url, let url = URL(string: raw) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.white.opacity(0.06)
                    }
                    .frame(height: 190)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                MSAPanel {
                    Text(branch.name)
                        .font(.msa(20, weight: .bold))
                        .foregroundColor(.white)

                    if let address = branch.address {
                        iconLine("mappin.and.ellipse", address)
                    }

                    if let hours = branch.workingHours {
                        iconLine("clock", hours)
                    }

                    if let distance = MSAFormat.distance(branch.distance_km) {
                        Text(String(format: "branch_distance_from_you".localized, distance))
                            .font(.msa(13, weight: .semibold))
                            .foregroundColor(Color("MainColor"))
                    }
                }

                if let coordinate = branch.coordinate {
                    BranchMapView(coordinate: coordinate, title: branch.name)

                    Button {
                        BranchActions.openDirections(branch)
                    } label: {
                        Text("branch_directions".localized)
                            .font(.msa(16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color("MainColor"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                if (branch.phone?.isEmpty == false) || (branch.whatsapp?.isEmpty == false) {
                    MSAPanel {
                        Text("branch_contact".localized)
                            .font(.msa(14, weight: .bold))
                            .foregroundColor(Color("MainColor"))

                        if let phone = branch.phone, !phone.isEmpty {
                            contactRow("phone.fill", "branch_call".localized, phone) {
                                BranchActions.call(phone)
                            }
                        }

                        if let whatsapp = branch.whatsapp, !whatsapp.isEmpty {
                            contactRow("message.fill", "branch_whatsapp".localized, whatsapp) {
                                BranchActions.whatsapp(whatsapp)
                            }
                        }
                    }
                }

                Spacer(minLength: 60)
            }
            .padding(.horizontal, 16)
        }
    }

    private func iconLine(_ icon: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(Color(white: 0.6))

            Text(text)
                .font(.msa(13))
                .foregroundColor(Color(white: 0.78))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }

    private func contactRow(
        _ icon: String,
        _ title: String,
        _ value: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(Color("MainColor"))

                Text(title)
                    .font(.msa(14, weight: .medium))
                    .foregroundColor(.white)

                Spacer()

                // الرقم دايماً LTR حتى في الواجهة العربية — من غير كده
                // رقم زي "+20 100 123 4567" بيتعرض بترتيب مقلوب
                // والمستخدم بينسخه غلط.
                Text(value)
                    .font(.msa(13))
                    .foregroundColor(Color(white: 0.78))
                    .environment(\.layoutDirection, .leftToRight)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color("MainColor").opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("MainColor").opacity(0.4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.top, 6)
    }
}

/**
 خريطة صغيرة بعلامة على الفرع.

 التفاعل مقفول عن قصد (`allowsHitTesting(false)`): الخريطة جوّه ScrollView
 رأسي، ولو سبناها تستقبل السحب كان المستخدم اللي بيحاول يمرّر الشاشة
 هيحرّك الخريطة بالغلط. اللي عايز يتحرك بيدوس «الاتجاهات».

 MapKit جزء من النظام — مفيش مفتاح API ولا تكلفة، بعكس أندرويد اللي
 محتاج مفتاح Google Maps.
 */
private struct BranchMapView: View {

    let coordinate: CLLocationCoordinate2D
    let title: String

    /// ~١.٥ كم عرضاً — مستوى الحي، الشارع والمعالم حواليه باينة
    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
        )
    }

    var body: some View {
        // المشروع مستهدف iOS 17، فالـ API الجديد متاح — بس سايبين
        // البديل القديم عشان لو الـ deployment target اتنزّل بعدين.
        Group {
            if #available(iOS 17.0, *) {
                Map(initialPosition: .region(region)) {
                    Marker(title, coordinate: coordinate)
                }
            } else {
                Map(
                    coordinateRegion: .constant(region),
                    interactionModes: [],
                    annotationItems: [BranchPin(coordinate: coordinate)]
                ) { pin in
                    MapMarker(coordinate: pin.coordinate, tint: .red)
                }
            }
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainColor").opacity(0.45), lineWidth: 1)
        )
        .allowsHitTesting(false)
    }

    private struct BranchPin: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }
}
