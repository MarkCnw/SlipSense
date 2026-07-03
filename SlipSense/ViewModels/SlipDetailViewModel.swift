import Foundation
import Photos
import UIKit

@MainActor
@Observable
final class SlipDetailViewModel {
    var fullImage: UIImage?
    var scannedText: String = ""
    var isLoadingImage: Bool = false
    var isScanningText: Bool = false
    
    private let imageProvider = PhotoImageProvider()
    
    func load(asset: PHAsset) {
        guard !isLoadingImage, !isScanningText else { return }
        
        isLoadingImage = true
        scannedText = ""
        
        Task(priority: .userInitiated) {
            defer { isLoadingImage = false }
            
            guard let image = await imageProvider.requestImage(for: asset) else { return }
            fullImage = image
            
            isScanningText = true
            defer { isScanningText = false }
            
            scannedText = await OCRService.shared
                .recognizeTextLines(from: image) ?? ""
        }
    }
    
    var extractedAmountText: String? {
        extractAmount(from: scannedText)
    }
    
    private func extractAmount(from text: String) -> String? {
        let pattern = #"\d{1,3}(?:,\d{3})*\.\d{2}"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let nsString = text as NSString
        let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        
        var maxAmount = 0.0
        var bestMatch: String?
        
        for match in results {
            let matchStr = nsString.substring(with: match.range)
            let numberStr = matchStr.replacingOccurrences(of: ",", with: "")
            if let value = Double(numberStr), value > maxAmount {
                maxAmount = value
                bestMatch = matchStr
            }
        }
        
        return bestMatch
    }
}
