import Foundation
import Photos 

struct AlbumInfo: Identifiable {
    let id = UUID()
    let name: String
    let photoCount: Int
    let collection: PHAssetCollection
}
