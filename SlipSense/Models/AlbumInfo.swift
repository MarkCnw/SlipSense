import Foundation
import Photos // 💡 อย่าลืม import Photos นะครับ สำคัญมาก!

struct AlbumInfo: Identifiable {
    let id = UUID()
    let name: String
    let photoCount: Int
    let collection: PHAssetCollection
}
