import SwiftUI
import SwiftData

struct InitialScanView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = InitialScanViewModel()
    @State private var photoService = PhotoService()
    @State private var photoProvider = PhotoImageProvider()
    
    @AppStorage("isInitialScanComplete") private var isInitialScanComplete: Bool = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 📍 Header
            VStack(spacing: 16) {
                Text(viewModel.scanState == .scanning ? "กำลังสแกนสลิป..." : "พร้อมใช้งาน")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .multilineTextAlignment(.center)
                
                Text(viewModel.scanState == .scanning ? "ระบบกำลังดึงข้อมูลสลิปทั้งหมด\nเพื่อนำมาวิเคราะห์ยอดใช้จ่ายของคุณ" : "กรุณากดปุ่มด้านล่างเพื่ออนุญาตให้เข้าถึงรูปภาพ\nและเริ่มต้นการสแกนสลิปทั้งหมด")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
            
            // 📍 Main Content Area
            if viewModel.scanState == .ready || viewModel.scanState == .noPermission || viewModel.scanState == .requestingPermission {
                Button {
                    Task {
                        await viewModel.requestPermissionAndScan(
                            context: modelContext,
                            photoService: photoService,
                            photoProvider: photoProvider
                        ) {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                isInitialScanComplete = true
                            }
                        }
                    }
                } label: {
                    VStack(spacing: 16) {
                        Image(systemName: "viewfinder.circle.fill")
                            .font(.system(size: 72)) // ปรับลดไซส์นิดนึงให้สมดุล
                        
                        Text("เริ่มสแกนสลิป")
                            .font(.title3.bold())
                            .minimumScaleFactor(0.8) // อนุญาตให้ฟอนต์หดลงได้นิดหน่อยถ้าจอมือถือเล็ก
                    }
                    .foregroundColor(.white)
                    .padding(40) // ใช้ Padding แทนการฟิกซ์กรอบเป๊ะๆ ให้ขยายตามตัวอักษรได้
                    .frame(maxWidth: 240, minHeight: 240) // กำหนดกรอบแบบยืดหยุ่น
                    .background(
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8) // ปรับเงาให้นุ่มนวลขึ้น
                    )
                }
                .scaleEffect(viewModel.scanState == .requestingPermission ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.scanState)
                // 🔊 เพิ่ม VoiceOver สำหรับ Accessibility
                .accessibilityLabel("ปุ่มเริ่มสแกนสลิป")
                .accessibilityHint("กดเพื่ออนุญาตให้แอปเข้าถึงรูปภาพและเริ่มค้นหาสลิปเงินฝาก")
                
                if viewModel.scanState == .noPermission {
                    Button(action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("เปิดการตั้งค่าเพื่ออนุญาต")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 16)
                }
                
            } else {
                // 📍 Progress Circle View
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), style: StrokeStyle(lineWidth: 16, lineCap: .round)) // ใช้สีระบบเพื่อรองรับ Dark/Light Mode
                    
                    Circle()
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(
                            LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 16, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.2), value: viewModel.progress)
                    
                    VStack(spacing: 8) {
                        Text("\(Int(viewModel.progress * 100))%")
                            .font(.system(.largeTitle, design: .rounded).weight(.bold))
                            .contentTransition(.numericText()) // ✨ แอนิเมชันสลับตัวเลขแบบ Apple
                        
                        Text("\(viewModel.scannedPhotos) / \(viewModel.totalPhotos)")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText())
                    }
                }
                .frame(maxWidth: 240, maxHeight: 240) // ใช้ขนาดแบบยืดหยุ่น
                .padding()
                // 🔊 รวมกลุ่มให้ VoiceOver อ่านรวดเดียว
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("กำลังสแกนไปแล้ว \(Int(viewModel.progress * 100)) เปอร์เซ็นต์")
            }
            
            Spacer()
        }
    }
}
