import UIKit
import Vision

/// Centralized OCR service that consolidates all text-recognition logic.
/// Uses a shared CIContext for image preprocessing to avoid per-call allocation.
final class OCRService: Sendable {
    
    static let shared = OCRService()
    
    // Reuse a single CIContext across all preprocessing calls (thread-safe).
    private let ciContext = CIContext(options: [.useSoftwareRenderer: false])
    
    private init() {}
    
    // MARK: - Public API
    
    /// Perform OCR on both the original and a contrast-enhanced version of the image,
    /// returning the combined recognized text.
    func recognizeText(from image: UIImage) -> String? {
        var combinedText = ""
        
        let request = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let strings = observations.compactMap { $0.topCandidates(1).first?.string }
            combinedText += strings.joined(separator: "\n") + "\n"
        }
        request.recognitionLanguages = ["th-TH", "en-US"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        // Pass 1: Original image
        if let originalCG = image.cgImage {
            try? VNImageRequestHandler(cgImage: originalCG, options: [:]).perform([request])
        }
        
        // Pass 2: Contrast-enhanced image
        if let processedCG = preprocessImage(image) {
            try? VNImageRequestHandler(cgImage: processedCG, options: [:]).perform([request])
        }
        
        return combinedText.isEmpty ? nil : combinedText
    }
    
    /// Perform OCR and return line-separated text (used by SlipDetailView preview).
    func recognizeTextLines(from image: UIImage) -> String? {
        guard let cgImage = image.cgImage else { return nil }
        
        var extractedText = ""
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else { return }
            extractedText = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
        }
        request.recognitionLanguages = ["th-TH", "en-US"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        try? VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
        return extractedText.isEmpty ? nil : extractedText
    }
    
    // MARK: - Private Helpers
    
    /// Desaturate + boost contrast to improve OCR accuracy on slip photos.
    private func preprocessImage(_ image: UIImage) -> CGImage? {
        guard let ciImage = CIImage(image: image) else { return image.cgImage }
        
        guard let filter = CIFilter(name: "CIColorControls") else { return image.cgImage }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)
        filter.setValue(1.8, forKey: kCIInputContrastKey)
        filter.setValue(0.1, forKey: kCIInputBrightnessKey)
        
        guard let output = filter.outputImage else { return image.cgImage }
        return ciContext.createCGImage(output, from: output.extent)
    }
}
