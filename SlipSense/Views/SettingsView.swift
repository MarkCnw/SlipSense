import SwiftUI
import SwiftData
import MessageUI
import SafariServices

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
    
    // 📍 ตัวแปรสำหรับควบคุมหน้าต่างส่งอีเมลและเว็บไซต์
    @State private var isShowingMailView = false
    @State private var showingMailAlert = false
    @State private var isShowingWebsite = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    filterSection
                    syncSection
                    securitySection
                    aboutSection
                    versionSection
                }
                .disabled(viewModel.isSyncing || viewModel.showSuccessOverlay)
                .blur(radius: (viewModel.isSyncing || viewModel.showSuccessOverlay) ? 6 : 0)
                
                if viewModel.isSyncing || viewModel.showSuccessOverlay {
                    syncOverlayView
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.isSyncing || viewModel.showSuccessOverlay)
            .navigationTitle("การตั้งค่า")
            .toolbar((viewModel.isSyncing || viewModel.showSuccessOverlay) ? .hidden : .visible, for: .tabBar)
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
            // 🌐 หน้าต่างเปิดเว็บไซต์นักพัฒนาแบบ In-App Safari
            .sheet(isPresented: $isShowingWebsite) {
                if let url = URL(string: "https://portfolio.markcnw.workers.dev/") {
                    SafariView(url: url)
                        .ignoresSafeArea()
                }
            }
            .alert("ยืนยันการล้างข้อมูล?", isPresented: $viewModel.showingDeleteAlert) {
                Button("ยกเลิก", role: .cancel) { }
                Button("ลบทิ้งทั้งหมด", role: .destructive) {
                    viewModel.deleteAllData(context: context)
                }
            } message: {
                Text("ประวัติรายจ่ายทั้งหมดจะถูกลบ (รูปสลิปในเครื่องยังอยู่)")
            }
            .alert("แจ้งเตือนการซิงค์", isPresented: $viewModel.showingSyncAlert) {
                Button("ตกลง", role: .cancel) { }
            } message: {
                Text(viewModel.syncAlertMessage ?? "")
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
            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .font(.body)
                    .foregroundStyle(Color(uiColor: .systemBlue))
                    .frame(width: 28)
                TextField("สมหมาย ใจดี", text: $thaiName)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .onChange(of: thaiName) { _, _ in updateRealName() }
            }
            
            HStack(spacing: 12) {
                Image(systemName: "textformat.abc")
                    .font(.body)
                    .foregroundStyle(Color(uiColor: .systemBlue))
                    .frame(width: 28)
                TextField("Sommai jaidee", text: $englishName)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .onChange(of: englishName) { _, _ in updateRealName() }
            }
        } header: {
            Text("ชื่อจริงของคุณ (สำหรับดักจับยอดโอนตัวเอง)")
        } footer: {
            Text("ระบบจะใช้ข้อมูลนี้เพื่อตรวจสอบและข้ามการคำนวณสลิปที่คุณโอนเงินระหว่างบัญชีของตัวเอง")
        }
    }
    
    @ViewBuilder
    private var syncSection: some View {
        Section {
            Button {
                viewModel.startSync(context: context)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color(uiColor: .systemPurple))
                        .frame(width: 28)
                    Text("ซิงค์สลิปทั้งหมด")
                        .foregroundStyle(.primary)
                    Spacer()
                }
            }
        } header: {
            Text("ข้อมูลและการซิงค์")
        } footer: {
            Text("ค้นหาและสแกนสลิปจากอัลบั้มธนาคารทั้งหมดในเครื่องของคุณโดยอัตโนมัติ")
        }
    }
    
    @ViewBuilder
    private var securitySection: some View {
        Section(header: Text("ความปลอดภัย")) {
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.body)
                    .foregroundStyle(Color(uiColor: .systemBlue))
                    .frame(width: 28)
                Toggle("เปิดใช้รหัสผ่าน", isOn: Binding(
                    get: { securityService.isSecurityEnabled },
                    set: { newValue in
                        viewModel.toggleSecurity(isEnabled: newValue, securityService: securityService)
                    }
                ))
            }
        }
    }
    
    @ViewBuilder
    private var aboutSection: some View {
        Section {
            // 🌐 ปุ่มเปิด In-App Safari
            Button {
                isShowingWebsite = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "globe")
                        .font(.body)
                        .foregroundStyle(Color(uiColor: .systemBlue))
                        .frame(width: 28)
                    Text("เว็บไซต์นักพัฒนา")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            
            Button(action: {
                if MFMailComposeViewController.canSendMail() {
                    isShowingMailView = true
                } else {
                    showingMailAlert = true
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "envelope.fill")
                        .font(.body)
                        .foregroundStyle(Color(uiColor: .systemBlue))
                        .frame(width: 28)
                    Text("ติดต่อผู้พัฒนา / แจ้งปัญหา")
                        .foregroundStyle(.primary)
                    Spacer()
                }
            }
            
            Button(action: {
                let appID = "6792425485"
                if let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.body)
                        .foregroundStyle(Color(uiColor: .systemYellow))
                        .frame(width: 28)
                    Text("ให้คะแนนแอปเรา")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        } header: {
            Text("เกี่ยวกับแอป")
        }
    }
    
    @ViewBuilder
    private var versionSection: some View {
        Section {
            EmptyView()
        } footer: {
            VStack(spacing: 4) {
                Text("SlipSense")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("เวอร์ชัน \(viewModel.appVersion)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
    }
    
    // 🌟 Overlay แสดงสถานะการสแกนตรงกลางจอ (ล็อกการใช้งานชั่วคราว)
    @ViewBuilder
    private var syncOverlayView: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
        
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 25, x: 0, y: 15)
                
                if viewModel.showSuccessOverlay {
                    VStack(spacing: 16) {
                        Image("allgood")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(Color.green)
                        
                        Text("สเเกนสำเร็จ!")
                            .font(.system(.title, design: .rounded).weight(.heavy))
                            .foregroundStyle(.primary)
                    }
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
                } else {
                    let progress = Double(viewModel.scannedCount) / Double(max(viewModel.totalCount, 1))
                    
                    Circle()
                        .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .padding(18)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .padding(18)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                    
                    VStack(spacing: 12) {
                        Image("Update--Streamline-Manila")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        
                        VStack(spacing: 4) {
                            Text("\(Int(progress * 100))%")
                                .font(.system(.title, design: .rounded).weight(.heavy))
                                .foregroundStyle(.primary)
                                .contentTransition(.numericText())
                            
                            Text("\(viewModel.scannedCount) / \(viewModel.totalCount)")
                                .font(.headline.monospacedDigit().bold())
                                .foregroundStyle(.secondary)
                                .contentTransition(.numericText())
                        }
                    }
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
            .frame(width: 280, height: 280)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.showSuccessOverlay)
            
            Text(viewModel.showSuccessOverlay ? "สแกนเสร็จสิ้น" : "กำลังตรวจสอบและบันทึกข้อมูล...")
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
        .transition(.scale(scale: 0.9).combined(with: .opacity))
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

// 🌐 SafariView Wrapper
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariVC = SFSafariViewController(url: url)
        safariVC.dismissButtonStyle = .done
        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    SettingsView()
}
