import Foundation


struct SlipParserService {
    
    // MARK: - 👔 ฟังก์ชันหัวหน้างาน (รับข้อความ แล้วจ่ายงานให้ลูกน้อง)
    func parseSlipData(from text: String) -> (amount: Double?, bank: String) {
        let amountStr = extractAmount(from: text)
        let amount = Double(amountStr?.replacingOccurrences(of: ",", with: "") ?? "")
        let bank = detectBank(from: text)
        return (amount, bank)
    }

    // MARK: - 🕵️‍♂️ ลูกน้องคนที่ 1: หายอดเงิน
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

    // MARK: - 🕵️‍♂️ ลูกน้องคนที่ 2: หาชื่อธนาคาร (อัปเกรด AI ป้องกันการแย่งซีน)
    private func detectBank(from text: String) -> String {
        let lowerText = text.lowercased().replacingOccurrences(of: " ", with: "")
        
        // 🚀 สเต็ปที่ 1: ดักจับจาก "ชื่อแอป" หรือ "หัวสลิป" ก่อน! (แม่นยำที่สุด)
        if lowerText.contains("mymo") { return "ออมสิน" }
        if lowerText.contains("kplus") || lowerText.contains("k-plus") { return "KBANK" }
        if lowerText.contains("scbeasy") { return "SCB" }
        if lowerText.contains("krungthainext") { return "KTB" }
        if lowerText.contains("kma") || lowerText.contains("krungsriapp") { return "BAY" }
        if lowerText.contains("bualuang") || lowerText.contains("mbanking") { return "BBL" }
        if lowerText.contains("ttbtouch") { return "TTB" }
        if lowerText.contains("paotang") || lowerText.contains("เป๋าตัง") { return "KTB" }
        
        // 🚀 สเต็ปที่ 2: ถ้าไม่เจอชื่อแอป ให้หาจาก "ชื่อธนาคาร"
        // ─── ธนาคารหลัก (Big 7) ───
        if lowerText.contains("ออมสิน") || lowerText.contains("gsb") { return "ออมสิน" }
        if lowerText.contains("kbank") || lowerText.contains("กสิกร") || lowerText.contains("kasikorn") { return "KBANK" }
        if lowerText.contains("scb") || lowerText.contains("ไทยพาณิชย์") || lowerText.contains("ไทยพาณิช") { return "SCB" }
        if lowerText.contains("bbl") || lowerText.contains("กรุงเทพ") || lowerText.contains("bangkokbank") { return "BBL" }
        if lowerText.contains("ktb") || lowerText.contains("กรุงไทย") || lowerText.contains("krungthai") { return "KTB" }
        if lowerText.contains("krungsri") || lowerText.contains("กรุงศรี") || lowerText.contains("ayudhya") || lowerText.contains("อยุธยา") { return "BAY" }
        if lowerText.contains("ttb") || lowerText.contains("tto") || lowerText.contains("ทหารไทย") || lowerText.contains("ธนชาต") || lowerText.contains("ทีทีบี") || lowerText.contains("tmb") || lowerText.contains("thanachart") { return "TTB" }
        
        // ─── ธนาคารรอง ───
        if lowerText.contains("เกียรตินาคิน") || lowerText.contains("kkp") { return "KKP" }
        if lowerText.contains("ธ.ก.ส") || lowerText.contains("ธกส") || lowerText.contains("baac") || lowerText.contains("การเกษตร") { return "BAAC" }
        if lowerText.contains("อาคารสงเคราะห์") || lowerText.contains("ธอส") || lowerText.contains("ghb") { return "GHB" }
        if lowerText.contains("ซีไอเอ็มบี") || lowerText.contains("cimb") { return "CIMB" }
        if lowerText.contains("ยูโอบี") || lowerText.contains("uob") { return "UOB" }
        if lowerText.contains("ทิสโก้") || lowerText.contains("ทิสโก") || lowerText.contains("tisco") { return "TISCO" }
        if lowerText.contains("แลนด์แอนด์เฮ้าส์") || lowerText.contains("lhbank") || lowerText.contains("แลนด์") { return "LH Bank" }
        if lowerText.contains("ไอซีบีซี") || lowerText.contains("icbc") { return "ICBC" }
        if lowerText.contains("ไทยเครดิต") || lowerText.contains("thaicredit") { return "ไทยเครดิต" }
        if lowerText.contains("พร้อมเพย์") || lowerText.contains("promptpay") { return "PromptPay" }
        
        return "ไม่ระบุ"
    }
}
