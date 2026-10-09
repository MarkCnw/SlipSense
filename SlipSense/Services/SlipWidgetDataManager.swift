import Foundation
import WidgetKit

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

final class SlipWidgetDataManager {
    static let shared = SlipWidgetDataManager()
    
    static let appGroupID = "group.com.markcnw.SlipSense"
    private let userDefaults = UserDefaults(suiteName: appGroupID)
    
    private let amountKey = "widget_today_expense_amount"
    private let countKey = "widget_today_expense_count"
    private let dateKey = "widget_today_expense_date"
    private let categoriesKey = "widget_today_categories"
    
    private init() {}
    
    func saveTodayExpense(amount: Double, slipCount: Int, categories: [WidgetCategoryItem] = []) {
        guard let defaults = userDefaults else { return }
        defaults.set(amount, forKey: amountKey)
        defaults.set(slipCount, forKey: countKey)
        defaults.set(Date(), forKey: dateKey)
        
        if let encoded = try? JSONEncoder().encode(categories) {
            defaults.set(encoded, forKey: categoriesKey)
        } else {
            defaults.removeObject(forKey: categoriesKey)
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func updateTodayExpense(from slips: [SlipRecord]) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let todaySlips = slips.filter { $0.scanDate >= startOfDay && !$0.isSelfTransfer }
        let total = todaySlips.reduce(0.0) { $0 + $1.amount }
        
        // จัดกลุ่มตามธนาคาร และกำหนดสีตามเอกลักษณ์ของแต่ละธนาคาร
        var bankTotals: [String: (name: String, amount: Double, colorHex: String)] = [:]
        
        for slip in todaySlips {
            let info = Self.resolveBank(from: slip.bankName)
            if var existing = bankTotals[info.name] {
                existing.amount += slip.amount
                bankTotals[info.name] = existing
            } else {
                bankTotals[info.name] = (name: info.name, amount: slip.amount, colorHex: info.colorHex)
            }
        }
        
        let sortedSummaries = bankTotals.values.sorted { $0.amount > $1.amount }
        var categoryList: [WidgetCategoryItem] = []
        
        if sortedSummaries.count <= 4 {
            for item in sortedSummaries {
                categoryList.append(WidgetCategoryItem(name: item.name, amount: item.amount, colorHex: item.colorHex))
            }
        } else {
            for item in sortedSummaries.prefix(3) {
                categoryList.append(WidgetCategoryItem(name: item.name, amount: item.amount, colorHex: item.colorHex))
            }
            let remainingAmount = sortedSummaries.dropFirst(3).reduce(0.0) { $0 + $1.amount }
            categoryList.append(WidgetCategoryItem(name: "อื่นๆ", amount: remainingAmount, colorHex: "#8E8E93"))
        }
        
        saveTodayExpense(amount: total, slipCount: todaySlips.count, categories: categoryList)
    }
    
    static func resolveBank(from raw: String) -> (name: String, colorHex: String) {
        let name = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if name.contains("kbank") || name.contains("กสิกร") || name.contains("kasikorn") || name.contains("kplus") || name.contains("k-plus") {
            return ("กสิกรไทย", "#00A950") // สีเขียว
        }
        if name.contains("scb") || name.contains("ไทยพาณิชย์") || name.contains("ไทยพาณิช") || name.contains("scbeasy") {
            return ("ไทยพาณิชย์", "#4E2A84") // สีม่วง
        }
        if name.contains("bbl") || name.contains("กรุงเทพ") || name.contains("bangkokbank") || name.contains("bualuang") {
            return ("กรุงเทพ", "#1E3A8A") // สีน้ำเงิน
        }
        if name.contains("ktb") || name.contains("กรุงไทย") || name.contains("krungthai") || name.contains("เป๋าตัง") || name.contains("paotang") {
            return ("กรุงไทย", "#00A4E4") // สีฟ้า
        }
        if name.contains("bay") || name.contains("กรุงศรี") || name.contains("krungsri") || name.contains("ayudhya") || name.contains("kma") {
            return ("กรุงศรี", "#FEC400") // สีเหลือง
        }
        if name.contains("ttb") || name.contains("ทหารไทย") || name.contains("ธนชาต") || name.contains("ทีทีบี") || name.contains("tmb") || name.contains("thanachart") || name.contains("ttbtouch") {
            return ("TTB", "#F37021") // สีส้ม
        }
        if name.contains("gsb") || name.contains("ออมสิน") || name.contains("mymo") {
            return ("ออมสิน", "#EB198B") // สีชมพู
        }
        if name.contains("kkp") || name.contains("เกียรตินาคิน") {
            return ("เกียรตินาคิน", "#6E2A8D") // สีม่วง
        }
        if name.contains("baac") || name.contains("ธ.ก.ส") || name.contains("ธกส") || name.contains("เกษตร") {
            return ("ธ.ก.ส.", "#005C2B") // สีเขียวเข้ม
        }
        if name.contains("ghb") || name.contains("ธอส") || name.contains("อาคารสงเคราะห์") {
            return ("ธอส.", "#FF6600") // สีส้ม
        }
        if name.contains("cimb") || name.contains("ซีไอเอ็มบี") {
            return ("CIMB", "#7E1119") // สีแดงเลือดหมู
        }
        if name.contains("uob") || name.contains("ยูโอบี") {
            return ("UOB", "#002D62") // สีน้ำเงินเข้ม
        }
        if name.contains("tisco") || name.contains("ทิสโก้") || name.contains("ทิสโก") {
            return ("ทิสโก้", "#004F9F") // สีน้ำเงิน
        }
        if name.contains("lhb") || name.contains("แลนด์") || name.contains("lh bank") {
            return ("LH Bank", "#00A39A") // สีเขียวอมฟ้า
        }
        if name.contains("icbc") || name.contains("ไอซีบีซี") {
            return ("ICBC", "#C8102E") // สีแดง
        }
        if name.contains("tcrb") || name.contains("ไทยเครดิต") {
            return ("ไทยเครดิต", "#005A9C") // สีน้ำเงิน
        }
        if name.contains("promptpay") || name.contains("พร้อมเพย์") {
            return ("พร้อมเพย์", "#003B64") // สีกรมท่า
        }
        if name.contains("truemoney") || name.contains("ทรูมันนี่") || name.contains("true money") {
            return ("TrueMoney", "#F37021") // สีส้ม
        }
        
        return ("อื่นๆ", "#8E8E93")
    }
    
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
