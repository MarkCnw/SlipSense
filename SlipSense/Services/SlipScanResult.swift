import Foundation

enum SlipScanStatus: Equatable {
    case saved
    case skippedDuplicate
    case skippedSelfTransferCrossBank
    case skippedNoAmount
    case skippedNoOCRText
    case failed(String)
}

struct SlipScanResult: Equatable {
    let assetIdentifier: String
    let status: SlipScanStatus
    let amount: Double?
    let bankName: String?
    let memo: String?
}
