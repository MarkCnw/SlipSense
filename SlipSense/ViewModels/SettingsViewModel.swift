import Foundation
import SwiftData
import SwiftUI
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    @ObservationIgnored
    @AppStorage("appTheme") var appTheme: Int = 0
    
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
    
    func deleteAllData(context: ModelContext) {
        do {
            try context.delete(model: SlipRecord.self)
            try context.save()
        } catch {
            errorMessage = "เกิดข้อผิดพลาดในการลบข้อมูล: \(error.localizedDescription)"
        }
    }
}
