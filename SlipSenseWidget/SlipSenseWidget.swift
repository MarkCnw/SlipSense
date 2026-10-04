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
struct TodayExpenseData {
    let amount: Double
    let slipCount: Int
    let lastUpdated: Date
    let dateString: String
}

// MARK: - Data Manager (Shared UserDefaults Reader)
final class SlipWidgetDataManager {
    static let shared = SlipWidgetDataManager()
    static let appGroupID = "group.com.markcnw.SlipSense"
    private let userDefaults = UserDefaults(suiteName: appGroupID)
    
    private let amountKey = "widget_today_expense_amount"
    private let countKey = "widget_today_expense_count"
    private let dateKey = "widget_today_expense_date"
    
    private init() {}
    
    func getTodayExpense() -> TodayExpenseData {
        guard let defaults = userDefaults else {
            return TodayExpenseData(amount: 0, slipCount: 0, lastUpdated: Date(), dateString: Self.formatDate(Date()))
        }
        
        let savedDate = defaults.object(forKey: dateKey) as? Date ?? Date()
        let calendar = Calendar.current
        
        // ถ้าข้อมูลที่บันทึกไม่ใช่วันนี้ แปลว่าขึ้นวันใหม่แล้ว ให้แสดง 0 บาท
        if !calendar.isDateInToday(savedDate) {
            return TodayExpenseData(
                amount: 0,
                slipCount: 0,
                lastUpdated: Date(),
                dateString: Self.formatDate(Date())
            )
        }
        
        let amount = defaults.double(forKey: amountKey)
        let count = defaults.integer(forKey: countKey)
        
        return TodayExpenseData(
            amount: amount,
            slipCount: count,
            lastUpdated: savedDate,
            dateString: Self.formatDate(savedDate)
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
                amount: 1450.00,
                slipCount: 3,
                lastUpdated: Date(),
                dateString: "2 ต.ค."
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
                dateString: startOfTomorrow.formatted(.dateTime.day().month(.abbreviated).locale(Locale(identifier: "th_TH")))
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

// MARK: - Widget Views

struct SlipSenseWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView
        case .systemMedium:
            mediumWidgetView
        default:
            smallWidgetView
        }
    }
    
