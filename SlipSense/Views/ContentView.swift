import SwiftUI

struct ContentView: View {
    // 💡 มีแค่ตัวแปรเช็คหน้า Onboarding ตัวเดียวพอครับ
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    var body: some View {
        // 💡 ไม่ต้องมี NavigationStack หรือ PhotoManager เลยครับ
        Group {
            if hasSeenOnboarding {
                MainTabView() // ถ้าเคยดูแล้ว พาเข้าแอปหลัก
            } else {
                OnboardingView() // ถ้ายังไม่เคยดู พาไปหน้าแนะนำแอป
            }
        }
    }
}

#Preview {
    ContentView()
}
