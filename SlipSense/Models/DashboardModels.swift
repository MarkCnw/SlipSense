import Foundation

enum DashboardTimeframe: String, CaseIterable {
    case today = "1 วันล่าสุด"
    case week = "7 วันล่าสุด"
    case month = "30 วันล่าสุด"
    case custom = "กำหนดเอง"
}

enum DashboardTab: String, CaseIterable {
        case overview = "ภาพรวม"
        case category = "หมวดหมู่" // 🌟 1. เพิ่มบรรทัดนี้เข้ามา
        case behavior = "พฤติกรรม"
}

struct DailyExpense: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

struct TimeSpendData: Identifiable {
    let id = UUID()
    let period: String
    let amount: Double
    let sortOrder: Int
}

struct BankSpendData: Identifiable {
    let id = UUID()
    let bank: BankType
    let amount: Double
}

struct CategoryExpenseSummary: Identifiable {
    let id = UUID()
    let categoryName: String
    let totalAmount: Double
}
