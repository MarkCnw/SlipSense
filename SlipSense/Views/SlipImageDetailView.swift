import SwiftUI
import Photos

struct SlipImageDetailView: View {
    let slip: SlipRecord
    
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ส่วนแสดงรูปภาพสลิป
                Group {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                    } else if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("กำลังโหลดรูปภาพ...")
                                .foregroundStyle(.secondary)
                        }
                        .frame(height: 400)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.badge.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundStyle(.tertiary)
                            Text("ไม่พบรูปภาพสลิปในเครื่อง")
                                .foregroundStyle(.secondary)
                        }
                        .frame(height: 400)
                    }
                }
                .padding(.top)
                
                // การ์ดแสดงรายละเอียด
                VStack(spacing: 16) {
                    DetailRow(title: "ธนาคาร", value: slip.bankName)
                    Divider()
                    DetailRow(title: "วันที่และเวลา", value: slip.scanDate.formatted(date: .abbreviated, time: .shortened))
                    Divider()
                    DetailRow(title: "ยอดเงิน", value: slip.amount.formatted(.currency(code: "THB")), isHighlight: true)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("รายละเอียดสลิป")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            loadImageFromDevice()
        }
    }
    
    // ฟังก์ชันดึงรูปภาพจาก Photos ด้วย assetIdentifier
    private func loadImageFromDevice() {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [slip.assetIdentifier], options: nil)
        
        guard let asset = fetchResult.firstObject else {
            isLoading = false
            return
        }
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        // ดึงรูปขนาดเต็ม (MaximumSize) เพื่อให้เห็นตัวหนังสือชัดเจน
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { result, _ in
            DispatchQueue.main.async {
                self.image = result
                self.isLoading = false
            }
        }
    }
}

// คอมโพเนนต์ช่วยวาดแถวรายละเอียดให้สวยงาม
struct DetailRow: View {
    let title: String
    let value: String
    var isHighlight: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(isHighlight ? .bold : .medium)
                .foregroundStyle(isHighlight ? .primary : .primary)
                .font(isHighlight ? .title3 : .body)
        }
    }
}
