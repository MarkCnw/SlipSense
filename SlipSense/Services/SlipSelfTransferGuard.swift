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
}

private extension SlipSelfTransferGuard {
    struct Party {
        let name: String
        let bank: String
        let account: String
    }

    static func extractPartiesByLineScan(from lines: [String]) -> [Party] {
        guard lines.count >= 3 else { return [] }
        var result: [Party] = []

        for i in 0..<(lines.count - 2) {
            let l1 = lines[i]
            let l2 = lines[i + 1]
            let l3 = lines[i + 2]

            if isLikelyNameLine(l1),
               isBankLine(l2),
               isMaskedAccountLine(l3) {
                result.append(Party(name: l1, bank: l2, account: l3))
            }
        }

        // dedup
        var dedup: [Party] = []
        for p in result {
            if let last = dedup.last,
               normalizeName(last.name) == normalizeName(p.name),
               normalizeBank(last.bank) == normalizeBank(p.bank),
               compact(last.account) == compact(p.account) {
                continue
            }
            dedup.append(p)
        }
        return dedup
    }

    static func isLikelyNameLine(_ s: String) -> Bool {
        let blocked = ["โอนเงินสำเร็จ", "เลขที่รายการ", "จำนวน", "ค่าธรรมเนียม", "วันที่ทำรายการ", "สแกนตรวจสอบสลิป", "จาก", "ไปยัง"]
        if blocked.contains(where: { s.contains($0) }) { return false }
        if !normalizeBank(s).isEmpty { return false }
        if compact(s).range(of: #"\d"#, options: .regularExpression) != nil { return false }
        return compact(s).count >= 4
    }

    static func isBankLine(_ s: String) -> Bool {
        !normalizeBank(s).isEmpty
    }

    static func isMaskedAccountLine(_ s: String) -> Bool {
        let t = compact(s)
        guard t.count >= 8 else { return false }
        guard t.contains("x") else { return false }
        guard t.range(of: #"\d"#, options: .regularExpression) != nil else { return false }
        return t.range(of: #"^[x0-9\-]+$"#, options: .regularExpression) != nil
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
        if a == b { return true }
        if commonPrefixLength(a, b) >= 6 { return true }

        let ta = firstNameToken(from: lhs)
        let tb = firstNameToken(from: rhs)
        if let ta, let tb, ta.count >= 4, tb.count >= 4, ta == tb {
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
        let aa = Array(a), bb = Array(b)
        let n = min(aa.count, bb.count)
        var i = 0
        while i < n, aa[i] == bb[i] { i += 1 }
        return i
    }

    static func compact(_ s: String) -> String {
        s.lowercased().replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
    }
}
