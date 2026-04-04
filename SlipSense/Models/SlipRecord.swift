import Foundation
import SwiftData

@Model
final class SlipRecord {
    var amount: Double
    var scanDate: Date
    var memo: String = ""
    var category: String = "ทั่วไป"
    var transactionID: String = ""
    var bankName: String = "ไม่ระบุ"
    @Attribute(.unique) var assetIdentifier: String
    
    // 💡 แก้ตรงนี้: เพิ่ม memo: String = "" เข้าไปในวงเล็บ
    init(amount: Double, scanDate: Date, assetIdentifier: String, transactionID: String = "", bankName: String = "ไม่ระบุ", memo: String = "") {
        self.amount = amount
        self.scanDate = scanDate
        self.assetIdentifier = assetIdentifier
        self.transactionID = transactionID
        self.bankName = bankName
        self.memo = memo // 💡 เพิ่มบรรทัดนี้ด้วยเพื่อจับคู่ค่า
    }
}
