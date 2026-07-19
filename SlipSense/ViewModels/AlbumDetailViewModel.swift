import Foundation
import Photos
import SwiftData
import SwiftUI

@MainActor
@Observable
final class AlbumDetailViewModel {
    private let photoService: PhotoService
    private let imageProvider = PhotoImageProvider()
    
    var assets: [PHAsset] = []
    var isBatchScanning = false
    var scannedCount = 0
    
    var savedCount = 0
    var skippedDuplicateCount = 0
    var skippedSelfTransferCount = 0
    var skippedNoAmountCount = 0
    var skippedNoOCRCount = 0
    var failedCount = 0
    
    // 🛑 เก็บ Task ไว้เพื่อยกเลิกได้จริง
    private var scanTask: Task<Void, Never>?
    
    init(photoService: PhotoService) {
        self.photoService = photoService
    }
    
    var progressText: String {
        "กำลังสแกนสลิป \(scannedCount) / \(assets.count) รูป..."
    }
    
    var summaryText: String {
        "บันทึก: \(savedCount) | ซ้ำ: \(skippedDuplicateCount) | โอนตัวเองต่างธนาคาร: \(skippedSelfTransferCount)"
    }
    
    func loadAssets(in album: PHAssetCollection) {
        assets = photoService.fetchPhotos(in: album)
    }
    
    /// 🛑 ยกเลิกการสแกนจริงๆ (หยุด Task เบื้องหลัง)
    func cancelScan() {
        scanTask?.cancel()
        scanTask = nil
        isBatchScanning = false
        print("🛑 สแกนถูกยกเลิกโดยผู้ใช้ | สแกนไป: \(scannedCount) / \(assets.count)")
    }
    
    func startBatchScan(context: ModelContext) {
        guard !assets.isEmpty, !isBatchScanning else { return }
        
        isBatchScanning = true
        resetCounters()
        
        let assetsToScan = assets
        let container = context.container
        
        scanTask = Task(priority: .userInitiated) {
            let worker = SlipScanWorker(modelContainer: container)
            
            await worker.batchScan(assets: assetsToScan, imageProvider: imageProvider) { result in
                Task { @MainActor in
                    self.scannedCount += 1
                    self.consume(result)
                }
            }
            
            // อัปเดตสถานะเมื่อเสร็จสิ้น (ถ้ายังไม่ถูกยกเลิก)
            if !Task.isCancelled {
                await MainActor.run {
                    self.isBatchScanning = false
                    print("✅ scan done | บันทึก: \(self.savedCount) ซ้ำ: \(self.skippedDuplicateCount)")
                }
            }
        }
    }
    private func resetCounters() {
        scannedCount = 0
        savedCount = 0
        skippedDuplicateCount = 0
        skippedSelfTransferCount = 0
        skippedNoAmountCount = 0
        skippedNoOCRCount = 0
        failedCount = 0
    }
    
    private func consume(_ result: SlipScanResult) {
        switch result.status {
        case .saved:
            savedCount += 1
        case .skippedDuplicate:
            skippedDuplicateCount += 1
        case .skippedSelfTransferCrossBank:
            skippedSelfTransferCount += 1
        case .skippedNoAmount:
            skippedNoAmountCount += 1
        case .skippedNoOCRText:
            skippedNoOCRCount += 1
        case .failed:
            failedCount += 1
        }
    }
}

