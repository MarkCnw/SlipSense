import SwiftUI
import SwiftData // 💡 1. Import SwiftData

@main
struct SlipSenseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // 💡 2. เอา Model ที่เพิ่งสร้าง ไปเสียบปลั๊กที่ระดับบนสุดของแอป!
        .modelContainer(for: SlipRecord.self)
    }
}
