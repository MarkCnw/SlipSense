//
//  PhotoService.swift
//  SlipSense
//
//  Created by MarkCnw on 21/4/2569 BE.
//

import Foundation
import Photos

@Observable
class PhotoService {
    var hasPermission: Bool = false
    var albums: [AlbumInfo] = []
    
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
}
