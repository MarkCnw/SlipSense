import Foundation

enum SlipSelfTransferGuard {
    static func shouldSkipSelfTransferCrossBank(from rawText: String) -> Bool {
        let lines = rawText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let parties = extractPartiesByLineScan(from: lines)
        guard parties.count >= 2 else { return false }
        
        let p1 = parties[0]
        let p2 = parties[1]
        
        // 🌟 แก้ไข: ตัดเงื่อนไขเช็คชื่อธนาคารทิ้ง ขอแค่คนโอนและคนรับเป็นคนเดียวกันก็พอ
        return isLikelySamePerson(p1.name, p2.name)
    }
    
    /// Debug: ดู parties ที่ extract ได้ (ใช้ตอน debug เท่านั้น)
    static func debugExtractParties(from rawText: String) -> [(name: String, bank: String, account: String)] {
        let lines = rawText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        return extractPartiesByLineScan(from: lines).map { (name: $0.name, bank: $0.bank, account: $0.account) }
    }
}

private extension SlipSelfTransferGuard {
    struct Party {
        let name: String
        let bank: String
        let account: String
    }
    
    static func extractPartiesByLineScan(from lines: [String]) -> [Party] {
        var result: [Party] = []
        
        // 📍 Pre-process: แยกบรรทัดที่มีชื่อธนาคารนำหน้าชื่อคน
        var processedLines: [String] = []
        let knownBankSuffixes = ["next", "touch", "easy", "plus", "bank", "mymo"]
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let tokens = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            if tokens.count >= 2 {
                let firstToken = tokens[0]
                let rest = tokens.dropFirst().joined(separator: " ")
                
                if !normalizeBank(firstToken).isEmpty && isLikelyNameLine(rest) && !knownBankSuffixes.contains(rest.lowercased()) {
                    processedLines.append(firstToken)
                    processedLines.append(rest)
                    continue
                }
            }
            processedLines.append(trimmed)
        }
        
        var i = 0
        while i < processedLines.count - 1 {
            let l1 = processedLines[i]
            
            // ถ้านี่คือบรรทัดที่น่าจะเป็น "ชื่อคน"
            if isLikelyNameLine(l1) {
                let l2 = processedLines[i + 1]
                
                // เคสที่ 1: ชื่อธนาคารและเลขบัญชี อยู่ในบรรทัดเดียวกัน
                if isBankLine(l2) && (l2.lowercased().contains("x") || l2.contains("*")) {
                    result.append(Party(name: l1, bank: l2, account: l2))
                    i += 2
                    continue
                }
                
                if i < processedLines.count - 2 {
                    let l3 = processedLines[i + 2]
                    
                    // เคสที่ 2: ชื่อ -> ธนาคาร -> เลขบัญชี
                    if isBankLine(l2) && isMaskedAccountLine(l3) {
                        result.append(Party(name: l1, bank: l2, account: l3))
                        i += 3
                        continue
                    }
                    
                    // เคสที่ 3: ชื่อ -> เลขบัญชี -> ธนาคาร
                    if isMaskedAccountLine(l2) && isBankLine(l3) {
                        result.append(Party(name: l1, bank: l3, account: l2))
                        i += 3
                        continue
                    }
                }
                
                // เคสที่ 4: ชื่อ -> เลขบัญชี
                if isMaskedAccountLine(l2) {
                    result.append(Party(name: l1, bank: "", account: l2))
                    i += 2
                    continue
                }
            }
            i += 1
        }
        
