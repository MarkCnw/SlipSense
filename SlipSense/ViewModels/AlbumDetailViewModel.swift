import Foundation
import Photos
import SwiftData
import SwiftUI

@MainActor
@Observable
final class AlbumDetailViewModel {
    private let photoService: PhotoService
    private var coordinator = SlipScanCoordinator()
    
    var assets: [PHAsset] = []
    var isBatchScanning = false
    var scannedCount = 0
    
    var savedCount = 0
    var skippedDuplicateCount = 0
    var skippedSelfTransferCount = 0
    var skippedNoAmountCount = 0
    var skippedNoOCRCount = 0
    var failedCount = 0
    
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
    
    func startBatchScan(context: ModelContext) {
        guard !assets.isEmpty, !isBatchScanning else { return }
        
        isBatchScanning = true
        scannedCount = 0
        savedCount = 0
        skippedDuplicateCount = 0
        skippedSelfTransferCount = 0
        skippedNoAmountCount = 0
        skippedNoOCRCount = 0
        failedCount = 0
        
        // capture บน MainActor ก่อนเข้า detached
        let assetsToScan = assets
        let coordinator = self.coordinator
        
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = true
            
            for asset in assetsToScan {
                manager.requestImage(
                    for: asset,
                    targetSize: CGSize(width: 900, height: 900),
                    contentMode: .aspectFit,
                    options: options
                ) { [weak self] image, _ in
                    guard let self, let image else { return }
                    
                    let result = coordinator.scanAndStore(
                        asset: asset,
                        image: image,
                        context: context
                    )
                    
                    Task { @MainActor in
                        self.consume(result)
                    }
                }
                
                await MainActor.run {
                    self.scannedCount += 1
                }
            }
            
            await MainActor.run {
                self.isBatchScanning = false
                print("✅ scan done | \(self.summaryText)")
            }
        }
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
