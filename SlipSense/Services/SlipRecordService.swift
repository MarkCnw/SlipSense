import Foundation
import SwiftData

@Observable
class SlipRecordService {
    
    // 💡 อัปเดตเพิ่ม bankName: String และ memo: String เข้ามาในวงเล็บ
    func processScannedSlip(amount: Double, date: Date, transID: String, assetIdentifier: String, bankName: String, memo: String, context: ModelContext) {
        
        let descriptor = FetchDescriptor<SlipRecord>(
            predicate: #Predicate { $0.assetIdentifier == assetIdentifier }
        )
        
        let existingSlips = try? context.fetch(descriptor)
        
        if let existing = existingSlips, !existing.isEmpty {
            print("สลิปซ้ำ! ไม่บันทึกเพิ่ม")
        } else {
            // 💡 โยนค่า bankName กับ memo ใส่ลงไปตอนสร้าง Record ด้วย
            let newSlip = SlipRecord(
                amount: amount,
                scanDate: date,
                assetIdentifier: assetIdentifier,
                transactionID: transID,
                bankName: bankName,
                memo: memo
            )
            context.insert(newSlip)
            try? context.save()
        }
    }
}
