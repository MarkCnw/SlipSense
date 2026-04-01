import SwiftUI
import Photos
import Vision
import SwiftData

struct AlbumDetailView: View {
    let album: AlbumInfo
    var photoManager: PhotoManager
    
    @Environment(\.modelContext) private var context
    
    @State private var assets: [PHAsset] = []
    
    @State private var isBatchScanning = false
    @State private var scannedCount = 0
    
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(assets, id: \.localIdentifier) { asset in
                        NavigationLink(destination: SlipDetailView(asset: asset)) {
                            ThumbnailView(asset: asset)
                                .frame(height: 120)
                                .clipped()
                        }
                    }
                }
            }
            
            if isBatchScanning {
                VStack {
                    Spacer()
                    VStack(spacing: 15) {
                        ProgressView("กำลังสแกนสลิป \(scannedCount) / \(assets.count) รูป...")
                            .tint(.white)
                            .foregroundStyle(.white)
                        
                        ProgressView(value: Double(scannedCount), total: Double(assets.count))
                            .progressViewStyle(.linear)
                            .tint(.green)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(15)
                    .padding()
                }
            }
        }
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    startBatchScan()
                }) {
                    Text("สแกนทั้งหมด")
                        .bold()
                }
                .disabled(isBatchScanning || assets.isEmpty)
            }
        }
        .onAppear {
            assets = photoManager.fetchPhotos(in: album.collection)
        }
    }
    
    // MARK: - 🚀 ระบบ AI สแกนเหมาเข่ง
    private func startBatchScan() {
        isBatchScanning = true
        scannedCount = 0
        
        // 💡 แก้ Error สีเหลือง: ก๊อปปี้ assets ออกมาก่อนเข้า Background Thread!
        let assetsToScan = self.assets
        
        Task.detached(priority: .userInitiated) {
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = true
            
            // 💡 ใช้ assetsToScan แทน self.assets
            for asset in assetsToScan {
                manager.requestImage(for: asset, targetSize: CGSize(width: 800, height: 800), contentMode: .aspectFit, options: options) { result, _ in
                    if let image = result {
                        if let extractedText = self.performOCR(on: image) {
                            if let amountStr = self.extractAmount(from: extractedText),
                               let amount = Double(amountStr.replacingOccurrences(of: ",", with: "")) {
                                
                                Task { @MainActor in
                                    let newRecord = SlipRecord(assetIdentifier: asset.localIdentifier, amount: amount)
                                    self.context.insert(newRecord)
                                }
                            }
                        }
                    }
                }
                
                Task { @MainActor in
                    self.scannedCount += 1
                }
            }
            
            Task { @MainActor in
                self.isBatchScanning = false
                print("✅ สแกนเสร็จสมบูรณ์ และบันทึกลง Database เรียบร้อย!")
            }
        }
    }
    
    // MARK: - Helper Functions
    private func performOCR(on image: UIImage) -> String? {
        guard let cgImage = image.cgImage else { return nil }
        var resultText = ""
        
        let request = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            resultText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
        }
        request.recognitionLanguages = ["th-TH", "en-US"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
        
        return resultText
    }
    
    private func extractAmount(from text: String) -> String? {
        let lines = text.components(separatedBy: "\n")
        let pattern = #"\d{1,3}(?:,\d{3})*\.\d{2}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let keywords = ["จำนวนเงิน", "ยอดเงิน", "amount", "โอนเงินสำเร็จ", "ยอดโอน"]
        
        for (index, line) in lines.enumerated() {
            let lowerLine = line.lowercased().replacingOccurrences(of: " ", with: "")
            if keywords.contains(where: { lowerLine.contains($0) }) {
                if let match = findFirstNumber(in: line, using: regex) { return match }
                if index + 1 < lines.count {
                    if let match = findFirstNumber(in: lines[index + 1], using: regex) { return match }
                }
            }
        }
        
        var maxAmount = 0.0
        var bestMatchStr: String? = nil
        let allMatches = regex.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))
        for match in allMatches {
            let matchStr = (text as NSString).substring(with: match.range)
            let numberStr = matchStr.replacingOccurrences(of: ",", with: "")
            if let value = Double(numberStr), value > maxAmount, value < 100000000 {
                maxAmount = value
                bestMatchStr = matchStr
            }
        }
        return bestMatchStr
    }
    
    private func findFirstNumber(in text: String, using regex: NSRegularExpression) -> String? {
        let nsString = text as NSString
        if let firstMatch = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length)).first {
            return nsString.substring(with: firstMatch.range)
        }
        return nil
    }
}

// MARK: - 💡 แก้ Error สีแดง: ใส่ท่อน ThumbnailView กลับคืนมาแล้วครับ!
struct ThumbnailView: View {
    let asset: PHAsset
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.2) // สีเทาตอนรอโหลดรูป
            }
        }
        .onAppear {
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.isNetworkAccessAllowed = true
            
            manager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: options) { result, _ in
                DispatchQueue.main.async {
                    if let result = result {
                        self.image = result
                    }
                }
            }
        }
    }
}
