import SwiftUI
import Observation

@MainActor
@Observable
final class NameInputViewModel {
    // เก็บข้อมูลจาก TextField
    var thaiName: String = ""
    var englishName: String = ""
    
    // ตรวจสอบว่าปุ่มควรถูกล็อค (Disabled) หรือไม่
    var isSaveDisabled: Bool {
        thaiName.trimmingCharacters(in: .whitespaces).isEmpty &&
        englishName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // ฟังก์ชันจัดการรวมชื่อและบันทึกข้อมูล
    func saveName(onComplete: () -> Void) {
        let tName = thaiName.trimmingCharacters(in: .whitespaces)
        let eName = englishName.trimmingCharacters(in: .whitespaces)
        
        // จัดการรวมชื่อด้วยเครื่องหมาย | เพื่อป้องกันปัญหานามสกุลโดนตัดไปอยู่อีกช่อง
        let combinedName = "\(tName)|\(eName)"
        
        // บันทึกลง UserDefaults (ตัวแปร @AppStorage ในระบบจะอัปเดตตามอัตโนมัติ)
        UserDefaults.standard.set(combinedName, forKey: "userRealName")
        
        // ส่งสัญญาณบอกว่าทำงานเสร็จแล้ว
        onComplete()
    }
}
