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
                            .tint(.orange)
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
    
    // MARK: - 🚀 ระบบ AI สแกน (อัปเกรดอ่านชื่อธนาคาร)
    private func startBatchScan() {
        isBatchScanning = true
        scannedCount = 0
        let assetsToScan = self.assets
        
        Task.detached(priority: .userInitiated) {
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = true
            
            for asset in assetsToScan {
                let assetID = asset.localIdentifier
                
                let isDuplicate = await MainActor.run {
                    let descriptor = FetchDescriptor<SlipRecord>(predicate: #Predicate { $0.assetIdentifier == assetID })
                    let existing = try? self.context.fetch(descriptor)
                    return !(existing?.isEmpty ?? true)
                }
                
                if isDuplicate {
                    await MainActor.run { self.scannedCount += 1 }
                    continue
                }
                
                manager.requestImage(for: asset, targetSize: CGSize(width: 800, height: 800), contentMode: .aspectFit, options: options) { result, _ in
                    if let image = result {
                        if let extractedText = self.performOCR(on: image) {
                            if let amountStr = self.extractAmount(from: extractedText),
                               let amount = Double(amountStr.replacingOccurrences(of: ",", with: "")) {
                                
                                // 💡 ตรวจจับชื่อธนาคารจากข้อความที่ AI อ่านได้
                                let detectedBank = self.detectBank(from: extractedText)
                                let extractedMemo = self.extractMemo(from: extractedText) // 💡 ดึงข้อความ Memo
                                
                                Task { @MainActor in
                                    let newRecord = SlipRecord(
                                        amount: amount,
                                        scanDate: asset.creationDate ?? Date(),
                                        assetIdentifier: assetID,    // 💡 ย้าย assetIdentifier มาไว้ตรงนี้ (ก่อน memo)
                                        bankName: detectedBank,
                                        memo: extractedMemo          // 💡 ย้าย memo มาไว้ล่างสุด
                                    )
                                    self.context.insert(newRecord)
                                    try? self.context.save()
                                }
                            }
                        }
                    }
                }
                
                await MainActor.run {
                    self.scannedCount += 1
                }
            }
            
            await MainActor.run {
                self.isBatchScanning = false
                print("✅ สแกนและแยกหมวดหมู่ธนาคารเสร็จสมบูรณ์!")
            }
        }
    }
    
    // MARK: - Helper Functions (OCR)
    // MARK: - 🚀 ฟังก์ชันปรับแต่งภาพ (เคลียร์ลายน้ำ เร่งสีตัวอักษร)
        private func preprocessImage(image: UIImage) -> CGImage? {
            // แปลงภาพให้อยู่ในรูปแบบที่ CoreImage จัดการได้
            guard let ciImage = CIImage(image: image) else { return image.cgImage }
            
            // ใส่ฟิลเตอร์ ขาว-ดำ และ เร่งความคมชัด (Contrast)
            let filter = CIFilter(name: "CIColorControls")!
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(0.0, forKey: kCIInputSaturationKey) // ลดสีเป็น 0 (ภาพขาวดำ)
            filter.setValue(1.8, forKey: kCIInputContrastKey)   // เร่งความคมชัด 1.8 เท่า (ให้ตัวอักษรเด้งขึ้นมา)
            filter.setValue(0.1, forKey: kCIInputBrightnessKey) // ปรับสว่างขึ้นนิดหน่อย
            
            // เรนเดอร์ภาพออกมาใหม่
            let context = CIContext(options: nil)
            if let output = filter.outputImage,
               let cgImage = context.createCGImage(output, from: output.extent) {
                return cgImage
            }
            
            return image.cgImage // ถ้าแปลงล้มเหลว ให้ใช้รูปต้นฉบับ
        }

        // MARK: - Helper Functions (OCR)
    // MARK: - Helper Functions (OCR ท่าไม้ตาย สแกน 2 รอบ)
        private func performOCR(on image: UIImage) -> String? {
            var combinedText = ""
            
            let request = VNRecognizeTextRequest { request, _ in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                // ดึงข้อความมาต่อกันด้วยเว้นวรรค
                let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
                combinedText += recognizedStrings.joined(separator: " ") + " "
            }
            
            request.recognitionLanguages = ["th-TH", "en-US"]
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            
            // 🚀 รอบที่ 1: สแกนจากรูปภาพสีต้นฉบับ
            if let originalCG = image.cgImage {
                let handler1 = VNImageRequestHandler(cgImage: originalCG, options: [:])
                try? handler1.perform([request])
            }
            
            // 🚀 รอบที่ 2: สแกนจากรูปภาพที่ล้างลายน้ำแล้ว (ขาวดำ)
            if let processedCG = preprocessImage(image: image) {
                let handler2 = VNImageRequestHandler(cgImage: processedCG, options: [:])
                try? handler2.perform([request])
            }
            
            // คืนค่าข้อความทั้งหมด (ทั้ง 2 รอบรวมกัน) ส่งไปเก็บเป็น Memo
            return combinedText
        }
        
        
    // MARK: - 💡 ดึงข้อความทั้งหมดเพื่อทำระบบ Full-Text Search
        private func extractMemo(from text: String) -> String {
            // กวาดข้อความทุกบรรทัดที่ AI อ่านได้ มาต่อกันเป็นบรรทัดเดียว
            // เพื่อเป็น "คีย์เวิร์ดซ่อน" ให้ระบบ Search ทำงานได้คลุมทุกคำบนสลิป!
            return text.replacingOccurrences(of: "\n", with: " ")
        }
    
    // 💡 ฟังก์ชันใหม่: แยกชื่อธนาคารจากข้อความบนสลิป
    private func detectBank(from text: String) -> String {
        let lowerText = text.lowercased().replacingOccurrences(of: " ", with: "")
        
        if lowerText.contains("kbank") || lowerText.contains("กสิกร") { return "KBANK" }
        if lowerText.contains("scb") || lowerText.contains("ไทยพาณิชย์") { return "SCB" }
        if lowerText.contains("bbl") || lowerText.contains("กรุงเทพ") { return "BBL" }
        if lowerText.contains("ktb") || lowerText.contains("กรุงไทย") { return "KTB" }
        if lowerText.contains("krungsri") || lowerText.contains("กรุงศรี") || lowerText.contains("bay") { return "BAY" }
        if lowerText.contains("ttb") || lowerText.contains("ทหารไทยธนชาต") { return "TTB" }
        if lowerText.contains("gsb") || lowerText.contains("ออมสิน") || lowerText.contains("mymo") { return "ออมสิน" }
        
        return "ไม่ระบุ"
    }
    
    private func extractAmount(from text: String) -> String? {
        let lines = text.components(separatedBy: "\n")
        let pattern = #"\d{1,3}(?:,\d{3})*\.\d{2}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        
        let keywords = ["จำนวนเงิน", "ยอดโอน", "amount", "total amount", "thb", "โอนเงินสำเร็จ", "ยอดเงิน"]
        let blacklist = ["ยอดเงินคงเหลือ", "available balance", "balance", "คงเหลือ"]

        for (index, line) in lines.enumerated() {
            let lowerLine = line.lowercased().replacingOccurrences(of: " ", with: "")
            
            if blacklist.contains(where: { lowerLine.contains($0) }) { continue }
            
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

// MARK: - Thumbnail Component
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
                Color.gray.opacity(0.2)
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
