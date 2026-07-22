import SwiftUI
import SwiftData
import MessageUI

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = SettingsViewModel()
    
    // 💡 ตัวแปรหลักที่เชื่อมกับระบบหลังบ้าน
    @AppStorage("userRealName") private var userRealName: String = ""
    @State private var selectedBank: String? = nil
    
    // 💡 ตัวแปรสำหรับรับค่าแยกช่องบนหน้าจอ
    @State private var thaiName: String = ""
    @State private var englishName: String = ""
    
    // 📍 1. เพิ่มตัวแปร 2 ตัวนี้ สำหรับควบคุมหน้าต่างส่งอีเมล
    @State private var isShowingMailView = false
    @State private var showingMailAlert = false
    
    
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
                    
                    // 📍 2. แก้ไขปุ่มติดต่อผู้พัฒนาให้เรียกใช้ MessageUI
                    Button(action: {
                        if MFMailComposeViewController.canSendMail() {
                            isShowingMailView = true
                        } else {
                            showingMailAlert = true
                        }
                    }) {
                        Text("ติดต่อผู้พัฒนา / แจ้งปัญหา")
                    }
                    Button(action: {
                        // ใส่แค่ตัวเลข ID ของแอป SlipSense เท่านั้นครับ
                        let appID = "6792425485"
                        
                        // โค้ดตรงนี้จะทำหน้าที่เอาตัวเลขไปต่อกับลิงก์ที่ถูกต้องให้เองครับ
                        if let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 28)
                            Text("ให้คะแนนแอปเรา")
                                .foregroundColor(.primary)
                        }
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
            // 📍 3. เพิ่มการแสดงผลหน้าต่างอีเมล (Sheet) และแจ้งเตือน (Alert) ไว้ตรงนี้
            .sheet(isPresented: $isShowingMailView) {
                MailView(
                    isShowing: $isShowingMailView,
                    toRecipients: ["chinnawong.working@gmail.com"], // 👈 อย่าลืมเปลี่ยนเป็นอีเมลของคุณมาร์คนะครับ
                    subject: "Feedback SlipSense App",
                    messageBody: "รายละเอียดปัญหา หรือ ข้อเสนอแนะ:\n"
                )
            }
            .alert("ไม่สามารถส่งอีเมลได้", isPresented: $showingMailAlert) {
                Button("ตกลง", role: .cancel) { }
            } message: {
                Text("กรุณาตรวจสอบว่าคุณได้ล็อกอินแอป Mail บนเครื่อง iPhone ของคุณแล้ว")
            }
        }
    }
    
    
    // MARK: - Helper Functions
    
    private func updateRealName() {
        let tName = thaiName.trimmingCharacters(in: .whitespaces)
        let eName = englishName.trimmingCharacters(in: .whitespaces)
        
        userRealName = "\(tName)|\(eName)"
    }
    
    private func loadNamesToFields() {
        if userRealName.contains("|") {
            let components = userRealName.components(separatedBy: "|")
            if components.count >= 2 {
                thaiName = components[0]
                englishName = components[1]
            }
        } else {
            let hasEnglish = userRealName.range(of: "[a-zA-Z]", options: .regularExpression) != nil
            let components = userRealName.components(separatedBy: " ").filter { !$0.isEmpty }
            
            if components.count >= 2 && !hasEnglish {
                thaiName = userRealName
            } else if components.count >= 2 && hasEnglish {
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
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                // ถ้าถูกเลือกให้เป็นสีฟ้า ถ้าไม่เลือกให้เป็นสีเทาอ่อน
                .background(isSelected ? Color.blue : Color(UIColor.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    SettingsView()
}
