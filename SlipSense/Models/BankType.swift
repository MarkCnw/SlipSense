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
    case kkp = "KKP"
    case baac = "BAAC"
    case ghb = "GHB"
    case cimb = "CIMB"
    case uob = "UOB"
    case tisco = "TISCO"
    case lhb = "LH Bank"
    case icbc = "ICBC"
    case tcrb = "ไทยเครดิต"
    case promptpay = "PromptPay"
    case truemoney = "TrueMoney"
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
        case .kkp: return "ธนาคารเกียรตินาคินภัทร"
        case .baac: return "ธนาคารเพื่อการเกษตรและสหกรณ์การเกษตร"
        case .ghb: return "ธนาคารอาคารสงเคราะห์"
        case .cimb: return "ธนาคารซีไอเอ็มบี ไทย"
        case .uob: return "ธนาคารยูโอบี"
        case .tisco: return "ธนาคารทิสโก้"
        case .lhb: return "ธนาคารแลนด์ แอนด์ เฮ้าส์"
        case .icbc: return "ธนาคารไอซีบีซี (ไทย)"
        case .tcrb: return "ธนาคารไทยเครดิต"
        case .promptpay: return "พร้อมเพย์"
        case .truemoney: return "ทรูมันนี่ วอลเล็ท"
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
        case .kkp: return "เกียรตินาคิน"
        case .baac: return "ธ.ก.ส."
        case .ghb: return "ธอส."
        case .cimb: return "CIMB"
        case .uob: return "UOB"
        case .tisco: return "ทิสโก้"
        case .lhb: return "LH Bank"
        case .icbc: return "ICBC"
        case .tcrb: return "ไทยเครดิต"
        case .promptpay: return "พร้อมเพย์"
        case .truemoney: return "TrueMoney"
        case .unknown: return "อื่นๆ"
        }
    }
    
    // ชื่อ Asset รูปภาพโลโก้
    var logoName: String {
        switch self {
        case .all: return "all"
        case .kbank: return "bank_kbank"
        case .scb: return "bank_scb"
        case .bbl: return "bank_bbl"
        case .ktb: return "bank_ktb"
        case .bay: return "bank_bay"
        case .ttb: return "bank_ttb"
        case .gsb: return "bank_gsb"
        case .kkp: return "bank_kkp"
        case .baac: return "bank_baac"
        case .ghb: return "bank_ghb"
        case .cimb: return "bank_cimb"
        case .uob: return "bank_uob"
        case .tisco: return "bank_tisco"
        case .lhb: return "bank_lhb"
        case .icbc: return "bank_icbc"
        case .tcrb: return "bank_tcrb"
        case .promptpay: return "bank_promptpay"
        case .truemoney: return "bank_truemoney"
        default: return "unknown"
        }
    }
}
