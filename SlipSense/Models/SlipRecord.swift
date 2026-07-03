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
    
    // 💡 1. เพิ่มตัวแปรเช็คการโอนให้ตัวเองตรงนี้ครับ
    var isSelfTransfer: Bool = false
    
    init(
        amount: Double,
        scanDate: Date,
        assetIdentifier: String,
        transactionID: String = "",
        bankName: String = "ไม่ระบุ",
        memo: String = "",
        isSelfTransfer: Bool = false // 💡 2. เพิ่มเข้ามารับค่าตอนสร้างสลิป
    ) {
        self.amount = amount
        self.scanDate = scanDate
        self.assetIdentifier = assetIdentifier
        self.transactionID = transactionID
        self.bankName = bankName
        self.memo = memo
        self.isSelfTransfer = isSelfTransfer // 💡 3. กำหนดค่าลง Database
    }
    
    /// Convenience: resolved `BankType` enum from the stored string.
    var bankType: BankType {
        BankType(rawValue: bankName) ?? .unknown
    }
}
