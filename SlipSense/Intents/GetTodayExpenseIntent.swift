import AppIntents
import SwiftData
import Foundation
import Photos

struct GetTodayExpenseIntent: AppIntent {
    
    // ชื่อและคำอธิบายที่จะไปโผล่ในแอป Shortcuts
    static var title: LocalizedStringResource = "ยอดใช้จ่ายวันนี้"
    static var description = IntentDescription("เช็คยอดใช้จ่ายวันนี้จากแอป SlipSense พร้อมอัปเดตสลิปอัตโนมัติ")
    
    // ตั้งค่าเป็น false เพื่อให้ Siri ทำงานแบบเงียบๆ ได้แม้ล็อกหน้าจอ
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        // ---------------------------------------------------------
        // STEP 1: เตรียม ModelContext
        // ---------------------------------------------------------
        guard let modelContainer = try? ModelContainer(for: SlipRecord.self) else {
            throw Error.databaseNotReady
        }
        let context = modelContainer.mainContext
        
        // ---------------------------------------------------------
        // STEP 2: โหลดเวลา Sync ล่าสุดจาก UserDefaults
        // ---------------------------------------------------------
        let lastSyncKey = "LastPhotoSyncDate"
        let lastSyncDate = UserDefaults.standard.object(forKey: lastSyncKey) as? Date ?? Date().addingTimeInterval(-86400)
        
        // ---------------------------------------------------------
        // STEP 3: ดึงรูปและสแกน OCR แบบ Synchronous
        // ---------------------------------------------------------
        let photoService = PhotoService()
        let photoProvider = PhotoImageProvider()
        // ✅ แก้ Error 1: ส่ง modelContainer เข้าไปด้วย
        let ocrWorker = SlipScanWorker(modelContainer: modelContainer)
        
        // ✅ แก้ Error 2: ดึงรูปภาพใหม่ให้ตรงกับโครงสร้างของ PhotoService
        let bankCollections = photoService.fetchTargetBankCollections()
        var newSlips: [PHAsset] = []
        for collection in bankCollections {
            let assets = photoService.fetchNewPhotos(in: collection, since: lastSyncDate)
            newSlips.append(contentsOf: assets)
        }
        
        if !newSlips.isEmpty {
            // ใช้ batchScan ของเดิมที่มีอยู่แล้ว ระบบจะบันทึกลง Database ให้อัตโนมัติใน Background
            await ocrWorker.batchScan(assets: newSlips, imageProvider: photoProvider) { _ in
                // ปล่อยให้ Worker ทำงานไปจนครบทุุกรูป
            }
            
            // ---------------------------------------------------------
            // STEP 4: อัปเดตเวลา Sync ล่าสุด
            // ---------------------------------------------------------
            UserDefaults.standard.set(Date(), forKey: lastSyncKey)
        }
        
        // ---------------------------------------------------------
        // STEP 5: ดึงยอดเงินรวมของวันนี้ทั้งหมดมาคำนวณ
        // ---------------------------------------------------------
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        
        // ✅ แก้ Error 3 & 4: เปลี่ยนจาก timestamp เป็น scanDate และระบุ Type ของ Predicate ให้ชัดเจน
        let fetchDescriptor = FetchDescriptor<SlipRecord>(
            predicate: #Predicate<SlipRecord> { $0.scanDate >= startOfDay }
        )
        
        let todayRecords = (try? context.fetch(fetchDescriptor)) ?? []
        let totalAmount = todayRecords.reduce(0) { $0 + $1.amount }
        
        // ---------------------------------------------------------
        // 🌟 STEP 5.1: ดึงวงเงินที่ตั้งไว้มาเช็คและแจ้งเตือน
        // ---------------------------------------------------------
        let dailyLimit = UserDefaults.standard.double(forKey: "dailyLimit")
        
        
        
        // ---------------------------------------------------------
        // STEP 6: จัดฟอร์แมตตัวเลขและให้ Siri ขานตอบ
        // ---------------------------------------------------------
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "th_TH")
        let amountString = formatter.string(from: NSNumber(value: totalAmount)) ?? "0 บาท"
        
        let dialog = IntentDialog("วันนี้คุณใช้เงินไปทั้งหมด \(amountString) ค่ะ")
        
        return .result(dialog: dialog)
    }
    
    // จัดการ Error
    enum Error: Swift.Error, CustomLocalizedStringResourceConvertible {
        case databaseNotReady
        
        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .databaseNotReady:
                return "ขออภัยค่ะ ไม่สามารถเข้าถึงฐานข้อมูลได้ในขณะนี้"
            }
        }
    }
}
