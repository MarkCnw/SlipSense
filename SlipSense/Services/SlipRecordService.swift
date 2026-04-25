import Foundation
import SwiftData

@Observable
class SlipRecordService {
    
    /// onSkipped จะถูกเรียกเมื่อระบบตัดสินใจข้ามสลิป (เช่น โอนให้ตัวเองต่างธนาคาร)
    func processScannedSlip(
        amount: Double,
        date: Date,
        transID: String,
        assetIdentifier: String,
        bankName: String,
        memo: String,
        context: ModelContext,
        onSkipped: ((String) -> Void)? = nil
    ) {
        // ✅ ด่านกันหลัก: ข้ามถ้าเป็น self-transfer ข้ามธนาคาร
        if SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: memo) {
            onSkipped?("ไม่บันทึก: โอนให้ตัวเองต่างธนาคาร")
            return
        }

        let descriptor = FetchDescriptor<SlipRecord>(
            predicate: #Predicate { $0.assetIdentifier == assetIdentifier }
        )
        
        let existingSlips = try? context.fetch(descriptor)
        
        if let existing = existingSlips, !existing.isEmpty {
            onSkipped?("ไม่บันทึก: สลิปซ้ำ")
        } else {
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
