import AppIntents
import SwiftData
import Foundation

struct GetTodayExpenseIntent: AppIntent {
    // 1. ชื่อและคำอธิบายที่จะไปโชว์ในแอป Shortcuts
    static var title: LocalizedStringResource = "เช็คยอดใช้จ่ายวันนี้"
    static var description = IntentDescription("คำนวณยอดเงินรวมจากสลิปที่สแกนในวันนี้")

    // 2. ฟังก์ชันนี้จะทำงานทันทีเมื่อผู้ใช้พูดสั่ง Siri
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        // 💡 เชื่อมต่อฐานข้อมูล SwiftData แบบเบื้องหลัง (Background)
        guard let container = try? ModelContainer(for: SlipRecord.self) else {
            return .result(dialog: "ขออภัยค่ะ ระบบฐานข้อมูลมีปัญหา")
        }
        let context = ModelContext(container)
        
        // 💡 หาวันเริ่มต้นของวันนี้ (เวลา 00:00 น.)
        let startOfDay = Calendar.current.startOfDay(for: Date())
        
        // 💡 ดึงเฉพาะสลิปของวันนี้
        let descriptor = FetchDescriptor<SlipRecord>(
            predicate: #Predicate { $0.scanDate >= startOfDay }
        )
        
        let todaySlips = (try? context.fetch(descriptor)) ?? []
        
        // 💡 คำนวณยอดรวม
        let totalAmount = todaySlips.reduce(0) { $0 + $1.amount }
        
        // 💡 จัดฟอร์แมตตัวเลขให้สวยงาม (เช่น 1,500)
        let formattedAmount = totalAmount.formatted(.number.precision(.fractionLength(0)))
        
        // 💡 เตรียมประโยคให้ Siri พูดตอบกลับ
        let dialog = IntentDialog("วันนี้บอสใช้เงินไปทั้งหมด \(formattedAmount) บาทค่ะ")
        
        // ส่งผลลัพธ์กลับไปให้ Siri ออกเสียง
        return .result(dialog: dialog)
    }
}
