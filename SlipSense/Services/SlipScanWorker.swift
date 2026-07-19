import Foundation
import Photos
import SwiftData
import UIKit

/// ดินแดนเบื้องหลัง 100% สำหรับสแกนสลิปโดยเฉพาะ ไม่กวนหน้าจอหลัก
actor SlipScanWorker {
    private let parser: SlipParserService
        private let recordService: SlipRecordService
        private let modelContainer: ModelContainer
        
        init(modelContainer: ModelContainer) {
            self.modelContainer = modelContainer
            self.parser = SlipParserService()
            self.recordService = SlipRecordService()
        }
    
    /// ฟังก์ชันวนลูปสแกนรูปทั้งหมดที่เบื้องหลัง
    func batchScan(
        assets: [PHAsset],
        imageProvider: PhotoImageProvider,
        onProgress: @escaping @Sendable (SlipScanResult) -> Void
    ) async {
        
        // สร้าง ModelContext สำหรับหลังบ้านโดยเฉพาะ ปลอดภัยและไม่แลค
        let backgroundContext = ModelContext(modelContainer)
        
        for asset in assets {
            // 🛑 เช็คว่า Task ถูกยกเลิกหรือยัง
            if Task.isCancelled {
                print("🛑 batchScan ถูกยกเลิก — หยุดสแกน")
                break
            }
            
            let assetID = asset.localIdentifier
            
            // 1. เช็คซ้ำในหลังบ้าน
            let descriptor = FetchDescriptor<SlipRecord>(predicate: #Predicate { $0.assetIdentifier == assetID })
            let existing = try? backgroundContext.fetch(descriptor)
            if !(existing?.isEmpty ?? true) {
                let result = SlipScanResult(assetIdentifier: assetID, status: .skippedDuplicate, amount: nil, bankName: nil, memo: nil)
                onProgress(result)
                continue
            }
            
            // 2. ดึงรูปในหลังบ้าน
            guard let image = await imageProvider.requestImage(for: asset) else {
                let result = SlipScanResult(assetIdentifier: assetID, status: .failed("ดึงรูปไม่ได้"), amount: nil, bankName: nil, memo: nil)
                onProgress(result)
                continue
            }
            
            // 3. ทำ OCR ในหลังบ้าน
            guard let text = await OCRService.shared.recognizeText(from: image), !text.isEmpty else {
                let result = SlipScanResult(assetIdentifier: assetID, status: .skippedNoOCRText, amount: nil, bankName: nil, memo: nil)
                onProgress(result)
                continue
            }
            
            // 4. ตรวจสอบเงื่อนไขโอนเงินให้ตัวเอง
            if SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: text) {
                let result = SlipScanResult(assetIdentifier: assetID, status: .skippedSelfTransferCrossBank, amount: nil, bankName: nil, memo: text.replacingOccurrences(of: "\n", with: " "))
                onProgress(result)
                continue
            }
            
            // 5. แกะข้อมูลและบันทึกในหลังบ้าน
            let parsed = parser.parseSlipData(from: text)
            guard let amount = parsed.amount else {
                let result = SlipScanResult(assetIdentifier: assetID, status: .skippedNoAmount, amount: nil, bankName: parsed.bank, memo: text.replacingOccurrences(of: "\n", with: " "))
                onProgress(result)
                continue
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
                    context: backgroundContext
                )
                
                // บันทึกข้อมูลลงฐานข้อมูลเบื้องหลัง
                try backgroundContext.save()
                
                let result = SlipScanResult(assetIdentifier: assetID, status: saveStatus, amount: amount, bankName: parsed.bank, memo: memo)
                onProgress(result)
            } catch {
                let result = SlipScanResult(assetIdentifier: assetID, status: .failed(error.localizedDescription), amount: amount, bankName: parsed.bank, memo: memo)
                onProgress(result)
            }
            
            // 💡 ให้ระบบหายใจ — เปิดช่องว่างให้ main thread render UI ได้
            await Task.yield()
        }
    }
}
