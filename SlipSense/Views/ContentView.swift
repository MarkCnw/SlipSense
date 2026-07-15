import SwiftUI

struct ContentView: View {
    // 💡 ตัวแปรเช็คสถานะการเข้าใช้งานครั้งแรก
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("isInitialScanComplete") private var isInitialScanComplete: Bool = false
    @AppStorage("hasName") private var hasName: Bool = false
    
    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else if !hasName {
                NameInputView()
                    .transition(.opacity)
            } else if !isInitialScanComplete{
                InitialScanView()
            }else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.8), value: hasSeenOnboarding)
        .animation(.easeInOut(duration: 0.8), value: hasName)
        .animation(.easeInOut(duration: 0.8), value: isInitialScanComplete)
    }
}

#Preview {
    ContentView()
}