    // MARK: - 🏆 Small Widget (1x1) - Ultra-Clean Balanced Design
    private var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Row: Card Icon + Sync Button
            HStack(alignment: .center) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7.5, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.25, green: 0.48, blue: 0.98),
                                    Color(red: 0.45, green: 0.32, blue: 0.96)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 25, height: 25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7.5, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        )
                        .shadow(color: Color.blue.opacity(0.25), radius: 3, x: 0, y: 1.5)
                    
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Button(intent: SyncIntent()) {
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 9.5, weight: .semibold))
                            .foregroundStyle(.blue)
                        
                        Text("ซิงค์")
                            .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3.5)
                    .background(
                        Capsule()
                            .fill(Color(.secondarySystemFill).opacity(0.7))
                            .overlay(
                                Capsule()
                                    .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
            
            Spacer(minLength: 8)
            
            Text("ยอดใช้จ่ายวันนี้")
                .font(.system(size: 11.5, weight: .medium))
                .foregroundStyle(.secondary)
            
            Spacer(minLength: 4)
            
            // Amount Display
            let split = entry.expenseData.amount.splitAmount
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(split.integer)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.62)
                    .lineLimit(1)
                
                Text(split.fraction)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                
                Text("บาท")
                    .font(.system(size: 9.5, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color(.tertiarySystemFill), in: Capsule())
                    .padding(.leading, 3)
            }
            
            Spacer(minLength: 10)
            
            // Footer: Slip Count & Sync Time
            HStack {
                Text(entry.expenseData.slipCount > 0 ? "\(entry.expenseData.slipCount) สลิป" : "ไม่มีสลิป")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(entry.expenseData.lastUpdated.formatted(.dateTime.hour().minute().locale(Locale(identifier: "th_TH"))))
                    .font(.system(size: 9.5, weight: .regular, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4.5)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(.secondarySystemFill).opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.primary.opacity(0.04), lineWidth: 0.5)
                    )
            )
        }
    }
    
    // MARK: - 👑 Medium Widget (2x1) - ShopeePay Bento Dashboard
    private var mediumWidgetView: some View {
        HStack(spacing: 12) {
            // 👈 ฝั่งซ้าย: ข้อมูลยอดเงินหลัก (Hero Spending)
            VStack(alignment: .leading, spacing: 0) {
                // Section Title (Clean & Minimal)
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                    
                    Text("ยอดใช้จ่ายวันนี้")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                
                Spacer(minLength: 8)
                
                // Big Crisp Amount
                let split = entry.expenseData.amount.splitAmount
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(split.integer)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.62)
                        .lineLimit(1)
                    
                    Text(split.fraction)
                        .font(.system(size: 19, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                    
                    Text("บาท")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 5.5)
                        .padding(.vertical, 2.5)
                        .background(
                            Capsule()
                                .fill(Color(.tertiarySystemFill).opacity(0.8))
                        )
                        .padding(.leading, 2)
                }
                
                Spacer(minLength: 8)
                
                // Status Footer: Slip Count & Sync Time
                HStack(spacing: 5) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundStyle(entry.expenseData.slipCount > 0 ? Color.blue : Color.secondary)
                    
                    Text(entry.expenseData.slipCount > 0 ? "\(entry.expenseData.slipCount) สลิป" : "ไม่มีสลิป")
                        .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .font(.system(size: 8))
                        .foregroundStyle(.tertiary)
                    
                    Text(entry.expenseData.lastUpdated.formatted(.dateTime.hour().minute().locale(Locale(identifier: "th_TH"))))
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4.5)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(.secondarySystemFill).opacity(0.45))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.primary.opacity(0.04), lineWidth: 0.5)
                        )
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // 👉 ฝั่งขวา: 2x2 Bento Action Tiles (สไตล์ ShopeePay คลีนเรียบหรู)
            VStack(spacing: 7) {
                HStack(spacing: 7) {
                    // ปุ่ม 1: ซิงค์ข้อมูล (Interactive Button ประมวลผลเบื้องหลังทันที)
                    Button(intent: SyncIntent()) {
                        bentoTileContent(
                            icon: "arrow.triangle.2.circlepath",
                            title: "ซิงค์",
                            accentColor: Color.blue
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // ปุ่ม 2: สแกนสลิป
                    Link(destination: URL(string: "slipsense://scan")!) {
                        bentoTileContent(
                            icon: "viewfinder",
                            title: "สแกน",
                            accentColor: Color(red: 0.58, green: 0.38, blue: 0.98)
                        )
                    }
                }
                
                HStack(spacing: 7) {
                    // ปุ่ม 3: รายการประวัติ
                    Link(destination: URL(string: "slipsense://history")!) {
                        bentoTileContent(
                            icon: "list.bullet.rectangle.fill",
                            title: "ประวัติ",
                            accentColor: Color(red: 0.28, green: 0.52, blue: 0.96)
                        )
                    }
                    
                    // ปุ่ม 4: แดชบอร์ดภาพรวม
                    Link(destination: URL(string: "slipsense://dashboard")!) {
                        bentoTileContent(
                            icon: "chart.pie.fill",
                            title: "ภาพรวม",
                            accentColor: Color(red: 0.95, green: 0.52, blue: 0.22)
                        )
                    }
                }
            }
            .frame(width: 136)
        }
    }
    
    // MARK: - Bento Tile Component (ShopeePay Style)
    @ViewBuilder
    private func bentoTileContent(
        icon: String,
        title: String,
        accentColor: Color
    ) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 15.5, weight: .semibold))
                .foregroundStyle(accentColor)
                .frame(height: 18)
            
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemFill).opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 0.6)
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
                    // Deep Clean Luxury Surface
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.secondarySystemBackground).opacity(0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
        .configurationDisplayName("ยอดใช้จ่ายวันนี้")
        .description("แสดงยอดรวมการใช้จ่ายของวันนี้จากสลิปธนาคาร อัปเดตอัตโนมัติ")
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
            amount: 20.00,
            slipCount: 1,
            lastUpdated: .now,
            dateString: "2 ต.ค."
        )
    )
}

#Preview(as: .systemMedium) {
    SlipSenseWidget()
} timeline: {
    ExpenseEntry(
        date: .now,
        expenseData: TodayExpenseData(
            amount: 20.00,
            slipCount: 1,
            lastUpdated: .now,
            dateString: "2 ต.ค."
        )
    )
}
