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
        
        let b1 = normalizeBank(p1.bank)
        let b2 = normalizeBank(p2.bank)
        
        guard !b1.isEmpty, !b2.isEmpty, b1 != b2 else { return false }
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
        var i = 0
        
        while i < lines.count - 1 {
            let l1 = lines[i]
            
            // ถ้านี่คือบรรทัดที่น่าจะเป็น "ชื่อคน"
            if isLikelyNameLine(l1) {
                let l2 = lines[i + 1]
                
                // เคสที่ 1: ชื่อธนาคารและเลขบัญชี อยู่ในบรรทัดเดียวกัน (เช่น "กสิกรไทย xxx-1234")
                if isBankLine(l2) && (l2.lowercased().contains("x") || l2.contains("*")) {
                    result.append(Party(name: l1, bank: l2, account: l2))
                    i += 2
                    continue
                }
                
                // เคสที่ 2: ชื่อ -> ธนาคาร -> เลขบัญชี (เรียงกัน 3 บรรทัดแบบดั้งเดิม)
                if i < lines.count - 2 {
                    let l3 = lines[i + 2]
                    if isBankLine(l2) && isMaskedAccountLine(l3) {
                        result.append(Party(name: l1, bank: l2, account: l3))
                        i += 3
                        continue
                    }
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
        // เพิ่มคำว่า baht, บาท เข้าไปบล็อกด้วยเพื่อป้องกัน OCR อ่านผิด
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
        guard t.count >= 6 else { return false } // ลดขั้นต่ำลงเผื่อบางธนาคารสั้น
        guard t.contains("x") || t.contains("*") else { return false } // 💡 รองรับทั้ง x และ *
        guard t.range(of: #"\d"#, options: .regularExpression) != nil else { return false }
        
        // 💡 Regex ใหม่: อนุญาตให้มี x, *, ตัวเลข, ขีด, และจุด
        return t.range(of: #"^[x*0-9\-.]+$"#, options: .regularExpression) != nil
    }
    
    static func normalizeBank(_ raw: String) -> String {
        let t = compact(raw)
        if t.contains("ออมสิน") || t.contains("gsb") || t.contains("mymo") { return "GSB" }
        if t.contains("กสิกร") || t.contains("kbank") || t.contains("kplus") || t.contains("k-plus") || t.contains("ธกสิกรไทย") { return "KBANK" }
        if t.contains("ไทยพาณิชย์") || t.contains("scb") || t.contains("scbeasy") { return "SCB" }
        if t.contains("กรุงเทพ") || t.contains("bangkokbank") || t.contains("bbl") || t.contains("bualuang") { return "BBL" }
        if t.contains("กรุงไทย") || t.contains("krungthai") || t.contains("ktb") || t.contains("krungthainext") { return "KTB" }
        if t.contains("กรุงศรี") || t.contains("krungsri") || t.contains("ayudhya") || t.contains("bay") || t.contains("kma") { return "BAY" }
        if t.contains("ทีทีบี") || t.contains("ttb") || t.contains("tmbthanachart") || t.contains("ttbtouch") { return "TTB" }
        if t.contains("เกียรตินาคินภัทร") || t.contains("kkp") { return "KKP" }
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

            // 💡 1. ดึงข้อมูลจาก Settings (สมมติผู้ใช้พิมพ์: "มาร์ค mark")
            let savedName = UserDefaults.standard.string(forKey: "userRealName") ?? ""
            
            // 💡 2. หั่นข้อความด้วยช่องว่าง จะได้ Array: ["มาร์ค", "mark"]
            let myKeywords = savedName.lowercased()
                .components(separatedBy: .whitespaces)
                .map { normalizeName($0) }
                .filter { $0.count >= 3 } // ป้องกันคำสั้นเกินไป
                
            if !myKeywords.isEmpty {
                // 💡 3. เช็คไขว้: ขอแค่มี Keyword คำใดคำหนึ่ง ปรากฏอยู่ในชื่อคนส่งและคนรับ
                let senderIsMe = myKeywords.contains { a.contains($0) }
                let receiverIsMe = myKeywords.contains { b.contains($0) }
                
                // ถ้าใช่เราทั้งคู่ (แม้จะคนละภาษา หรือมีแค่ชื่อไม่มีนามสกุล) บล็อกทันที!
                if senderIsMe && receiverIsMe {
                    return true
                }
            }

            // ----- ลอจิกเปรียบเทียบชื่อดั้งเดิม (เผื่อผู้ใช้ยังไม่ได้ตั้งค่า) -----
            if a == b { return true }
            if commonPrefixLength(a, b) >= 5 { return true } // ปรับให้ยืดหยุ่นขึ้นนิดนึง

            let ta = firstNameToken(from: lhs)
            let tb = firstNameToken(from: rhs)
            if let ta = ta, let tb = tb, ta.count >= 3, tb.count >= 3, ta == tb {
                return true
            }
            return false
        }
    
    static func firstNameToken(from raw: String) -> String? {
        let cleaned = raw
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "*", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let prefixes: Set<String> = ["นาย", "นาง", "นางสาว", "ด.ช", "ดช", "ด.ญ", "ดญ", "mr", "mrs", "ms"]
        let tokens = cleaned.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .filter { !prefixes.contains($0.lowercased()) }
        
        guard let first = tokens.first else { return nil }
        let normalized = first.lowercased()
            .replacingOccurrences(of: #"[^a-zA-Zก-๙0-9]"#, with: "", options: .regularExpression)
        return normalized.isEmpty ? nil : normalized
    }
    
    static func commonPrefixLength(_ a: String, _ b: String) -> Int {
        // ⚠️ ใช้ unicodeScalars แทน Character (grapheme cluster)
        // เพราะภาษาไทยมีสระ/วรรณยุกต์รวม เช่น "มู" = 1 grapheme แต่ 2 scalars
        // ถ้าใช้ grapheme จะทำให้ "ม" ≠ "มู" ทั้งที่ขึ้นต้นเหมือนกัน
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
