import SwiftUI
import Photos
import Vision
import SwiftData

struct AlbumDetailView: View {
    let album: AlbumInfo
    var photoService: PhotoService
    
    @State private var slipParserService = SlipParserService()
    @State private var slipRecordService = SlipRecordService()
    
    @Environment(\.modelContext) private var context
    @State private var assets: [PHAsset] = []
    
    @State private var isBatchScanning = false
    @State private var scannedCount = 0
    @State private var skippedSelfTransferCount = 0
    
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
                        
                        if skippedSelfTransferCount > 0 {
                            Text("ข้ามโอนให้ตัวเองต่างธนาคาร: \(skippedSelfTransferCount)")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.9))
                        }
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
            assets = photoService.fetchPhotos(in: album.collection)
        }
    }
    
    // MARK: - 🚀 ระบบ AI สแกน
    private func startBatchScan() {
        isBatchScanning = true
        scannedCount = 0
        skippedSelfTransferCount = 0
        let assetsToScan = self.assets
        
        Task.detached(priority: .userInitiated) {
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = true
            
            for asset in assetsToScan {
                let assetID = asset.localIdentifier
                
                // กันสลิปซ้ำ
                let isDuplicate = await MainActor.run {
                    let descriptor = FetchDescriptor<SlipRecord>(predicate: #Predicate { $0.assetIdentifier == assetID })
                    let existing = try? self.context.fetch(descriptor)
                    return !(existing?.isEmpty ?? true)
                }
                
                if isDuplicate {
                    await MainActor.run { self.scannedCount += 1 }
                    continue
                }
                
                manager.requestImage(
                    for: asset,
                    targetSize: CGSize(width: 800, height: 800),
                    contentMode: .aspectFit,
                    options: options
                ) { result, _ in
                    guard let image = result else { return }
                    guard let extractedText = self.performOCR(on: image), !extractedText.isEmpty else { return }
                    print("----- OCR START -----")
                    print(extractedText)
                    print("----- OCR END -----")
                    print("selfTransfer? \(SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: extractedText))")
                    
                    // ✅ ด่านที่ 1: กันก่อน parse
                    if SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: extractedText) {
                        Task { @MainActor in
                            self.skippedSelfTransferCount += 1
                            print("⛔️ ข้ามสลิปโอนให้ตัวเองต่างธนาคาร (pre-check): \(assetID)")
                        }
                        return
                    }
                    print("Guard version: REGEX_PARTY_V1")
                    print("selfTransfer? \(SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: extractedText))")
                    
                    let parseResult = self.slipParserService.parseSlipData(from: extractedText)
                    guard let amount = parseResult.amount else { return }
                    
                    let bank = parseResult.bank
                    let memo = self.extractMemo(from: extractedText)
                    
                    Task { @MainActor in
                        // ✅ ด่านที่ 2: กันซ้ำตอนบันทึก (เผื่อหลุด)
                        self.slipRecordService.processScannedSlip(
                            amount: amount,
                            date: asset.creationDate ?? Date(),
                            transID: "",
                            assetIdentifier: assetID,
                            bankName: bank,
                            memo: memo,
                            context: self.context,
                            onSkipped: { reason in
                                if reason.contains("โอนให้ตัวเองต่างธนาคาร") {
                                    self.skippedSelfTransferCount += 1
                                    print("⛔️ \(reason) [\(assetID)]")
                                }
                            }
                        )
                    }
                }
                
                await MainActor.run {
                    self.scannedCount += 1
                }
            }
            
            await MainActor.run {
                self.isBatchScanning = false
                print("✅ สแกนเสร็จ | ข้ามโอนตัวเองต่างธนาคาร: \(self.skippedSelfTransferCount) รายการ")
            }
        }
    }
    
    // MARK: - Helper Functions
    private func preprocessImage(image: UIImage) -> CGImage? {
        guard let ciImage = CIImage(image: image) else { return image.cgImage }
        
        guard let filter = CIFilter(name: "CIColorControls") else { return image.cgImage }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)
        filter.setValue(1.8, forKey: kCIInputContrastKey)
        filter.setValue(0.1, forKey: kCIInputBrightnessKey)
        
        let ciContext = CIContext(options: nil)
        if let output = filter.outputImage,
           let cgImage = ciContext.createCGImage(output, from: output.extent) {
            return cgImage
        }
        
        return image.cgImage
    }

    private func performOCR(on image: UIImage) -> String? {
        var combinedText = ""
        
        let request = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            combinedText += recognizedStrings.joined(separator: "\n") + "\n"
        }
        
        request.recognitionLanguages = ["th-TH", "en-US"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        if let originalCG = image.cgImage {
            let handler1 = VNImageRequestHandler(cgImage: originalCG, options: [:])
            try? handler1.perform([request])
        }
        
        if let processedCG = preprocessImage(image: image) {
            let handler2 = VNImageRequestHandler(cgImage: processedCG, options: [:])
            try? handler2.perform([request])
        }
        
        let cleaned = combinedText.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }
        
    private func extractMemo(from text: String) -> String {
        text.replacingOccurrences(of: "\n", with: " ")
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
            
            manager.requestImage(
                for: asset,
                targetSize: CGSize(width: 300, height: 300),
                contentMode: .aspectFill,
                options: options
            ) { result, _ in
                DispatchQueue.main.async {
                    if let result = result {
                        self.image = result
                    }
                }
            }
        }
    }
}
