import Foundation
import Photos
import SwiftData

@Observable
class PhotoManager {
    var albums: [AlbumInfo] = []
    var hasPermission: Bool = false
    
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
    
    // 💡 แก้ Error 1: เพิ่ม assetIdentifier เพื่อส่งไปเซฟ และใช้เช็คสลิปซ้ำ
    func processScannedSlip(amount: Double, date: Date, transID: String, assetIdentifier: String, context: ModelContext) {
        // เช็คว่ารูปนี้เคยเซฟไปหรือยัง (แม่นยำ 100%)
        let descriptor = FetchDescriptor<SlipRecord>(
            predicate: #Predicate { $0.assetIdentifier == assetIdentifier }
        )
        
        let existingSlips = try? context.fetch(descriptor)
        
        if let existing = existingSlips, !existing.isEmpty {
            print("สลิปซ้ำ! ไม่บันทึกเพิ่ม")
        } else {
            // บันทึกโดยใส่ assetIdentifier เข้าไปด้วย
            let newSlip = SlipRecord(amount: amount, scanDate: date, assetIdentifier: assetIdentifier, transactionID: transID)
            context.insert(newSlip)
            try? context.save()
        }
    }
    
    private func extractAmount(from text: String) -> String? {
        let lines = text.components(separatedBy: "\n")
        let pattern = #"\d{1,3}(?:,\d{3})*\.\d{2}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        
        let keywords = ["จำนวนเงิน", "ยอดโอน", "amount", "total amount", "thb"]
        let blacklist = ["ยอดเงินคงเหลือ", "available balance", "balance"]

        for (index, line) in lines.enumerated() {
            let lowerLine = line.lowercased().replacingOccurrences(of: " ", with: "")
            
            if blacklist.contains(where: { lowerLine.contains($0) }) { continue }
            
            if keywords.contains(where: { lowerLine.contains($0) }) {
                if let match = findFirstNumber(in: line, using: regex) { return match }
                if index + 1 < lines.count {
                    if let match = findFirstNumber(in: lines[index + 1], using: regex) { return match }
                }
            }
        }
        return nil
    }
    
    // 💡 แก้ Error 2: เติมฟังก์ชันดึงตัวเลขจากข้อความที่หายไป
    private func findFirstNumber(in text: String, using regex: NSRegularExpression) -> String? {
        let nsString = text as NSString
        if let firstMatch = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length)).first {
            return nsString.substring(with: firstMatch.range)
        }
        return nil
    }
    
    private func detectBank(from text: String) -> String {
        let lowerText = text.lowercased().replacingOccurrences(of: " ", with: "")
        
        if lowerText.contains("kbank") || lowerText.contains("กสิกร") { return "KBANK" }
        if lowerText.contains("scb") || lowerText.contains("ไทยพาณิชย์") { return "SCB" }
        if lowerText.contains("bbl") || lowerText.contains("กรุงเทพ") { return "BBL" }
        if lowerText.contains("ktb") || lowerText.contains("กรุงไทย") { return "KTB" }
        if lowerText.contains("krungsri") || lowerText.contains("กรุงศรี") || lowerText.contains("bay") { return "BAY" }
        if lowerText.contains("ttb") || lowerText.contains("ทหารไทยธนชาต") { return "TTB" }
        
        return "ไม่ระบุ"
    }
}
