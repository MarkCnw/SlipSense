import SwiftUI
import Photos
import Vision

struct SlipDetailView: View {
    let asset: PHAsset
    
    @State private var fullImage: UIImage?
    @State private var scannedText: String = ""
    @State private var isScanning: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. โชว์รูปสลิป
                if let image = fullImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else {
                    ProgressView("กำลังโหลดรูปภาพ...")
                        .frame(height: 400)
                }
                
                Divider()
                
                // 2. โชว์ข้อความ
                VStack(alignment: .leading, spacing: 10) {
                    Text("ข้อมูลในสลิป:")
                        .font(.headline)
                    
                    if isScanning {
                        ProgressView("AI กำลังสแกนข้อความ...")
                    } else {
                        // 💡 ไฮไลต์เด็ด: โชว์กล่องยอดเงินถ้าดึงตัวเลขได้สำเร็จ!
                        if let amount = extractAmount(from: scannedText) {
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
                        
                        Text(scannedText.isEmpty ? "ไม่พบข้อความ" : scannedText)
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
        .onAppear {
            loadFullImageAndScan()
        }
    }
    
    // MARK: - Logic โหลดรูปและสแกน
    private func loadFullImageAndScan() {
        Task.detached(priority: .userInitiated) {
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = true
            
            manager.requestImage(for: asset, targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFit, options: options) { result, _ in
                guard let image = result else { return }
                
                Task { @MainActor in
                    self.fullImage = image
                    self.isScanning = true
                }
                
                self.performOCR(on: image)
            }
        }
    }
    
    // MARK: - AI สแกนข้อความ
    private func performOCR(on image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                Task { @MainActor in self.isScanning = false }
                return
            }
            
            let extractedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            
            Task { @MainActor in
                self.scannedText = extractedText
                self.isScanning = false
            }
        }
        
        request.recognitionLanguages = ["th-TH", "en-US"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
    
    // MARK: - 💡 ฟังก์ชันใหม่: ดึงยอดเงิน (Regex)
    private func extractAmount(from text: String) -> String? {
        let pattern = #"\d{1,3}(?:,\d{3})*\.\d{2}"# // มองหาตัวเลขทศนิยม 2 ตำแหน่ง
        
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            
            var maxAmount = 0.0
            var bestMatchStr: String? = nil
            
            for match in results {
                let matchStr = nsString.substring(with: match.range)
                let numberStr = matchStr.replacingOccurrences(of: ",", with: "")
                if let value = Double(numberStr), value > maxAmount {
                    maxAmount = value
                    bestMatchStr = matchStr
                }
            }
            return bestMatchStr
            
        } catch {
            return nil
        }
    }
}
