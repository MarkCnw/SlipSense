import Foundation
import SwiftData
import SwiftUI

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
}
