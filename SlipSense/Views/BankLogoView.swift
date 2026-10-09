import SwiftUI

struct BankLogoView: View {
    let bankName: String
    var size: CGFloat = 40
    
    var body: some View {
        if let assetName = BankLogoHelper.assetName(for: bankName) {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            // Fallback สำหรับกรณีไม่ระบุธนาคาร หรือตรวจจับไม่ได้
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                    .fill(BankLogoHelper.fallbackColor(for: bankName).gradient)
                    .frame(width: size, height: size)
                
                Image(systemName: BankLogoHelper.fallbackSystemImage(for: bankName))
                    .font(.system(size: size * 0.45, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
    }
}

enum BankLogoHelper {
    static func assetName(for rawBank: String) -> String? {
        let name = rawBank.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !name.isEmpty, name != "ไม่ระบุ", name != "unknown" else { return nil }
        
        // 1. ธนาคารหลักยอดนิยม
        if name.contains("kbank") || name.contains("กสิกร") || name.contains("kasikorn") || name.contains("kplus") || name.contains("k-plus") {
            return "bank_kbank"
        }
        if name.contains("scb") || name.contains("ไทยพาณิชย์") || name.contains("ไทยพาณิช") || name.contains("scbeasy") {
            return "bank_scb"
        }
        if name.contains("bbl") || name.contains("กรุงเทพ") || name.contains("bangkokbank") || name.contains("bualuang") {
            return "bank_bbl"
        }
        if name.contains("ktb") || name.contains("กรุงไทย") || name.contains("krungthai") || name.contains("เป๋าตัง") || name.contains("paotang") {
            return "bank_ktb"
        }
        if name.contains("bay") || name.contains("กรุงศรี") || name.contains("krungsri") || name.contains("ayudhya") || name.contains("kma") {
            return "bank_bay"
        }
        if name.contains("ttb") || name.contains("ทหารไทย") || name.contains("ธนชาต") || name.contains("ทีทีบี") || name.contains("tmb") || name.contains("thanachart") || name.contains("ttbtouch") {
            return "bank_ttb"
        }
        if name.contains("gsb") || name.contains("ออมสิน") || name.contains("mymo") {
            return "bank_gsb"
        }
        
        // 2. ธนาคารพาณิชย์และเฉพาะกิจอื่นๆ
        if name.contains("kkp") || name.contains("เกียรตินาคิน") {
            return "bank_kkp"
        }
        if name.contains("baac") || name.contains("ธ.ก.ส") || name.contains("ธกส") || name.contains("เกษตร") {
            return "bank_baac"
        }
        if name.contains("ghb") || name.contains("ธอส") || name.contains("อาคารสงเคราะห์") {
            return "bank_ghb"
        }
        if name.contains("cimb") || name.contains("ซีไอเอ็มบี") {
            return "bank_cimb"
        }
        if name.contains("uob") || name.contains("ยูโอบี") {
            return "bank_uob"
        }
        if name.contains("tisco") || name.contains("ทิสโก้") || name.contains("ทิสโก") {
            return "bank_tisco"
        }
        if name.contains("lhb") || name.contains("แลนด์") || name.contains("lh bank") || name.contains("land and houses") {
            return "bank_lhb"
        }
        if name.contains("icbc") || name.contains("ไอซีบีซี") {
            return "bank_icbc"
        }
        if name.contains("tcrb") || name.contains("ไทยเครดิต") || name.contains("thaicredit") {
            return "bank_tcrb"
        }
        if name.contains("citi") || name.contains("ซิตี้") {
            return "bank_citi"
        }
        if name.contains("hsbc") {
            return "bank_hsbc"
        }
        if name.contains("ibank") || name.contains("อิสลาม") {
            return "bank_ibank"
        }
        
        // 3. กระเป๋าเงินดิจิทัล & พร้อมเพย์
        if name.contains("promptpay") || name.contains("พร้อมเพย์") {
            return "bank_promptpay"
        }
        if name.contains("truemoney") || name.contains("ทรูมันนี่") || name.contains("true money") {
            return "bank_truemoney"
        }
        
        return nil
    }
    
    static func fallbackSystemImage(for rawBank: String) -> String {
        let name = rawBank.lowercased()
        if name.contains("พร้อมเพย์") || name.contains("promptpay") {
            return "arrow.2.squarepath"
        }
        return "building.columns.fill"
    }
    
    static func fallbackColor(for rawBank: String) -> Color {
        let name = rawBank.lowercased()
        if name.contains("พร้อมเพย์") || name.contains("promptpay") {
            return Color(uiColor: .systemBlue)
        }
        return Color(uiColor: .systemGray2)
    }
}
