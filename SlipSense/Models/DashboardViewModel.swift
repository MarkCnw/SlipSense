import SwiftUI
import SwiftData

// MARK: - Models
enum DashboardTimeframe: String, CaseIterable {
    case week = "7 วันล่าสุด"
    case month = "30 วันล่าสุด"
    case custom = "กำหนดเอง"
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
    let bank: BankType // 💡 เปลี่ยนจาก String เป็น Enum BankType
    let amount: Double
}

// MARK: - ViewModel (ผู้จัดการข้อมูล)
@Observable
class DashboardViewModel {
    
    var selectedTimeframe: DashboardTimeframe = .week
    var customStartDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    var customEndDate: Date = Date()
    var showDatePickerSheet: Bool = false
    
    var daysInPeriod: Int {
        selectedTimeframe == .week ? 7 : 30
    }
    
    // 1. ฟังก์ชันกรองสลิปตามช่วงเวลา
    func filteredSlips(from slips: [SlipRecord]) -> [SlipRecord] {
        let calendar = Calendar.current
        let now = Date()
        let start: Date
        let end: Date
        
        if selectedTimeframe == .custom {
            start = calendar.startOfDay(for: customStartDate)
            end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: customEndDate) ?? customEndDate
        } else {
            start = calendar.date(byAdding: .day, value: -daysInPeriod, to: now)!
            end = now
        }
        
        return slips.filter { $0.scanDate >= start && $0.scanDate <= end }
    }
    
    // 2. หายอดรวม
    func totalAmount(from slips: [SlipRecord]) -> Double {
        return filteredSlips(from: slips).reduce(0) { $0 + $1.amount }
    }
    
    // 3. ข้อมูลกราฟวงกลม
    func bankSpendData(from slips: [SlipRecord]) -> [BankSpendData] {
        let periodSlips = filteredSlips(from: slips)
        var dict: [String: Double] = [:]
        for slip in periodSlips {
            dict[slip.bankName, default: 0] += slip.amount
        }
        return dict.map {
            let bankType = BankType(rawValue: $0.key) ?? .unknown
            return BankSpendData(bank: bankType, amount: $0.value)
        }
        .sorted { $0.amount > $1.amount }
    }
    
    // 4. ข้อมูลกราฟแท่งแนวโน้มรายวัน
    func chartData(from slips: [SlipRecord]) -> [DailyExpense] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var data: [DailyExpense] = []
        for i in (0..<daysInPeriod).reversed() {
            if let targetDate = calendar.date(byAdding: .day, value: -i, to: today) {
                let daySlips = slips.filter { calendar.isDate($0.scanDate, inSameDayAs: targetDate) }
                let dailyTotal = daySlips.reduce(0) { $0 + $1.amount }
                data.append(DailyExpense(date: targetDate, amount: dailyTotal))
            }
        }
        return data
    }
    
    // 5. ข้อมูลกราฟแท่งแนวนอน (ช่วงเวลา)
    func timeSpendData(from slips: [SlipRecord]) -> [TimeSpendData] {
        let periodSlips = filteredSlips(from: slips)
        var morning = 0.0
        var afternoon = 0.0
        var evening = 0.0
        var night = 0.0
        
        let calendar = Calendar.current
        for slip in periodSlips {
            let hour = calendar.component(.hour, from: slip.scanDate)
            if hour >= 6 && hour < 12 { morning += slip.amount }
            else if hour >= 12 && hour < 18 { afternoon += slip.amount }
            else if hour >= 18 && hour < 22 { evening += slip.amount }
            else { night += slip.amount }
        }
        
        return [
            TimeSpendData(period: "เช้า (06-12)", amount: morning, sortOrder: 0),
            TimeSpendData(period: "บ่าย (12-18)", amount: afternoon, sortOrder: 1),
            TimeSpendData(period: "ค่ำ (18-22)", amount: evening, sortOrder: 2),
            TimeSpendData(period: "ดึก (22-06)", amount: night, sortOrder: 3)
        ]
    }
}
