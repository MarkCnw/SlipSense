
import SwiftUI
import Photos

struct SlipDetailView: View {
    let asset: PHAsset
    @State private var viewModel = SlipDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1) รูปสลิป
                if let image = viewModel.fullImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else if viewModel.isLoadingImage {
                    ProgressView("กำลังโหลดรูปภาพ...")
                        .frame(height: 400)
                } else {
                    ContentUnavailableView("ไม่พบรูปภาพ", systemImage: "photo")
                        .frame(height: 400)
                }
                
                Divider()
                
                // 2) ข้อความ OCR
                VStack(alignment: .leading, spacing: 10) {
                    Text("ข้อมูลในสลิป:")
                        .font(.headline)
                    
                    if viewModel.isScanningText {
                        ProgressView("AI กำลังสแกนข้อความ...")
                    } else {
                        if let amount = viewModel.extractedAmountText {
                            HStack {
                                Text("ยอดเงินโอน:")
                                    .font(.headline)
                                Spacer()
                                Text("฿ \(amount)")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(.green)
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.bottom, 8)
                        }
                        
                        Text(viewModel.scannedText.isEmpty ? "ไม่พบข้อความ" : viewModel.scannedText)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("รายละเอียดสลิป")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.load(asset: asset)
        }
    }
}
