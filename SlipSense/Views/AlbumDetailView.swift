import SwiftUI
import Photos
import SwiftData

struct AlbumDetailView: View {
    let album: AlbumInfo
    var photoService: PhotoService
    
    @Environment(\.modelContext) private var context
    @State private var viewModel: AlbumDetailViewModel
    @State private var showSuccessOverlay = false
        
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    init(album: AlbumInfo, photoService: PhotoService) {
        self.album = album
        self.photoService = photoService
        _viewModel = State(initialValue: AlbumDetailViewModel(photoService: photoService))
    }
    
    var body: some View {
        ZStack {
            // โซน 1: ตารางรูปภาพ หรือ หน้าว่าง
            if viewModel.assets.isEmpty {
                // 🌟 เพิ่ม Empty State ตามหลัก HIG
                ContentUnavailableView(
                    "ไม่มีรูปภาพ",
                    systemImage: "photo.on.rectangle.angled",
                    description: Text("ไม่พบรูปภาพในอัลบั้มนี้")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(viewModel.assets, id: \.localIdentifier) { asset in
                                ThumbnailView(asset: asset)
                                    .frame(height: 120)
                                    .clipped()
                            
                        }
                    }
                }
                // 🌟 ปิดการกดและเบลอพื้นหลัง ทั้งตอนกำลังสแกน และตอนโชว์หน้าสำเร็จ
                .disabled(viewModel.isBatchScanning || showSuccessOverlay)
                .blur(radius: (viewModel.isBatchScanning || showSuccessOverlay) ? 6 : 0)
            }
            
            // โซน 2: Overlay แสดงสถานะการสแกนตรงกลางจอ
            if viewModel.isBatchScanning || showSuccessOverlay { // 🌟 เช็คเงื่อนไขทั้ง 2 สถานะ
                Color.black.opacity(0.5) // ปรับให้มืดลงอีกนิดให้ UI ลอยเด่นขึ้น
                    .ignoresSafeArea()
                
                VStack(spacing: 28) { // เพิ่มระยะห่างระหว่างวงกลมกับข้อความด้านล่าง
                    
                    // ส่วนของวงกลม Progress + รูป SVG + เปอร์เซ็นต์
                    ZStack {
                        // 1. พื้นหลังวงกลมสีขาว
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 25, x: 0, y: 15)
                        
                        // 🌟 แบ่งการแสดงผลเป็น 2 สเตจ: ตอนสำเร็จ vs ตอนกำลังสแกน
                        if showSuccessOverlay {
                            // --- สเตจ 2: ตอนสแกนเสร็จสมบูรณ์ ---
                            VStack(spacing: 16) {
                                Image("allgood")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100) // ให้ขนาด 90 เท่ากับรูป Bugs
                                    .foregroundStyle(Color.green)
                                
                                Text("สเเกนสำเร็จ!")
                                    .font(.system(.title, design: .rounded).weight(.heavy))
                                    .foregroundStyle(.primary)
                            }
                            .transition(.scale(scale: 0.5).combined(with: .opacity))
                            
                        } else {
                            // --- สเตจ 1: ตอนกำลังสแกน ---
                            let progress = Double(viewModel.scannedCount) / Double(max(viewModel.assets.count, 1))
                            
                            // 2. วงกลมพื้นหลัง (ราง) ดันเข้ามา 18px
                            Circle()
                                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                .padding(18)
                            
                            // 3. วงกลมความคืบหน้าแบบสีเกรเดียนต์
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .padding(18)
                                .animation(.easeInOut(duration: 0.3), value: progress)
                            
                            // 4. รูป SVG และ ข้อมูลเปอร์เซ็นต์
                            VStack(spacing: 12) {
                                Image("Update--Streamline-Manila")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    
                                VStack(spacing: 4) {
                                    Text("\(Int(progress * 100))%")
                                        .font(.system(.title, design: .rounded).weight(.heavy)) // ปรับตัวเลขให้หนาและใหญ่ขึ้น
                                        .foregroundStyle(.primary)
                                        .contentTransition(.numericText())
                                    
                                    Text("\(viewModel.scannedCount) / \(viewModel.assets.count)")
                                        // 🌟 ใช้ .monospacedDigit() เพื่อไม่ให้ตัวเลขขยับซ้ายขวาเวลานับ
                                        .font(.headline.monospacedDigit().bold())
                                        .foregroundStyle(.secondary)
                                        .contentTransition(.numericText())
                                }
                            }
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                        }
                    }
                    .frame(width: 280, height: 280)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showSuccessOverlay) // แอนิเมชันสลับสเตจวงกลมด้านใน
                    
                    // 🌟 ดึงข้อความมาไว้ด้านล่างในแคปซูลกระจก ดูมินิมอลขึ้น (สลับข้อความตามสถานะ)
                    Text(showSuccessOverlay ? "สแกนเสร็จสิ้น" : "กำลังตรวจสอบและบันทึกข้อมูล...")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.isBatchScanning || showSuccessOverlay)
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isBatchScanning || showSuccessOverlay) // 🌟 ซ่อนปุ่ม Back ไว้จนกว่าจะโชว์เสร็จ
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if showSuccessOverlay {
                    // 🌟 ซ่อนปุ่มด้านขวาบน ตอนที่กำลังโชว์เครื่องหมายถูก
                    EmptyView()
                } else if viewModel.isBatchScanning {
                    Button("ยกเลิกสแกน") {
                        viewModel.cancelScan()
                    }
                    .bold()
                } else {
                    Button("สแกนทั้งหมด") {
                        viewModel.startBatchScan(context: context)
                    }
                    .bold()
                    .disabled(viewModel.assets.isEmpty)
                }
            }
        }
        .onAppear {
            viewModel.loadAssets(in: album.collection)
        }
        // 🌟 ดักจับเมื่อการสแกนเสร็จสมบูรณ์ เพื่อตั้งเวลาโชว์เครื่องหมายถูก
        .onChange(of: viewModel.isBatchScanning) { _, isScanning in
            if !isScanning && viewModel.scannedCount == viewModel.assets.count && viewModel.assets.count > 0 {
                
                showSuccessOverlay = true
                
                // ตั้งเวลา 1.5 วินาที แล้วปิดหน้าต่าง
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showSuccessOverlay = false
                }
            }
        }
        .toolbar((viewModel.isBatchScanning || showSuccessOverlay) ? .hidden : .visible, for: .tabBar)
        
    }
}
