//
//  SlipSenseWidget.swift
//  SlipSenseWidget
//
//  Created by MarkCnw on 10/2/26.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Models

struct WidgetCategoryItem: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let amount: Double
    let colorHex: String
}

struct TodayExpenseData {
    let amount: Double
    let slipCount: Int
    let lastUpdated: Date
    let dateString: String
    let categories: [WidgetCategoryItem]
}

// MARK: - Color Extension for Hex Codes

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 142, 142, 147)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Data Manager (Shared UserDefaults Reader)

final class SlipWidgetDataManager {
    static let shared = SlipWidgetDataManager()
    static let appGroupID = "group.com.markcnw.SlipSense"
    private let userDefaults = UserDefaults(suiteName: appGroupID)
    
    private let amountKey = "widget_today_expense_amount"
    private let countKey = "widget_today_expense_count"
    private let dateKey = "widget_today_expense_date"
    private let categoriesKey = "widget_today_categories"
    
    private init() {}
    
    func getTodayExpense() -> TodayExpenseData {
        guard let defaults = userDefaults else {
            return TodayExpenseData(amount: 0, slipCount: 0, lastUpdated: Date(), dateString: Self.formatDate(Date()), categories: [])
        }
        
        let savedDate = defaults.object(forKey: dateKey) as? Date ?? Date()
        let calendar = Calendar.current
        
        // ถ้าข้อมูลที่บันทึกไม่ใช่วันนี้ แปลว่าขึ้นวันใหม่แล้ว ให้แสดง 0 บาท
        if !calendar.isDateInToday(savedDate) {
            return TodayExpenseData(
                amount: 0,
                slipCount: 0,
                lastUpdated: Date(),
                dateString: Self.formatDate(Date()),
                categories: []
            )
        }
        
        let amount = defaults.double(forKey: amountKey)
        let count = defaults.integer(forKey: countKey)
        
        var categories: [WidgetCategoryItem] = []
        if let data = defaults.data(forKey: categoriesKey),
           let decoded = try? JSONDecoder().decode([WidgetCategoryItem].self, from: data) {
            categories = decoded
        }
        
        return TodayExpenseData(
            amount: amount,
            slipCount: count,
            lastUpdated: savedDate,
            dateString: Self.formatDate(savedDate),
            categories: categories
        )
    }
    
    private static func formatDate(_ date: Date) -> String {
        date.formatted(.dateTime.day().month(.abbreviated).locale(Locale(identifier: "th_TH")))
    }
}

// MARK: - App Intent for Widget Interaction

struct SyncIntent: AudioPlaybackIntent {
    static var title: LocalizedStringResource = "ซิงค์ข้อมูลสลิป"
    static var description = IntentDescription("รีโหลดข้อมูลวิดเจ็ตยอดใช้จ่ายวันนี้")
    
    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

// MARK: - Amount Formatter Helper

extension Double {
    var splitAmount: (integer: String, fraction: String) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let formatted = formatter.string(from: NSNumber(value: self)) ?? "0.00"
        let parts = formatted.split(separator: ".")
        if parts.count == 2 {
            return (String(parts[0]), "." + String(parts[1]))
        }
        return (formatted, ".00")
    }
}

// MARK: - Timeline Entry & Provider

