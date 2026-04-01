import Foundation
import SwiftData // 💡 1. เรียกใช้งานเวทมนตร์ Database

@Model
class SlipRecord {
    var id: UUID
    var assetIdentifier: String // 💡 2. ท่าไม้ตาย! เก็บรหัสอ้างอิงรูปภาพ
    var amount: Double          // เก็บจำนวนเงิน
    var scanDate: Date          // เก็บวันที่แอปสแกนเจอ
    var isExpense: Bool         // เป็นรายจ่ายใช่ไหม? (เผื่อเอาไปทำบัญชีต่อ)
    var note: String            // เผื่อให้ผู้ใช้พิมพ์โน้ตเพิ่มเองได้
    
    init(assetIdentifier: String, amount: Double, scanDate: Date = .now, isExpense: Bool = true, note: String = "") {
        self.id = UUID()
        self.assetIdentifier = assetIdentifier
        self.amount = amount
        self.scanDate = scanDate
        self.isExpense = isExpense
        self.note = note
    }
}
