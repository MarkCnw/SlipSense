import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // 탭ที่ 1: หน้า Dashboard (เดี๋ยวเราสร้างกัน)
            Text("หน้าสรุปยอด (Dashboard)")
                .tabItem {
                    Label("หน้าหลัก", systemImage: "chart.pie.fill")
                }
            
            // 탭ที่ 2: หน้าอัลบั้มสลิป (หน้าที่เราทำเสร็จแล้ว!)
            ContentView()
                .tabItem {
                    Label("สแกน", systemImage: "viewfinder")
                }
            
            // 탭ที่ 3: หน้าประวัติ (เดี๋ยวเราสร้างกัน)
            Text("ประวัติสลิปทั้งหมด")
                .tabItem {
                    Label("ประวัติ", systemImage: "list.bullet.rectangle.fill")
                }
            
            // 탭ที่ 4: หน้าตั้งค่า
            Text("ตั้งค่าแอป")
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