struct ExpenseEntry: TimelineEntry {
    let date: Date
    let expenseData: TodayExpenseData
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ExpenseEntry {
        ExpenseEntry(
            date: Date(),
            expenseData: TodayExpenseData(
                amount: 322.00,
                slipCount: 4,
                lastUpdated: Date(),
                dateString: "7 ต.ค.",
                categories: [
                    WidgetCategoryItem(name: "กสิกรไทย", amount: 150, colorHex: "#00A950"),
                    WidgetCategoryItem(name: "ไทยพาณิชย์", amount: 80, colorHex: "#4E2A84"),
                    WidgetCategoryItem(name: "กรุงเทพ", amount: 50, colorHex: "#1E3A8A"),
                    WidgetCategoryItem(name: "กรุงศรี", amount: 42, colorHex: "#FEC400")
                ]
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ExpenseEntry) -> Void) {
        let data = SlipWidgetDataManager.shared.getTodayExpense()
        let entry = ExpenseEntry(date: Date(), expenseData: data)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ExpenseEntry>) -> Void) {
        let currentData = SlipWidgetDataManager.shared.getTodayExpense()
        let currentEntry = ExpenseEntry(date: Date(), expenseData: currentData)
        
        var entries: [ExpenseEntry] = [currentEntry]
        
        let calendar = Calendar.current
        // สร้าง Entry สำหรับเที่ยงคืนวันนี้ (เริ่มวันใหม่) เพื่อรีเซ็ตยอดเป็น 0.00 บาท อัตโนมัติ
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) {
            let startOfTomorrow = calendar.startOfDay(for: tomorrow)
            let tomorrowData = TodayExpenseData(
                amount: 0,
                slipCount: 0,
                lastUpdated: startOfTomorrow,
                dateString: startOfTomorrow.formatted(.dateTime.day().month(.abbreviated).locale(Locale(identifier: "th_TH"))),
                categories: []
            )
            let midnightEntry = ExpenseEntry(date: startOfTomorrow, expenseData: tomorrowData)
            entries.append(midnightEntry)
        }
        
        // ให้ Widget เช็ค Timeline ใหม่ทุก 1 ชั่วโมง หรือเมื่อมีคำสั่ง reload
        let nextUpdate = calendar.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Chart Components

/// กราฟแท่งแบ่งสัดส่วนแนวตั้งตามสีธนาคาร (Vertical Stacked Bar)
struct VerticalStackedBar: View {
    let categories: [WidgetCategoryItem]
    let totalAmount: Double
    
