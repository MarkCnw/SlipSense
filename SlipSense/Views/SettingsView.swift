import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = SettingsViewModel()
    @AppStorage("userRealName") private var userRealName: String = ""
    
    var body: some View {
        NavigationStack {
            // 📍 ใช้ Form ครอบทุก Section เพื่อให้เป็นไปตามมาตรฐานหน้า Settings ของ iOS
            Form {
                
                // MARK: - Filter Settings
                Section {
                    HStack {
                        Image(systemName: "person.text.rectangle")
                            .foregroundStyle(.blue)
                            .frame(width: 28) // ล็อคความกว้างไอคอนให้ตรงกันทุกบรรทัด
                        TextField("เช่น: สมหมาย ใจดี sommai jaidee", text: $userRealName)
                    }
                } header: {
                    Text("ชื่อจริงของคุณ (ไทยและอังกฤษ)")
                } footer: {
                    Text("พิมพ์เฉพาะ 'ชื่อจริง' ของคุณ เว้นวรรคด้วยภาษาไทยและอังกฤษ เพื่อให้แอปข้ามการบันทึก 'สลิปโอนเงินให้ตัวเอง' อัตโนมัติ")
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
                    // 📍 ใช้ role: .destructive ระบบจะทำตัวอักษรให้เป็นสีแดงตามมาตรฐาน HIG อัตโนมัติ
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
}
