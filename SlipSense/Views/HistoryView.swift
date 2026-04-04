import SwiftUI
import SwiftData
import Photos

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SlipRecord.scanDate, order: .reverse) private var slips: [SlipRecord]
    
    @State private var searchText = ""
    @State private var selectedBank = "ทั้งหมด"
    
    let banks = ["ทั้งหมด", "KBANK", "SCB", "BBL", "KTB", "BAY", "TTB", "ออมสิน", "ไม่ระบุ"]
    
    // ตั้งค่าคอลัมน์สำหรับโชว์ตารางรูปภาพ (3 รูปต่อแถว)
    let gridColumns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var filteredSlips: [SlipRecord] {
            var result = slips
            if selectedBank != "ทั้งหมด" {
                result = result.filter { $0.bankName == selectedBank }
            }
            if !searchText.isEmpty {
                // 💡 อัปเกรดระบบค้นหาให้ฉลาดและยืดหยุ่นขึ้น
                result = result.filter {
                    String($0.amount).localizedStandardContains(searchText) ||
                    $0.bankName.localizedStandardContains(searchText) ||
                    $0.memo.localizedStandardContains(searchText)
                }
            }
            return result
        }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // แถบเลือกธนาคาร (ซ่อนเมื่อกำลังค้นหา เพื่อเพิ่มพื้นที่โชว์รูป)
                if searchText.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(banks, id: \.self) { bank in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedBank = bank
                                    }
                                }) {
                                    Text(bank)
                                        .font(.subheadline)
                                        .fontWeight(selectedBank == bank ? .bold : .regular)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedBank == bank ? Color.orange : Color(.systemGray5))
                                        .foregroundStyle(selectedBank == bank ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    .background(Color(.systemBackground))
                    
                    Divider()
                } else {
                    // แสดงผลลัพธ์การค้นหา
                    HStack {
                        Text("ผลการค้นหา \(filteredSlips.count) รายการ")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding()
                }
                
                // --- สลับ UI ระหว่าง List (ปกติ) และ Grid (เมื่อค้นหา) ---
                if !searchText.isEmpty {
                    // 🌟 โหมดค้นหา: โชว์เป็นตารางรูปภาพ (Grid)
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 2) {
                            ForEach(filteredSlips) { slip in
                                NavigationLink(destination: SlipImageDetailView(slip: slip)) {
                                    SlipThumbnailView(assetIdentifier: slip.assetIdentifier)
                                        .frame(height: 130) // ปรับความสูงของรูป
                                        .clipped()
                                }
                            }
                        }
                    }
                } else {
                    // 🌟 โหมดปกติ: โชว์เป็นรายการ (List)
                    List {
                        if filteredSlips.isEmpty {
                            Text("ไม่มีประวัติรายจ่ายในหมวดหมู่นี้")
                                .foregroundStyle(.secondary)
                                .listRowSeparator(.hidden)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        } else {
                            ForEach(filteredSlips) { slip in
                                NavigationLink(destination: SlipImageDetailView(slip: slip)) {
                                    HStack(spacing: 15) {
                                        Circle()
                                            .fill(bankColor(for: slip.bankName).opacity(0.15))
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Text(slip.bankName == "ไม่ระบุ" ? "?" : String(slip.bankName.prefix(1)))
                                                    .font(.headline)
                                                    .foregroundStyle(bankColor(for: slip.bankName))
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(slip.bankName == "ไม่ระบุ" ? "รายการใช้จ่าย" : "โอนจาก \(slip.bankName)")
                                                .font(.headline)
                                            Text(slip.scanDate.formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("- \(slip.amount, format: .currency(code: "THB"))")
                                            .font(.body)
                                            .bold()
                                            .foregroundStyle(.primary)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        context.delete(slip)
                                    } label: {
                                        Label("ลบ", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("ประวัติรายจ่าย")
            .searchable(text: $searchText, prompt: "ค้นหายอดเงิน หรือ ธนาคาร...")
        }
    }
    
    private func bankColor(for bank: String) -> Color {
        switch bank {
        case "KBANK": return .green
        case "SCB": return .purple
        case "BBL": return .blue
        case "KTB": return .cyan
        case "BAY": return .yellow
        case "TTB": return .orange
        case "ออมสิน": return .pink
        default: return .gray
        }
    }
}

// MARK: - คอมโพเนนต์ดึงรูป Thumbnail อัตโนมัติ (ใส่ไว้ท้ายไฟล์ HistoryView ได้เลย)
struct SlipThumbnailView: View {
    let assetIdentifier: String
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .onAppear {
            fetchImage()
        }
    }
    
    private func fetchImage() {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
        guard let asset = fetchResult.firstObject else { return }
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: options) { result, _ in
            DispatchQueue.main.async {
                self.image = result
            }
        }
    }
}
