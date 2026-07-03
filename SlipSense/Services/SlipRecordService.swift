import Foundation
import SwiftData


struct SlipRecordService {
    /// throw เฉพาะ save ผิดพลาด
    func processScannedSlip(
        amount: Double,
        date: Date,
        transID: String,
        assetIdentifier: String,
        bankName: String,
        memo: String,
        context: ModelContext
    ) throws -> SlipScanStatus {
        
        // ด่านกันซ้ำใน service อีกชั้น
        let descriptor = FetchDescriptor<SlipRecord>(
            predicate: #Predicate { $0.assetIdentifier == assetIdentifier }
        )
        
        let existingSlips = try context.fetch(descriptor)
        if !existingSlips.isEmpty {
            return .skippedDuplicate
        }
        
        
        let newSlip = SlipRecord(
            amount: amount,
            scanDate: date,
            assetIdentifier: assetIdentifier,
            transactionID: transID,
            bankName: bankName,
            memo: memo
        )
        
        context.insert(newSlip)
        try context.save()
        return .saved
    }
}

