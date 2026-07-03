import SwiftUI
import SwiftData
import Photos

@MainActor
@Observable
final class DashboardViewModel {
    
    var selectedTimeframe: DashboardTimeframe = .week
    var customStartDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    var customEndDate: Date = Date()
    var showDatePickerSheet = false
    
    var daysInPeriod: Int {
        switch selectedTimeframe {
        case .today: return 1         // 📍 คืนค่า 1 วัน
        case .week: return 7
        case .month: return 30
        case .custom:
            let calendar = Calendar.current
            let start = calendar.startOfDay(for: customStartDate)
            let end = calendar.startOfDay(for: customEndDate)
            let diff = calendar.dateComponents([.day], from: start, to: end).day ?? 0
            return max(diff + 1, 1)
        }
    }
    
    @MainActor
        func autoSyncBankSlips(context: ModelContext, photoProvider: PhotoImageProvider, photoService: PhotoService) async {
            let isAllowed = await photoService.checkPhotoPermission()
            guard isAllowed else {
                return
            }
            
            // 1. ดึงเวลาที่เคยสแกนล่าสุด
            let lastSyncDate = UserDefaults.standard.object(forKey: "LastBankSyncDate") as? Date ?? Date.distantPast
            
            // 2. ดึงอัลบั้มธนาคารทั้งหมด
            let bankCollections = photoService.fetchTargetBankCollections()
            
            // 3. รวบรวมรูปใหม่ทั้งหมดที่เพิ่งเข้ามา
            var allNewAssets: [PHAsset] = []
            for collection in bankCollections {
                let newAssets = photoService.fetchNewPhotos(in: collection, since: lastSyncDate)
                allNewAssets.append(contentsOf: newAssets)
            }
            
            // 4. ถ้ามีรูปใหม่ โยนให้พนักงานหลังบ้าน (SlipScanWorker) ไปจัดการเงียบๆ
            if !allNewAssets.isEmpty {
                let worker = SlipScanWorker(modelContainer: context.container)
                
                await worker.batchScan(assets: allNewAssets, imageProvider: photoProvider) { _ in
                    // ปล่อยให้มันรันไป ไม่ต้องอัปเดต UI ในหน้านี้
                }
                
                // 5. บันทึกเวลาปัจจุบันทับลงไปเมื่อสแกนเสร็จ
                UserDefaults.standard.set(Date(), forKey: "LastBankSyncDate")
            }
        }
    
    func displayBankName(fromCode code: String) -> String {
        switch code {
        case "KBANK": return "กสิกร"
        case "SCB": return "ไทยพาณิชย์"
        case "BBL": return "กรุงเทพ"
        case "KTB": return "กรุงไทย"
        case "BAY": return "กรุงศรี"
        case "TTB": return "TTB"
        case "ออมสิน": return "ออมสิน"
        default: return "ไม่ระบุ"
        }
    }
    
    func filteredSlips(from slips: [SlipRecord]) -> [SlipRecord] {
        let calendar = Calendar.current
        let now = Date()
        let start: Date
        let end: Date
        
        if selectedTimeframe == .custom {
            let s = calendar.startOfDay(for: customStartDate)
            let e = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: customEndDate) ?? customEndDate
            start = min(s, e)
            end = max(s, e)
        } else {
            // 📍 ปรับตรงนี้ให้รองรับเคสวันนี้ (offset = 0)
            let dayOffset: Int
            switch selectedTimeframe {
            case .today: dayOffset = 0
            case .week: dayOffset = 7
            case .month: dayOffset = 30
            case .custom: dayOffset = 0
            }
            
            // ถ้าเป็น .today ตัว start จะกลายเป็นจุดเริ่มต้นของวันปัจจุบันพอดี
            start = calendar.date(byAdding: .day, value: -dayOffset, to: calendar.startOfDay(for: now)) ?? now
            end = now
        }
        return slips.filter { $0.scanDate >= start && $0.scanDate <= end }
    }
    
    func totalAmount(from periodSlips: [SlipRecord]) -> Double {
        periodSlips.reduce(0) { $0 + $1.amount }
    }
    
    func bankSpendData(from periodSlips: [SlipRecord]) -> [BankSpendData] {
        var dict: [String: Double] = [:]
        
        for slip in periodSlips {
            dict[slip.bankName, default: 0] += slip.amount
        }
        
        return dict.map { key, value in
            BankSpendData(bank: BankType(rawValue: key) ?? .unknown, amount: value)
        }
        .sorted { $0.amount > $1.amount }
    }
    
    func chartData(from periodSlips: [SlipRecord]) -> [DailyExpense] {
        let calendar = Calendar.current
        let endBaseDate = (selectedTimeframe == .custom) ? customEndDate : Date()
        let endDate = calendar.startOfDay(for: endBaseDate)
        
        var data: [DailyExpense] = []
        for i in (0..<daysInPeriod).reversed() {
            guard let targetDate = calendar.date(byAdding: .day, value: -i, to: endDate) else { continue }
            let daySlips = periodSlips.filter { calendar.isDate($0.scanDate, inSameDayAs: targetDate) }
            let total = daySlips.reduce(0) { $0 + $1.amount }
            data.append(DailyExpense(date: targetDate, amount: total))
        }
        return data
    }
    
    func timeSpendData(from periodSlips: [SlipRecord]) -> [TimeSpendData] {
        let calendar = Calendar.current
        
        var morning = 0.0
        var afternoon = 0.0
        var evening = 0.0
        var night = 0.0
        
        for slip in periodSlips {
            let hour = calendar.component(.hour, from: slip.scanDate)
            if hour >= 6 && hour < 12 { morning += slip.amount }
            else if hour >= 12 && hour < 18 { afternoon += slip.amount }
            else if hour >= 18 && hour < 22 { evening += slip.amount }
            else { night += slip.amount }
        }
        
        return [
            TimeSpendData(period: "เช้า (06-12)", amount: morning, sortOrder: 0),
            TimeSpendData(period: "บ่าย (12-18)", amount: afternoon, sortOrder: 1),
            TimeSpendData(period: "ค่ำ (18-22)", amount: evening, sortOrder: 2),
            TimeSpendData(period: "ดึก (22-06)", amount: night, sortOrder: 3)
        ]
    }
}
