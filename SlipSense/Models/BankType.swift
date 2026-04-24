import SwiftUI

enum BankType: String, CaseIterable {
    case all = "ทั้งหมด"
    case kbank = "KBANK"
    case scb = "SCB"
    case bbl = "BBL"
    case ktb = "KTB"
    case bay = "BAY"
    case ttb = "TTB"
    case gsb = "ออมสิน"
    case unknown = "ไม่ระบุ"
    
    // ชื่อภาษาไทยแบบเต็ม (ใช้โชว์ใน List)
    var thaiName: String {
        switch self {
        case .all: return "ทั้งหมด"
        case .kbank: return "ธนาคารกสิกรไทย"
        case .scb: return "ธนาคารไทยพาณิชย์"
        case .bbl: return "ธนาคารกรุงเทพ"
        case .ktb: return "ธนาคารกรุงไทย"
        case .bay: return "ธนาคารกรุงศรีอยุธยา"
        case .ttb: return "ธนาคารทีทีบี"
        case .gsb: return "ธนาคารออมสิน"
        case .unknown: return "ไม่ระบุธนาคาร"
        }
    }
    
    // ชื่อภาษาไทยแบบสั้น (ใช้โชว์ใต้โลโก้)
    var shortName: String {
        switch self {
        case .all: return "ทั้งหมด"
        case .kbank: return "กสิกรไทย"
        case .scb: return "ไทยพาณิชย์"
        case .bbl: return "กรุงเทพ"
        case .ktb: return "กรุงไทย"
        case .bay: return "กรุงศรี"
        case .ttb: return "TTB"
        case .gsb: return "ออมสิน"
        case .unknown: return "อื่นๆ"
        }
    }
    
    // ชื่อ Asset รูปภาพโลโก้
    var logoName: String {
        switch self {
        case .all: return "all"
        case .kbank: return "kbank"
        case .scb: return "scb"
        case .bbl: return "bbl"
        case .ktb: return "ktb"
        case .bay: return "bay"
        case .ttb: return "ttb"
        case .gsb: return "gsb"
        default: return "unknown"
        }
    }
}
