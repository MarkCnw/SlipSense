import Foundation
import Photos
import UIKit

@MainActor
@Observable
final class SlipImageDetailViewModel {
    var image: UIImage?
    var isLoading = false
    
    private let imageProvider = PhotoImageProvider()
    
    func loadImage(assetIdentifier: String) {
        guard !isLoading else { return }
        isLoading = true
        
        Task(priority: .userInitiated) {
            defer { isLoading = false }
            
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
            guard let asset = fetchResult.firstObject else {
                image = nil
                return
            }
            
            image = await imageProvider.requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit
            )
        }
    }
}
