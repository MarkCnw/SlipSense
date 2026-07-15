import SwiftUI
import SwiftData
import Photos

@MainActor
@Observable
final class InitialScanViewModel {
    var scanState: ScanState = .ready
    var progress: Double = 0.0
    var totalPhotos: Int = 0
    var scannedPhotos: Int = 0
    
    enum ScanState {
        case ready
        case requestingPermission
        case scanning
        case complete
        case noPermission
    }
    
    func requestPermissionAndScan(
        context: ModelContext,
        photoService: PhotoService,
        photoProvider: PhotoImageProvider,
        onComplete: @escaping () -> Void
    ) async {
        scanState = .requestingPermission
        
        await photoService.requestPermission()
        
        guard photoService.hasPermission else {
            scanState = .noPermission
            return
        }
        
        scanState = .scanning
        
        // 1. Get all bank albums
            let bankCollections = photoService.fetchTargetBankCollections()
            
        // 2. Fetch all photos from these albums (since Date.distantPast)
            var allAssets: [PHAsset] = []
            for collection in bankCollections {
                let assets = photoService.fetchNewPhotos(in: collection, since: .distantPast)
                allAssets.append(contentsOf: assets)
            }
            
        totalPhotos = allAssets.count
            
            if allAssets.isEmpty {
            scanState = .complete
                    onComplete()
                return
            }
            
            // 3. Scan all photos in the background
        let container = context.container
        
        // We use detached task to prevent blocking the MainActor
        await Task.detached(priority: .userInitiated) {
            let worker = SlipScanWorker(modelContainer: container)
            
            await worker.batchScan(assets: allAssets, imageProvider: photoProvider) { result in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    self.scannedPhotos += 1
                    self.progress = Double(self.scannedPhotos) / Double(self.totalPhotos)
                }
            }
            
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                // Update LastBankSyncDate after initial scan is done
                UserDefaults.standard.set(Date(), forKey: "LastBankSyncDate")
                self.scanState = .complete
                onComplete()
            }
        }.value
    }
}
