import SwiftUI

struct ContentView: View {
    // 💡 ตัวแปรเช็คสถานะการเข้าใช้งานครั้งแรก
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("isInitialScanComplete") private var isInitialScanComplete: Bool = false
    @AppStorage("hasName") private var hasName: Bool = false
    
    // 1. สร้างตัวแปร SecurityService ให้เป็นตัวหลักของแอป
    @State private var securityService = SecurityService()
        
    // 2. ตัวจับสถานะแอป (ใช้งานอยู่, พับจอ, หรือปิดแอป)
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack {
            // 3. ลอจิกประตูทางเข้า: ถ้า "เปิดสวิตช์ความปลอดภัย" และ "ยังไม่ได้ปลดล็อก"
            if securityService.isSecurityEnabled && !securityService.isAppUnlocked {
                
                // แสดงหน้าจอล็อกแอป ปิดทับทุกสิ่งทุกอย่าง!
                LockScreenView(securityService: securityService)
                    .transition(.opacity) // ให้มีแอนิเมชันจางหายเวลาปลดล็อกสำเร็จ
                
            } else {
                
                // ✅ ถ้าไม่ได้เปิดล็อก หรือ ปลดล็อกสำเร็จแล้ว ให้โชว์หน้าแอปหลักทั้งหมดตรงนี้
                Group {
                    if !hasSeenOnboarding {
                        OnboardingView()
                            .transition(.opacity)
                    } else if !hasName {
                        NameInputView()
                            .transition(.opacity)
                    } else if !isInitialScanComplete {
                        InitialScanView()
                            .transition(.opacity)
                    } else {
                        MainTabView()
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.8), value: hasSeenOnboarding)
                .animation(.easeInOut(duration: 0.8), value: hasName)
                .animation(.easeInOut(duration: 0.8), value: isInitialScanComplete)
                
            }
        }
        // ส่ง SecurityService เข้า Environment ให้ View ลูกทุกตัวเข้าถึงได้
        .environment(securityService)
        // ทำให้การสลับหน้าจอระหว่างจอล็อกกับจอแอปดูนุ่มนวล
        .animation(.easeInOut, value: securityService.isAppUnlocked)
        
        // 4. ทีเด็ดแอปธนาคาร: พับจอเมื่อไหร่ สั่งล็อกทันที!
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // เมื่อแอปถูกพับไปอยู่เบื้องหลัง (Background)
            if newPhase == .background {
                // ถ้าตั้งค่าเปิดระบบล็อกไว้ ให้ปรับสถานะเป็น "ยังไม่ปลดล็อก"
                if securityService.isSecurityEnabled {
                    securityService.isAppUnlocked = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
