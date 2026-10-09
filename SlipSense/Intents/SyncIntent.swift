//
//  SyncIntent.swift
//  SlipSense
//
//  Created by MarkCnw on 10/4/26.
//

import AppIntents
import SwiftData
import Photos
import WidgetKit

struct SyncIntent: AudioPlaybackIntent {
    static var title: LocalizedStringResource = "ซิงค์ข้อมูลสลิป"
    static var description = IntentDescription("ประมวลผลและอัปเดตยอดสลิปวันนี้จากรูปภาพ")
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // 1. ดึง ModelContainer ของ SlipRecord
        guard let modelContainer = try? ModelContainer(for: SlipRecord.self) else {
            return .result()
        }
        let context = modelContainer.mainContext
        
        // 2. เช็คสิทธิ์และสแกนรูปภาพใหม่จากอัลบั้มธนาคารในเบื้องหลัง
        let photoService = PhotoService()
        let isAllowed = await photoService.checkPhotoPermission()
        
        if isAllowed {
            let lastSyncDate = (UserDefaults.standard.object(forKey: "LastBankSyncDate") as? Date)
                ?? (UserDefaults.standard.object(forKey: "LastPhotoSyncDate") as? Date)
                ?? Calendar.current.startOfDay(for: Date())
            
            let bankCollections = photoService.fetchTargetBankCollections()
            var allNewAssets: [PHAsset] = []
            for collection in bankCollections {
                let newAssets = photoService.fetchNewPhotos(in: collection, since: lastSyncDate)
                allNewAssets.append(contentsOf: newAssets)
            }
            
            if !allNewAssets.isEmpty {
                let photoProvider = PhotoImageProvider()
                let worker = SlipScanWorker(modelContainer: modelContainer)
                
                await worker.batchScan(assets: allNewAssets, imageProvider: photoProvider) { _ in }
                
                UserDefaults.standard.set(Date(), forKey: "LastBankSyncDate")
                UserDefaults.standard.set(Date(), forKey: "LastPhotoSyncDate")
            }
        }
        
        // 3. ดึงยอดเงินรวมของวันนี้ทั้งหมดมาคำนวณ
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let descriptor = FetchDescriptor<SlipRecord>(
            predicate: #Predicate<SlipRecord> { $0.scanDate >= startOfDay && !$0.isSelfTransfer }
        )
        
        let todaySlips = (try? context.fetch(descriptor)) ?? []
        let totalAmount = todaySlips.reduce(0.0) { $0 + $1.amount }
        
        // 4. บันทึกผลลัพธ์ลง App Group UserDefaults สำหรับ Widget (พร้อมแจกแจงหมวดหมู่)
        SlipWidgetDataManager.shared.updateTodayExpense(from: todaySlips)
        
        return .result()
    }
}
