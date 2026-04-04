import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    
    // ดึงค่าการตั้งค่าจาก AppStorage ให้ตรงกับไฟล์ App หลัก
    @AppStorage("appTheme") private var appTheme: Int = 0
   
    
    @State private var showingDeleteAlert = false
    
    // ดึงเวอร์ชันของแอปจาก Xcode
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    var body: some View {
        NavigationStack {
            List {
                // --- ส่วนการปรากฏ (Theme & Language) ---
                Section(header: Text("การปรากฏ")) {
                    // เลือกธีม
                    HStack {
                        Image(systemName: appTheme == 1 ? "sun.max.fill" : (appTheme == 2 ? "moon.fill" : "circle.lefthalf.filled"))
                            .foregroundStyle(.orange)
                        Text("ธีม")
                        Spacer()
                        Picker("", selection: $appTheme) {
                            Text("ระบบ").tag(0)
                            Text("สว่าง").tag(1)
                            Text("มืด").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                    }
                    
                   
                    
                }
                
                // --- โซนอันตราย ---
                Section(header: Text("โซนอันตราย").foregroundStyle(.red)) {
                    Button(action: { showingDeleteAlert = true }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("ล้างประวัติการสแกนทั้งหมด")
                        }
                        .foregroundStyle(.red)
                    }
                }
                
                // --- ข้อมูลแอป ---
                Section(header: Text("เกี่ยวกับแอป")) {
                    HStack {
                        Text("เวอร์ชัน")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("ผู้พัฒนา")
                        Spacer()
                        Text("MarkCnw")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            // 💡 ข้อความทั้งหมดนี้ระบบจะนำไปแปลภาษาผ่าน Localizable.xcstrings ให้อัตโนมัติ
            .navigationTitle("การตั้งค่า")
            .alert("ยืนยันการล้างข้อมูล?", isPresented: $showingDeleteAlert) {
                Button("ยกเลิก", role: .cancel) { }
                Button("ลบทิ้งทั้งหมด", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("ประวัติรายจ่ายทั้งหมดจะถูกลบ (รูปสลิปในเครื่องยังอยู่)")
            }
        }
    }
    
    // MARK: - ฟังก์ชันล้างข้อมูลประวัติทั้งหมด
    private func deleteAllData() {
        do {
            // ลบข้อมูล SlipRecord ทั้งหมดในฐานข้อมูล
            try context.delete(model: SlipRecord.self)
            try context.save()
            print("ล้างข้อมูลสำเร็จ!")
        } catch {
            print("เกิดข้อผิดพลาดในการลบข้อมูล: \(error.localizedDescription)")
        }
    }
}
