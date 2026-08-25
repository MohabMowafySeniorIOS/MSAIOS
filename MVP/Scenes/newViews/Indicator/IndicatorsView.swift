//
//  IndicatorsView.swift
//  MSA
//
//  Created by Mohab Mowafy on 04/06/2026.
//

import SwiftUI

// MARK: - Indicators Screen (شاشة المؤشرات)

struct IndicatorsView: View {
    @StateObject private var manager = PriceDataManager.shared
    @State private var selectedMetal: MetalType2 = .gold
    @State private var selectedPeriod: TimePeriod = .h24
    @State private var showPeriodPicker = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            BGSwiftUIView()

            VStack(spacing: 0) {
                // ── Header ───────────────────────────────────────────────
                headerView(title: "المؤشرات", isBackShow: true,onDismiss: {
                    dismiss()
                })
                

                // ── Content ──────────────────────────────────────────────
                ScrollView {
                    VStack(spacing: 14) {

                        // Hint banner
                        HintBanner()

                        // Metal segmented picker
                        MetalSegmentedPicker(selected: $selectedMetal)
                            .onChange(of: selectedMetal) { _ in reload() }

                        // Period dropdown
                        PeriodDropdown(
                            selected: $selectedPeriod,
                            isExpanded: $showPeriodPicker
                        )
                        .onChange(of: selectedPeriod) { _ in
                            showPeriodPicker = false
                            reload()
                        }

                        // Charts
                        if manager.isLoading {
                            LoadingView()
                        } else {
                            let charts = selectedMetal == .gold
                                ? manager.goldCharts
                                : manager.silverCharts

                            ForEach(charts.indices, id: \.self) { i in
                                GoldLineChart(dataSet: charts[i])
                                    .padding(.horizontal, 2)
                            }
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .task { reload() }
    }

    private func reload() {
        Task { await manager.load(metal: selectedMetal, period: selectedPeriod) }
    }
}

// MARK: - App Header

struct AppHeaderView: View {
    let title: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "B8924A"), Color(hex: "E8C870"), Color(hex: "B8924A")],
                startPoint: .leading, endPoint: .trailing
            )

            HStack {
                HStack(spacing: 10) {
                    CircleIconButton(systemName: "info.circle")
                    CircleIconButton(systemName: "person.circle")
                }

                Spacer()

                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                // Logo
                ZStack {
                    Circle().fill(Color.black).frame(width: 38, height: 38)
                    Text("D")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .italic()
                        .foregroundColor(Color(hex: "C9A84C"))
                }
                .padding(.leading, 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(height: 64)
        .environment(\.layoutDirection, .leftToRight)
    }
}

struct CircleIconButton: View {
    let systemName: String
    var body: some View {
        Button(action: {}) {
            Image(systemName: systemName)
                .font(.system(size: 20))
                .foregroundColor(.black)
                .frame(width: 36, height: 36)
                .background(Color.black.opacity(0.15))
                .clipShape(Circle())
        }
    }
}

// MARK: - Hint Banner

struct HintBanner: View {
    var body: some View {
        Text("يمكنك الضغط لمدة ثانيتين على الرسم البياني لعرض القيمة.")
            .font(.system(size: 13))
            .foregroundColor(Color(hex: "CCCCCC"))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "2A2A2A"))
            .cornerRadius(10)
    }
}

// MARK: - Metal Segmented Picker

struct MetalSegmentedPicker: View {
    @Binding var selected: MetalType2

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MetalType2.allCases, id: \.self) { metal in
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selected = metal } }) {
                    Text(metal.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(selected == metal ? .black : Color(hex: "C9A84C"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selected == metal
                                ? RoundedRectangle(cornerRadius: 22)
                                    .fill(Color(hex: "E8C870"))
                                : RoundedRectangle(cornerRadius: 22)
                                    .fill(Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(Color(hex: "1E1E1E"))
        .overlay(RoundedRectangle(cornerRadius: 26).stroke(Color(hex: "C9A84C").opacity(0.5), lineWidth: 1))
        .cornerRadius(26)
    }
}

// MARK: - Period Dropdown

struct PeriodDropdown: View {
    @Binding var selected: TimePeriod
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Selected row (trigger)
            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "C9A84C"))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))

                    Spacer()

                    Text(selected.rawValue)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(hex: "2A2A2A"))
                .cornerRadius(isExpanded ? 0 : 10)
            }
            .cornerRadius(isExpanded ? 0 : 10)

            // Expanded list
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Button(action: { selected = period }) {
                            HStack {
                                Spacer()
                                Text(period.rawValue)
                                    .font(.system(size: 15, weight: period == selected ? .semibold : .regular))
                                    .foregroundColor(period == selected ? Color(hex: "C9A84C") : .white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                period == selected
                                    ? Color(hex: "3A3A3A")
                                    : Color(hex: "252525")
                            )
                        }

                        if period != TimePeriod.allCases.last {
                            Divider().background(Color(hex: "3A3A3A"))
                        }
                    }
                }
                .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "C9A84C").opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(10)
        .zIndex(10)
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "C9A84C")))
                .scaleEffect(1.4)
            Text("جاري تحميل البيانات...")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "888888"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Corner Radius Helper

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview {
    IndicatorsView()
}
