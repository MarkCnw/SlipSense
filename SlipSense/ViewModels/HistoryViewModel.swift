import Foundation
import SwiftData
import SwiftUI

struct SlipDateGroup: Identifiable {
    var id: String { header }
    let header: String
    let slips: [SlipRecord]
    
    var count: Int {
        slips.count
    }
    
    var totalAmount: Double {
        slips.reduce(0) { $0 + $1.amount }
    }
}

@Observable
class HistoryViewModel {
    var searchText: String = ""
    
    // 💡 1. กรองข้อมูลตามที่ผู้ใช้พิมพ์ค้นหา (รับข้อมูลมาจาก @Query ใน View)
    func getFilteredSlips(from slips: [SlipRecord]) -> [SlipRecord] {
        if searchText.isEmpty {
            return slips
        } else {
            return slips.filter { slip in
                slip.bankName.localizedCaseInsensitiveContains(searchText) ||
                slip.amount.description.contains(searchText) ||
                slip.memo.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // 💡 2. ฟังก์ชันลบสลิป
    func deleteSlip(_ slip: SlipRecord, context: ModelContext) {
        context.delete(slip)
        do {
            try context.save()
        } catch {
            print("Failed to delete: \(error.localizedDescription)")
        }
    }
    
    // 💡 3. ฟังก์ชันจัดกลุ่มสลิปตามวันที่
    func groupSlipsByDate(_ slips: [SlipRecord]) -> [SlipDateGroup] {
        let calendar = Calendar.current
        
        // จัดกลุ่มโดยใช้วันที่เริ่มต้นของวันนั้นๆ (ตัดเวลาทิ้งเพื่อให้วันเดียวกันอยู่กลุ่มเดียวกัน)
        let grouped = Dictionary(grouping: slips) { slip in
            calendar.startOfDay(for: slip.scanDate)
        }
        
        // เรียงลำดับกลุ่มวันที่จากใหม่ไปเก่า (ล่าสุดขึ้นก่อน)
        let sortedGroups = grouped.sorted { $0.key > $1.key }
        
        // แปลงแต่ละกลุ่มให้เป็นรูปแบบ SlipDateGroup
        return sortedGroups.map { date, dailySlips in
            let headerString: String
            
            if calendar.isDateInToday(date) {
                headerString = "วันนี้"
            } else if calendar.isDateInYesterday(date) {
                headerString = "เมื่อวานนี้"
            } else {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "th_TH")
                formatter.dateFormat = "d MMM yyyy" // รูปแบบเช่น 28 ก.ย. 2026
                headerString = formatter.string(from: date)
            }
            
            // เรียงลำดับสลิปในแต่ละวันจากเวลาใหม่ไปเก่าด้วย
            let sortedDailySlips = dailySlips.sorted { $0.scanDate > $1.scanDate }
            
            return SlipDateGroup(header: headerString, slips: sortedDailySlips)
        }
    }
}