    var body: some View {
        GeometryReader { geo in
            let totalHeight = geo.size.height
            if totalAmount > 0 && !categories.isEmpty {
                VStack(spacing: 1.5) {
                    ForEach(categories) { cat in
                        let segmentHeight = max((cat.amount / totalAmount) * (totalHeight - CGFloat(max(0, categories.count - 1)) * 1.5), 3.0)
                        Rectangle()
                            .fill(Color(hex: cat.colorHex))
                            .frame(height: segmentHeight)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 4.5, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 4.5, style: .continuous)
                    .fill(Color.white.opacity(0.10))
            }
        }
    }
}

/// กราฟแท่งแบ่งสัดส่วนแนวนอนตามสีธนาคาร (Horizontal Stacked Bar)
struct HorizontalStackedBar: View {
    let categories: [WidgetCategoryItem]
    let totalAmount: Double
    
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            if totalAmount > 0 && !categories.isEmpty {
                HStack(spacing: 1.5) {
                    ForEach(categories) { cat in
                        let segmentWidth = max((cat.amount / totalAmount) * (totalWidth - CGFloat(max(0, categories.count - 1)) * 1.5), 3.0)
                        Rectangle()
                            .fill(Color(hex: cat.colorHex))
                            .frame(width: segmentWidth)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 3.5, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                    .fill(Color.white.opacity(0.10))
            }
        }
        .frame(height: 7.5)
    }
}

// MARK: - Widget Views

struct SlipSenseWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallWidgetView
            case .systemMedium:
                mediumWidgetView
            default:
                smallWidgetView
            }
        }
        .environment(\.colorScheme, .dark) // บังคับโทนดำ premium คมชัด อ่านง่าย
    }
    
    // MARK: - 🏆 Small Widget (1x1) - Sleek Charcoal Black
    private var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Row
            HStack(alignment: .center) {
                Text("ยอดใช้จ่ายวันนี้")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.70))
                    .lineLimit(1)
                
                Spacer()
                
                Button(intent: SyncIntent()) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(red: 1.0, green: 0.80, blue: 0.20)) // Gold accent
                        .padding(4.5)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }
                .buttonStyle(.plain)
            }
            
            Spacer(minLength: 2)
            
            // Big Hero Amount
            let split = entry.expenseData.amount.splitAmount
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(split.integer)
                    .font(.system(size: 27, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color.white)
                    .minimumScaleFactor(0.65)
                    .lineLimit(1)
                
                Text("บาท")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.55))
            }
            
            Spacer(minLength: 6)
            
            // Bottom Area: Vertical Stacked Bar + Bank Legend
            HStack(alignment: .top, spacing: 8.5) {
                VerticalStackedBar(
                    categories: entry.expenseData.categories,
                    totalAmount: entry.expenseData.amount
                )
                .frame(width: 17, height: 64)
                
                if entry.expenseData.categories.isEmpty || entry.expenseData.amount == 0 {
                    VStack(alignment: .leading, spacing: 2) {
                        Spacer()
                        Text("ยังไม่มีรายการวันนี้")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.65))
                        Text("แตะเพื่อซิงค์ข้อมูลสลิป")
                            .font(.system(size: 9.5, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.40))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                } else {
                    VStack(alignment: .leading, spacing: 3.5) {
                        ForEach(entry.expenseData.categories.prefix(4)) { item in
                            HStack(spacing: 5) {
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color(hex: item.colorHex))
                                    .frame(width: 7.5, height: 7.5)
                                
                                Text(item.name)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Color.white.opacity(0.80))
                                    .lineLimit(1)
                                
                                Spacer(minLength: 2)
                                
                                Text("\(Int(item.amount.rounded())) บาท")
                                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                                    .monospacedDigit()
                                    .foregroundStyle(Color.white)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    // MARK: - 👑 Medium Widget (2x1) - Sleek Charcoal Black
    private var mediumWidgetView: some View {
        HStack(spacing: 14) {
            // 👈 ฝั่งซ้าย: ข้อมูลสรุปหลัก
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(spacing: 5) {
                    Text("ยอดใช้จ่ายวันนี้")
                        .font(.system(size: 13.5, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.70))
                    
                    Spacer(minLength: 0)
                }
                
                Spacer(minLength: 6)
                
                // Big Amount
                let split = entry.expenseData.amount.splitAmount
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(split.integer)
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color.white)
                        .minimumScaleFactor(0.60)
                        .lineLimit(1)
                    
                    Text(split.fraction)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color.white.opacity(0.50))
                    
                    Text("บาท")
                        .font(.system(size: 12.5, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.55))
                        .padding(.leading, 2)
                }
                
                Spacer(minLength: 8)
                
                // Horizontal Stacked Bar
                HorizontalStackedBar(
                    categories: entry.expenseData.categories,
                    totalAmount: entry.expenseData.amount
                )
                
                Spacer(minLength: 8)
                
                // Footer: เวลาเท่านั้น
                HStack(spacing: 4.5) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.45))
                    
                    Text(entry.expenseData.slipCount > 0 ? "\(entry.expenseData.slipCount) สลิป" : "ไม่มีสลิป")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.60))
                    
                    Text("•")
                        .font(.system(size: 7))
                        .foregroundStyle(Color.white.opacity(0.25))
                    
                    Text(entry.expenseData.lastUpdated.formatted(.dateTime.hour().minute().locale(Locale(identifier: "th_TH"))))
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.45))
                }
                .padding(.horizontal, 7.5)
                .padding(.vertical, 3.5)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // 👉 ฝั่งขวา: รายการธนาคาร + ปุ่มแอ็กชัน
            VStack(alignment: .leading, spacing: 7) {
                // Bank Legend Items
                if entry.expenseData.categories.isEmpty || entry.expenseData.amount == 0 {
                    VStack(alignment: .leading, spacing: 3) {
                        Spacer()
                        Text("ยังไม่มีรายการวันนี้")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.65))
                        Text("แตะปุ่มซิงค์ด้านล่างเพื่ออัปเดต")
                            .font(.system(size: 9.5, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.40))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                } else {
                    VStack(spacing: 4.5) {
                        ForEach(entry.expenseData.categories.prefix(4)) { item in
                            HStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(hex: item.colorHex))
                                    .frame(width: 8, height: 8)
                                
                                Text(item.name)
                                    .font(.system(size: 11.5, weight: .bold))
                                    .foregroundStyle(Color.white.opacity(0.80))
                                    .lineLimit(1)
                                
                                Spacer(minLength: 4)
                                
                                Text("\(Int(item.amount.rounded())) บาท")
                                    .font(.system(size: 11.5, weight: .heavy, design: .rounded))
                                    .monospacedDigit()
                                    .foregroundStyle(Color.white)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                
                Spacer(minLength: 2)
                
                // Bottom Quick Action Buttons — Frosted Glass Dark
                HStack(spacing: 6) {
                    // ปุ่ม 1: ซิงค์
                    Button(intent: SyncIntent()) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundStyle(Color(red: 1.0, green: 0.80, blue: 0.20)) // Gold accent
                            
                            Text("ซิงค์")
                                .font(.system(size: 11.5, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.90))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 9.5, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 9.5, style: .continuous)
                                .stroke(Color.white.opacity(0.10), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // ปุ่ม 2: ภาพรวม
                    Link(destination: URL(string: "slipsense://dashboard")!) {
                        HStack(spacing: 4) {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundStyle(Color(red: 1.0, green: 0.80, blue: 0.20)) // Gold accent
                            
                            Text("ภาพรวม")
                                .font(.system(size: 11.5, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.90))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 9.5, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 9.5, style: .continuous)
                                .stroke(Color.white.opacity(0.10), lineWidth: 0.5)
                        )
                    }
                }
            }
            .frame(width: 136)
        }
    }
}

