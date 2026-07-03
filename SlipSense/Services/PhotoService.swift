import Foundation
import Photos

@Observable
class PhotoService {
    var hasPermission: Bool = false
    var albums: [AlbumInfo] = []
    // 1. รายชื่อโฟลเดอร์แอปธนาคารยอดฮิตในไทย
    let targetBankAlbums = ["K PLUS", "MyMo", "SCB Easy", "BualuangM", "Krungthai NEXT", "ttb touch", "KMA", "Krungthai NEXT"]
    
    // 2. ฟังก์ชันดึงเฉพาะอัลบั้มธนาคารที่มีในเครื่อง
    func fetchTargetBankCollections() -> [PHAssetCollection] {
        var targetCollections: [PHAssetCollection] = []
        let fetchOptions = PHFetchOptions()
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions) //
        
        collections.enumerateObjects { (collection, _, _) in
            let albumName = collection.localizedTitle ?? ""
            if self.targetBankAlbums.contains(albumName) {
                targetCollections.append(collection)
            }
        }
        return targetCollections
    }
    
    func fetchNewPhotos(in collection: PHAssetCollection, since date: Date) -> [PHAsset] {
        var assets: [PHAsset] = []
        let fetchOptions = PHFetchOptions()
        
        // 💡 กรองเอาเฉพาะรูปที่มีวันที่สร้างใหม่กว่าวันที่กำหนด
        fetchOptions.predicate = NSPredicate(format: "creationDate > %@", date as NSDate)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)] //
        
        let result = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        return assets
    }
    
    func requestPermission() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        
        await MainActor.run {
            if status == .authorized || status == .limited {
                self.hasPermission = true
                self.fetchAlbums()
            } else {
                self.hasPermission = false
            }
        }
    }
    
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
    
    
    func fetchPhotos(in collection: PHAssetCollection) -> [PHAsset] {
        var assets: [PHAsset] = []
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let result = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        return assets
    }
    
    func checkPhotoPermission()async -> Bool {
        let currentStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if currentStatus == .authorized || currentStatus == .limited {
            return true
        }
        let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        if newStatus == .authorized || newStatus == .limited {
            return true
        }
        return false
        
        
        
    }
}
