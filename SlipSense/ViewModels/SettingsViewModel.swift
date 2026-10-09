import Foundation
import SwiftData
import SwiftUI
import Observation
import Photos

@MainActor
@Observable
final class SettingsViewModel {
    @ObservationIgnored
    @AppStorage("appTheme") var appTheme: Int = 0
    
    var isShowingCreatePINSheet: Bool = false
    var isShowingDisablePIN: Bool = false
    
    var showingDeleteAlert = false
    var errorMessage: String?
    
    // 🔄 Sync State
    var isSyncing: Bool = false
    var showSuccessOverlay: Bool = false
    var scannedCount: Int = 0
    var totalCount: Int = 0
    var syncAlertMessage: String?
    var showingSyncAlert: Bool = false
    
    private let photoService = PhotoService()
    private let imageProvider = PhotoImageProvider()
    private var syncTask: Task<Void, Never>?
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var themeIconName: String {
        switch appTheme {
        case 1: return "sun.max.fill"
        case 2: return "moon.fill"
        default: return "circle.lefthalf.filled"
        }
    }
    
    // 🌟 ฟังก์ชันจัดการเปิด/ปิดสวิตช์ความปลอดภัย
    func toggleSecurity(isEnabled: Bool, securityService: SecurityService) {
        if isEnabled {
            isShowingCreatePINSheet = true
        } else {
            isShowingDisablePIN = true
        }
    }
    
    // 🔄 ฟังก์ชันสแกนและซิงค์สลิปจากทุกอัลบั้มธนาคารในเครื่อง
    func startSync(context: ModelContext) {
        guard !isSyncing else { return }
        
        syncTask = Task {
            let hasPermission = await photoService.checkPhotoPermission()
            guard hasPermission else {
                showingSyncAlert = true
                syncAlertMessage = "กรุณาอนุญาตให้แอปเข้าถึงรูปภาพเพื่อทำการสแกนสลิป"
                return
            }
            
            let collections = photoService.fetchTargetBankCollections()
            var allAssets: [PHAsset] = []
            var seen = Set<String>()
            
            for collection in collections {
                let assets = photoService.fetchPhotos(in: collection)
                for asset in assets {
                    if !seen.contains(asset.localIdentifier) {
                        seen.insert(asset.localIdentifier)
                        allAssets.append(asset)
                    }
                }
            }
            
            guard !allAssets.isEmpty else {
                showingSyncAlert = true
                syncAlertMessage = "ไม่พบรูปภาพในอัลบั้มธนาคารสำหรับซิงค์ข้อมูล"
                return
            }
            
            self.totalCount = allAssets.count
            self.scannedCount = 0
            self.isSyncing = true
            
            let container = context.container
            let worker = SlipScanWorker(modelContainer: container)
            
            await worker.batchScan(assets: allAssets, imageProvider: imageProvider) { _ in
                Task { @MainActor in
                    self.scannedCount += 1
                }
            }
            
            if !Task.isCancelled {
                // อัปเดตข้อมูล widget ให้เป็นยอดล่าสุดทันที
                let descriptor = FetchDescriptor<SlipRecord>()
                if let slips = try? context.fetch(descriptor) {
                    SlipWidgetDataManager.shared.updateTodayExpense(from: slips)
                }
                
                self.showSuccessOverlay = true
                
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                
                self.showSuccessOverlay = false
                self.isSyncing = false
            }
        }
    }
    
    func deleteAllData(context: ModelContext) {
        do {
            try context.delete(model: SlipRecord.self)
            try context.save()
        } catch {
            errorMessage = "เกิดข้อผิดพลาดในการลบข้อมูล: \(error.localizedDescription)"
        }
    }
}
