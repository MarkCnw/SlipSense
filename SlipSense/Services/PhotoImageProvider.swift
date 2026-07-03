import UIKit
import Photos

struct PhotoImageProvider {
    func requestImage(
        for asset: PHAsset,
        targetSize: CGSize = CGSize(width: 1000, height: 1000),
        contentMode: PHImageContentMode = .aspectFit
    ) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            manager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: contentMode,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}
