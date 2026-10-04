import Foundation
import WidgetKit

struct TodayExpenseData {
    let amount: Double
    let slipCount: Int
    let lastUpdated: Date
    let dateString: String
}

final class SlipWidgetDataManager {
    static let shared = SlipWidgetDataManager()
    
    static let appGroupID = "group.com.markcnw.SlipSense"
    private let userDefaults = UserDefaults(suiteName: appGroupID)
    
    private let amountKey = "widget_today_expense_amount"
    private let countKey = "widget_today_expense_count"
    private let dateKey = "widget_today_expense_date"
    
    private init() {}
    
    func saveTodayExpense(amount: Double, slipCount: Int) {
        guard let defaults = userDefaults else { return }
        defaults.set(amount, forKey: amountKey)
        defaults.set(slipCount, forKey: countKey)
        defaults.set(Date(), forKey: dateKey)
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func updateTodayExpense(from slips: [SlipRecord]) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let todaySlips = slips.filter { $0.scanDate >= startOfDay && !$0.isSelfTransfer }
        let total = todaySlips.reduce(0) { $0 + $1.amount }
        saveTodayExpense(amount: total, slipCount: todaySlips.count)
    }
    
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