// MARK: - Sleek Charcoal Black Widget Background

struct WidgetBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.11, green: 0.11, blue: 0.12),  // #1C1C1E - Charcoal
                Color(red: 0.05, green: 0.05, blue: 0.06)    // #0D0D0F - Near Black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Widget Configuration

struct SlipSenseWidget: Widget {
    let kind: String = "SlipSenseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SlipSenseWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    WidgetBackgroundView()
                }
        }
        .configurationDisplayName("ยอดใช้จ่ายวันนี้")
        .description("แสดงยอดรวมการใช้จ่ายของวันนี้จากสลิปธนาคาร พร้อมกราฟสัดส่วนแยกตามธนาคาร")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    SlipSenseWidget()
} timeline: {
    ExpenseEntry(
        date: .now,
        expenseData: TodayExpenseData(
            amount: 322.00,
            slipCount: 4,
            lastUpdated: .now,
            dateString: "7 ต.ค.",
            categories: [
                WidgetCategoryItem(name: "กสิกรไทย", amount: 150, colorHex: "#00A950"),
                WidgetCategoryItem(name: "ไทยพาณิชย์", amount: 80, colorHex: "#4E2A84"),
                WidgetCategoryItem(name: "กรุงเทพ", amount: 50, colorHex: "#1E3A8A"),
                WidgetCategoryItem(name: "กรุงศรี", amount: 42, colorHex: "#FEC400")
            ]
        )
    )
}

#Preview(as: .systemMedium) {
    SlipSenseWidget()
} timeline: {
    ExpenseEntry(
        date: .now,
        expenseData: TodayExpenseData(
            amount: 322.00,
            slipCount: 4,
            lastUpdated: .now,
            dateString: "7 ต.ค.",
            categories: [
                WidgetCategoryItem(name: "กสิกรไทย", amount: 150, colorHex: "#00A950"),
                WidgetCategoryItem(name: "ไทยพาณิชย์", amount: 80, colorHex: "#4E2A84"),
                WidgetCategoryItem(name: "กรุงเทพ", amount: 50, colorHex: "#1E3A8A"),
                WidgetCategoryItem(name: "กรุงศรี", amount: 42, colorHex: "#FEC400")
            ]
        )
    )
}
