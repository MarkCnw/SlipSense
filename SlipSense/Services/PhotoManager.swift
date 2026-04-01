import Foundation
import Photos

// 💡 @Observable (iOS 17+) ทำหน้าที่เหมือน ChangeNotifier ใน Flutter
// คือถ้าข้อมูลในคลาสนี้เปลี่ยน หน้าจอที่เรียกใช้จะอัปเดตตัวเองอัตโนมัติ!
@Observable
class PhotoManager {
    var albums: [AlbumInfo] = []
    var hasPermission: Bool = false
    
    // ย้าย Logic การขอ Permission มาไว้ที่นี่
    func requestPermission() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        
        // ต้องสั่งอัปเดต UI บน Main Thread
        await MainActor.run {
            if status == .authorized || status == .limited {
                self.hasPermission = true
                self.fetchAlbums() // อนุญาตปุ๊บ ดึงข้อมูลอัลบั้มต่อเลย
            } else {
                self.hasPermission = false
            }
        }
    }
    
    // ย้าย Logic การดึงอัลบั้มมาไว้ที่นี่
    private func fetchAlbums() {
        var tempAlbums: [AlbumInfo] = []
        let fetchOptions = PHFetchOptions()
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        collections.enumerateObjects { (collection, _, _) in
            let assetsFetchResult = PHAsset.fetchAssets(in: collection, options: nil)
            let count = assetsFetchResult.count
            
            if count > 0 {
                let albumName = collection.localizedTitle ?? "ไม่ทราบชื่อ"
                let newAlbum = AlbumInfo(name: albumName, photoCount: count, collection: collection)
                tempAlbums.append(newAlbum)
            }
        }
        
        self.albums = tempAlbums
    }
    
    // 💡 ฟังก์ชันใหม่: ดึงรูปภาพทั้งหมดที่อยู่ในอัลบั้มที่เลือก
        func fetchPhotos(in collection: PHAssetCollection) -> [PHAsset] {
            var assets: [PHAsset] = []
            
            // สั่งให้เรียงรูปใหม่ล่าสุดขึ้นก่อน
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            // ไปดึงรูปมาเลย!
            let result = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            result.enumerateObjects { asset, _, _ in
                assets.append(asset)
            }
            
            return assets
        }
}