        // ระบบลบข้อมูลซ้ำ (Dedup)
        var dedup: [Party] = []
        for p in result {
            if let last = dedup.last,
               normalizeName(last.name) == normalizeName(p.name),
               normalizeBank(last.bank) == normalizeBank(p.bank) {
                continue
            }
            dedup.append(p)
        }
        return dedup
    }
    
    static func isLikelyNameLine(_ s: String) -> Bool {
        let blocked = ["โอนเงินสำเร็จ", "เลขที่รายการ", "จำนวน", "ค่าธรรมเนียม", "วันที่ทำรายการ", "สแกนตรวจสอบสลิป", "จาก", "ไปยัง", "ถึง", "baht", "บาท", "qr code", "รหัสอ้างอิง", "สแกน", "รายการโอน"]
        if blocked.contains(where: { s.lowercased().contains($0.lowercased()) }) { return false }
        if !normalizeBank(s).isEmpty { return false }
        if compact(s).range(of: #"\d"#, options: .regularExpression) != nil { return false }
        return compact(s).count >= 4
    }
    
    static func isBankLine(_ s: String) -> Bool {
        !normalizeBank(s).isEmpty
    }
    
    static func isMaskedAccountLine(_ s: String) -> Bool {
        let t = compact(s)
        guard t.count >= 6 else { return false }
        guard t.range(of: #"\d"#, options: .regularExpression) != nil else { return false }
        return t.range(of: #"^[x*0-9\-.]+$"#, options: .regularExpression) != nil
    }
    
    static func normalizeBank(_ raw: String) -> String {
        let t = compact(raw)
        if t.contains("ออมสิน") || t.contains("gsb") || t.contains("mymo") { return "GSB" }
        if t.contains("กสิกร") || t.contains("kbank") || t.contains("kplus") || t.contains("k-plus") || t.contains("kasikorn") { return "KBANK" }
        if t.contains("ไทยพาณิชย์") || t.contains("ไทยพาณิช") || t.contains("scbeasy") || t.contains("scb") { return "SCB" }
        if t.contains("กรุงเทพ") || t.contains("bangkokbank") || t.contains("bbl") || t.contains("bualuang") { return "BBL" }
        if t.contains("กรุงไทย") || t.contains("krungthai") || t.contains("ktb") || t.contains("เป๋าตัง") || t.contains("paotang") { return "KTB" }
        if t.contains("กรุงศรี") || t.contains("อยุธยา") || t.contains("krungsri") || t.contains("ayudhya") || t.contains("bay") || t.contains("kma") { return "BAY" }
        if t.contains("ทหารไทย") || t.contains("ธนชาต") || t.contains("ทีทีบี") || t.contains("ttb") || t.contains("tto") || t.contains("tmb") || t.contains("thanachart") { return "TTB" }
        if t.contains("เกียรตินาคิน") || t.contains("kkp") { return "KKP" }
        if t.contains("ธ.ก.ส") || t.contains("ธกส") || t.contains("baac") || t.contains("การเกษตร") { return "BAAC" }
        if t.contains("อาคารสงเคราะห์") || t.contains("ธอส") || t.contains("ghb") || t.contains("ghbank") { return "GHB" }
        if t.contains("ซีไอเอ็มบี") || t.contains("cimb") { return "CIMB" }
        if t.contains("ยูโอบี") || t.contains("uob") { return "UOB" }
        if t.contains("ทิสโก้") || t.contains("ทิสโก") || t.contains("tisco") { return "TISCO" }
        if t.contains("แลนด์แอนด์เฮ้าส์") || t.contains("lhbank") || t.contains("แลนด์") { return "LHBANK" }
        if t.contains("ไอซีบีซี") || t.contains("icbc") { return "ICBC" }
        if t.contains("ไทยเครดิต") || t.contains("thaicredit") { return "THAICREDIT" }
        if t.contains("ส่งออก") || t.contains("exim") { return "EXIM" }
        if t.contains("พร้อมเพย์") || t.contains("promptpay") { return "PROMPTPAY" }
        return ""
    }
    
    static func normalizeName(_ s: String) -> String {
        s.lowercased()
            .replacingOccurrences(of: #"[^a-zA-Zก-๙0-9]"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: "นาย", with: "")
            .replacingOccurrences(of: "นางสาว", with: "")
            .replacingOccurrences(of: "นาง", with: "")
            .replacingOccurrences(of: "ดช", with: "")
            .replacingOccurrences(of: "ดญ", with: "")
            .replacingOccurrences(of: "mr", with: "")
            .replacingOccurrences(of: "mrs", with: "")
            .replacingOccurrences(of: "ms", with: "")
    }
    
    static func isLikelySamePerson(_ lhs: String, _ rhs: String) -> Bool {
        let a = normalizeName(lhs)
        let b = normalizeName(rhs)
        guard !a.isEmpty, !b.isEmpty else { return false }
        
        let savedName = UserDefaults.standard.string(forKey: "userRealName") ?? ""
        let myKeywords = savedName.lowercased()
            .replacingOccurrences(of: "|", with: " ")
            .components(separatedBy: .whitespaces)
            .map { normalizeName($0) }
            .filter { $0.count >= 3 }
        
        if !myKeywords.isEmpty {
            let senderIsMe = myKeywords.contains { a.contains($0) }
            let receiverIsMe = myKeywords.contains { b.contains($0) }
            if senderIsMe && receiverIsMe { return true }
        }
        
        if a == b { return true }
        if commonPrefixLength(a, b) >= 5 { return true }
        
        let ta = firstNameToken(from: lhs)
        let tb = firstNameToken(from: rhs)
        if let ta = ta, let tb = tb, ta.count >= 3, tb.count >= 3, ta == tb {
            return true
        }
        return false
    }
    
    static func firstNameToken(from raw: String) -> String? {
        let titles = ["นายแพทย์", "นาย", "นางสาว", "นาง", "ด.ช.", "ด.ญ.", "ดช", "ดญ", "mr.", "mrs.", "ms.", "mr", "mrs", "ms", "น.ส.", "นส", "นพ.", "นพ"]
        var name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        
        for t in titles {
            if name.lowercased().hasPrefix(t.lowercased()) {
                name = String(name.dropFirst(t.count)).trimmingCharacters(in: .whitespaces)
                break
            }
        }
        
        let cleaned = name
            .replacingOccurrences(of: #"[^a-zA-Zก-๙ \s]"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let tokens = cleaned.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        
        guard let first = tokens.first else { return nil }
        return normalizeName(first)
    }
    
    static func commonPrefixLength(_ a: String, _ b: String) -> Int {
        let aa = Array(a.unicodeScalars), bb = Array(b.unicodeScalars)
        let n = min(aa.count, bb.count)
        var i = 0
        while i < n, aa[i] == bb[i] { i += 1 }
        return i
    }
    
    static func compact(_ s: String) -> String {
        s.lowercased().replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
    }
}
