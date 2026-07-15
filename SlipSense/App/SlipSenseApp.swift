import SwiftUI
import SwiftData

@main
struct SlipSenseApp: App {
    // ดึงค่าที่ผู้ใช้เลือกไว้มาใช้งาน
    @AppStorage("appTheme") private var appTheme: Int = 0
    
    var body: some Scene {
        WindowGroup {
            // 💡 เปลี่ยนจาก MainTabView() เป็น ContentView() ตรงนี้นะครับ!
            ContentView()
            
                .preferredColorScheme(.light)
            
        }
        .modelContainer(for: SlipRecord.self)
    }
}
