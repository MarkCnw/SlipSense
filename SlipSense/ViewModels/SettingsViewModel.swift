import Foundation
import SwiftData
import SwiftUI
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    @ObservationIgnored
    @AppStorage("appTheme") var appTheme: Int = 0
    
    var isShowingCreatePINSheet: Bool = false
        var isShowingDisablePIN: Bool = false
    
    var showingDeleteAlert = false
    var errorMessage: String?
    
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
    
    // 🌟 2. เพิ่มฟังก์ชันนี้สำหรับจัดการตอนผู้ใช้กดเปิด/ปิดสวิตช์ความปลอดภัย
        func toggleSecurity(isEnabled: Bool, securityService: SecurityService) {
            if isEnabled {
                // ถ้ากดเปิด -> โชว์หน้าตั้ง PIN
                isShowingCreatePINSheet = true
            } else {
                // ถ้ากดปิด -> โชว์หน้าใส่ PIN เพื่อยืนยัน
                isShowingDisablePIN = true
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
