import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // 탭ที่ 1: หน้า Dashboard (เดี๋ยวเราสร้างกัน)
            DashboardView()
                .tabItem {
                    Label("หน้าหลัก", systemImage: "chart.pie.fill")
                }
            
            // 탭ที่ 2: หน้าอัลบั้มสลิป
            ScanView()
                .tabItem {
                    Label("สแกน", systemImage: "viewfinder")
                }
            
            // 탭ที่ 3: หน้าประวัติ
            HistoryView()
                .tabItem {
                    Label("ประวัติ", systemImage: "list.bullet.rectangle.fill")
                }
            
            // 탭ที่ 4: หน้าตั้งค่า
            SettingsView()
                .tabItem {
                    Label("ตั้งค่า", systemImage: "gearshape.fill")
                }
        }
        .tint(.green) // เปลี่ยนสีไอคอนที่ถูกเลือกเป็นสีเขียว
    }
}

#Preview {
    MainTabView()
}
