import SwiftUI
import SwiftData
import MessageUI

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(SecurityService.self) private var securityService
    @State private var viewModel = SettingsViewModel()
    
    // 💡 ตัวแปรหลักที่เชื่อมกับระบบหลังบ้าน
    @AppStorage("userRealName") private var userRealName: String = ""
    @State private var selectedBank: String? = nil
    
    // 💡 ตัวแปรสำหรับรับค่าแยกช่องบนหน้าจอ
    @State private var thaiName: String = ""
    @State private var englishName: String = ""
    @State private var security = false
    
    // 📍 ตัวแปรสำหรับควบคุมหน้าต่างส่งอีเมล
    @State private var isShowingMailView = false
    @State private var showingMailAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                filterSection
                aboutSection
                securitySection
                dangerZoneSection
            }
            .navigationTitle("การตั้งค่า")
            .onAppear {
                loadNamesToFields()
            }
            .sheet(isPresented: $viewModel.isShowingCreatePINSheet) {
                CreatePINView(securityService: securityService)
            }
            .sheet(isPresented: $viewModel.isShowingDisablePIN) {
                LockScreenView(securityService: securityService, isForDisable: true)
            }
            .sheet(isPresented: $isShowingMailView) {
                MailView(
                    isShowing: $isShowingMailView,
                    toRecipients: ["chinnawong.working@gmail.com"],
                    subject: "Feedback SlipSense App",
                    messageBody: "รายละเอียดปัญหา หรือ ข้อเสนอแนะ:\n"
                )
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
            .alert("ไม่สามารถส่งอีเมลได้", isPresented: $showingMailAlert) {
                Button("ตกลง", role: .cancel) { }
            } message: {
                Text("กรุณาตรวจสอบว่าคุณได้ล็อกอินแอป Mail บนเครื่อง iPhone ของคุณแล้ว")
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var filterSection: some View {
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
    }
    
    @ViewBuilder
    private var aboutSection: some View {
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
                Text("นักพัฒนา")
                Spacer()
                Text("MarkCnw")
                    .foregroundStyle(.secondary)
            }
            
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
                let appID = "6792425485"
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
    }
    
    @ViewBuilder
    private var securitySection: some View {
        Section(header: Text("ความปลอดภัย")) {
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.blue)
                    .frame(width: 28)
                Toggle("เปิดใช้ Face ID เเละ รหัส", isOn: Binding(
                    get: { securityService.isSecurityEnabled },
                    set: { newValue in
                        viewModel.toggleSecurity(isEnabled: newValue, securityService: securityService)
                    }
                ))
            }
            
        }
    }
    
    @ViewBuilder
    private var dangerZoneSection: some View {
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

// MARK: - Components Outside View

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
                .background(isSelected ? Color.blue : Color(UIColor.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    SettingsView()
}
