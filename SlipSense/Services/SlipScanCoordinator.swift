import Foundation
import Photos
import SwiftData
import UIKit

@Observable
final class SlipScanCoordinator {
    private var parser = SlipParserService()
    private var recordService = SlipRecordService()
    
    func scanAndStore(
        asset: PHAsset,
        image: UIImage,
        context: ModelContext
    ) -> SlipScanResult {
        let assetID = asset.localIdentifier
        
        // กันซ้ำตั้งแต่ต้น
        let descriptor = FetchDescriptor<SlipRecord>(
            predicate: #Predicate { $0.assetIdentifier == assetID }
        )
        let existing = try? context.fetch(descriptor)
        if !(existing?.isEmpty ?? true) {
            return SlipScanResult(
                assetIdentifier: assetID,
                status: .skippedDuplicate,
                amount: nil,
                bankName: nil,
                memo: nil
            )
        }
        
        // OCR
        guard let text = OCRService.shared.recognizeText(from: image), !text.isEmpty else {
            return SlipScanResult(
                assetIdentifier: assetID,
                status: .skippedNoOCRText,
                amount: nil,
                bankName: nil,
                memo: nil
            )
        }
        
        // Guard: โอนให้ตัวเองต่างธนาคาร
        if SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: text) {
            return SlipScanResult(
                assetIdentifier: assetID,
                status: .skippedSelfTransferCrossBank,
                amount: nil,
                bankName: nil,
                memo: text.replacingOccurrences(of: "\n", with: " ")
            )
        }
        
        let parsed = parser.parseSlipData(from: text)
        guard let amount = parsed.amount else {
            return SlipScanResult(
                assetIdentifier: assetID,
                status: .skippedNoAmount,
                amount: nil,
                bankName: parsed.bank,
                memo: text.replacingOccurrences(of: "\n", with: " ")
            )
        }
        
        let memo = text.replacingOccurrences(of: "\n", with: " ")
        
        do {
            let saveStatus = try recordService.processScannedSlip(
                amount: amount,
                date: asset.creationDate ?? Date(),
                transID: "",
                assetIdentifier: assetID,
                bankName: parsed.bank,
                memo: memo,
                context: context
            )
            
            return SlipScanResult(
                assetIdentifier: assetID,
                status: saveStatus,
                amount: amount,
                bankName: parsed.bank,
                memo: memo
            )
        } catch {
            return SlipScanResult(
                assetIdentifier: assetID,
                status: .failed(error.localizedDescription),
                amount: amount,
                bankName: parsed.bank,
                memo: memo
            )
        }
    }
}
