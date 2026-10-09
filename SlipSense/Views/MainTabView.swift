import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // แท็บที่ 1: หน้า Dashboard
            DashboardView()
                .tabItem {
                    Label("หน้าหลัก", systemImage: "chart.pie.fill")
                }
                .tag(0)
            
            // แท็บที่ 2: หน้าสแกนสลิป
            //ScanView()
               // .tabItem {
                   // Label("สแกน", systemImage: "viewfinder")
               // }
              //  .tag(1)
            
            // แท็บที่ 3: หน้าประวัติ
            HistoryView()
                .tabItem {
                    Label("ประวัติ", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(2)
            
            // แท็บที่ 4: หน้าตั้งค่า
            SettingsView()
                .tabItem {
                    Label("ตั้งค่า", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(.purple) // สีประจำแอป (ม่วง)
        .onOpenURL { url in
            switch url.host {
            case "dashboard":
                selectedTab = 0
            case "scan":
                selectedTab = 1
            case "history", "today":
                selectedTab = 2
            case "settings":
                selectedTab = 3
            default:
                break
            }
        }
    }
}

#Preview {
    MainTabView()
}
