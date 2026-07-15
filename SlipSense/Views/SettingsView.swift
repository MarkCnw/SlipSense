import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = SettingsViewModel()
    
    // 💡 ตัวแปรหลักที่เชื่อมกับระบบหลังบ้าน
    @AppStorage("userRealName") private var userRealName: String = ""
    
    // 💡 ตัวแปรสำหรับรับค่าแยกช่องบนหน้าจอ
    @State private var thaiName: String = ""
    @State private var englishName: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Filter Settings
                Section {
                    HStack {
                        Image(systemName: "character.book.closed.fill")
                            .foregroundStyle(.blue)
                            .frame(width: 28)
                        TextField("สมหมาย ใจดี", text: $thaiName)
                            .submitLabel(.done)
                            .onChange(of: thaiName) { _, _ in updateRealName() }
                    }
                    
                    HStack {
                        Image(systemName: "textformat.abc")
                            .foregroundStyle(.blue)
                            .frame(width: 28)
                        TextField("Sommai jaidee", text: $englishName)
                            .submitLabel(.done)
                            .onChange(of: englishName) { _, _ in updateRealName() }
                    }
                } header: {
                    Text("ชื่อจริงของคุณ (สำหรับดักจับยอดโอนตัวเอง)")
                } footer: {
                    Text("ใส่ชื่อจริงเเละนามสกุล ระบบจะใช้ข้อมูลนี้เพื่อตรวจสอบและข้ามการคำนวณสลิปที่คุณโอนเงินระหว่างบัญชีของตัวเอง")
                }
                
                // MARK: - About App
                Section {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.gray)
                            .frame(width: 28)
                        Text("เวอร์ชัน")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "hammer.fill")
                            .foregroundStyle(.gray)
                            .frame(width: 28)
                        Text("ผู้พัฒนา")
                        Spacer()
                        Text("MarkCnw")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("เกี่ยวกับแอป")
                }
                
                // MARK: - Danger Zone
                Section {
                    Button(role: .destructive) {
                        viewModel.showingDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                                .frame(width: 28)
                            Text("ล้างประวัติการสแกนทั้งหมด")
                        }
                    }
                } header: {
                    Text("โซนอันตราย")
                }
            }
            .navigationTitle("การตั้งค่า")
            // 💡 โหลดข้อมูลเดิมมาแยกใส่ 2 ช่องตอนเปิดหน้าจอ
            .onAppear {
                loadNamesToFields()
            }
            .alert("ยืนยันการล้างข้อมูล?", isPresented: $viewModel.showingDeleteAlert) {
                Button("ยกเลิก", role: .cancel) { }
                Button("ลบทิ้งทั้งหมด", role: .destructive) {
                    viewModel.deleteAllData(context: context)
                }
            } message: {
                Text("ประวัติรายจ่ายทั้งหมดจะถูกลบ (รูปสลิปในเครื่องยังอยู่)")
            }
            .alert("ผิดพลาด", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("ตกลง", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// ฟังก์ชันจับชื่อจาก 2 ช่องมารวมกันแล้วบันทึกลงระบบหลัก
    private func updateRealName() {
        let tName = thaiName.trimmingCharacters(in: .whitespaces)
        let eName = englishName.trimmingCharacters(in: .whitespaces)
        
        // ใช้ | เป็นตัวแบ่ง เพื่อป้องกันปัญหานามสกุล (ที่มีช่องว่าง) โดนตัดไปอยู่อีกช่อง
        userRealName = "\(tName)|\(eName)"
    }
    
    /// ฟังก์ชันอ่านค่าจากระบบหลัก มาแยกเป็นไทยและอังกฤษเพื่อแสดงในช่อง
    private func loadNamesToFields() {
        if userRealName.contains("|") {
            let components = userRealName.components(separatedBy: "|")
            if components.count >= 2 {
                thaiName = components[0]
                englishName = components[1]
            }
        } else {
            // กรณีข้อมูลเก่าที่ยังไม่มี |
            let hasEnglish = userRealName.range(of: "[a-zA-Z]", options: .regularExpression) != nil
            let components = userRealName.components(separatedBy: " ").filter { !$0.isEmpty }
            
            // ถ้าข้อมูลเก่ามี 2 คำขึ้นไปและไม่มีภาษาอังกฤษเลย ให้ถือว่าเป็นชื่อ-นามสกุลภาษาไทย
            if components.count >= 2 && !hasEnglish {
                thaiName = userRealName
            } else if components.count >= 2 && hasEnglish {
                // ถ้ามีภาษาอังกฤษผสม เดาว่าคำแรกไทย คำสองอังกฤษ (แบบดั้งเดิม)
                thaiName = components[0]
                englishName = components[1...].joined(separator: " ")
            } else if let name = components.first {
                if hasEnglish {
                    englishName = name
                } else {
                    thaiName = name
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
