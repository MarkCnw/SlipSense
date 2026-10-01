import Foundation
import Security
import Observation

@Observable
class SecurityService {
    // 💡 1. ให้ดึงค่าจาก UserDefaults มาเป็นค่าเริ่มต้นตรงนี้เลย (ไม่ต้องใช้ init แล้ว)
    var isSecurityEnabled: Bool = UserDefaults.standard.bool(forKey: "isSecurityEnabled") {
        didSet {
            UserDefaults.standard.set(isSecurityEnabled, forKey: "isSecurityEnabled")
        }
    }
    
    var isAppUnlocked: Bool = false
    var failedAttempts: Int = 0
    var isTemporarilyLocked: Bool = false
    
    init() {
        // ปล่อยว่างไว้ได้เลยครับ เพราะเราดึงค่าให้ isSecurityEnabled ไปแล้วด้านบน
    }
    
    func createPin(pin: String) {
        guard let pinData = pin.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "user_app_pin",
            kSecValueData as String: pinData
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            self.isSecurityEnabled = true
            self.isAppUnlocked = true
            self.failedAttempts = 0
        }
    }
    
    func verifyPin(inputPin: String) -> Bool {
        // Step 1: สร้าง Query สำหรับดึงข้อมูล
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "user_app_pin",
            kSecReturnData as String: true,              // ขอข้อมูลคืน
            kSecMatchLimit as String: kSecMatchLimitOne  // ดึงรายการเดียว
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        // Step 2 & 3: เช็กว่าดึงสำเร็จไหม และแปลง Data เป็น String
        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let storedPin = String(data: data, encoding: .utf8) {
            
            // Step 4: ตรวจสอบว่ารหัสที่กรอก (inputPin) ตรงกับใน Keychain (storedPin) ไหม
            if inputPin == storedPin {
                // ✅ ถ้ารหัสถูกต้อง:
                self.isAppUnlocked = true
                self.failedAttempts = 0
                self.isTemporarilyLocked = false // ปลดล็อกสถานะการล็อกชั่วคราวด้วย
                return true
            } else {
                // ❌ ถ้ารหัสผิด:
                self.failedAttempts += 1
                
                // 💡 2. ตอบคำถาม: สั่งล็อกชั่วคราวเมื่อกรอกผิดครบ 3 ครั้ง
                if self.failedAttempts >= 3 {
                    self.isTemporarilyLocked = true
                    // (ในอนาคตถ้าอยากหน่วงเวลา สามารถบันทึก Timestamp ลง UserDefaults ได้ครับ)
                }
                
                return false
            }
        }
        
        return false
    }
    func disableSecurity() {
        // 1. กำหนดเป้าหมายที่จะลบ (บอกแค่ว่าเป็น Password ของ account อะไร)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "user_app_pin"
        ] // 👈 ปิดวงเล็บของ Dictionary ให้เรียบร้อยตรงนี้
        
        // 2. สั่งลบข้อมูลออกจาก Keychain
        let status = SecItemDelete(query as CFDictionary)
        
        // 3. ถ้าลบสำเร็จ ให้อัปเดตตัวแปรในแอป
        if status == errSecSuccess || status == errSecItemNotFound {
            self.isSecurityEnabled = false
            self.failedAttempts = 0
        }
    }
}
