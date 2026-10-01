import SwiftUI

struct LockScreenView: View {
    @Environment(\.dismiss) private var dismiss
    var securityService: SecurityService
    
    // State สำหรับเก็บรหัส 2 รอบ
    @State private var pin: String = ""
    @State private var errorMessage: String? = nil
    
    // State สำหรับสั่ง Shake Animation และ Haptic Feedback
    @State private var shakeAttempts: Int = 0
    
    var isForDisable: Bool = false
    
    // ตัวคุมให้คีย์บอร์ดเด้งอัตโนมัติ
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // 1. ข้อความแนะนำตามสเต็ป
                VStack(spacing: 8) {
                    Text("ปลดล็อก SlipSense")
                    Text("กรุณากรอกรหัสผ่าน 4 หลักของคุณ")
                    
                }
                
                // 2. วงกลมแสดงสถานะ 4 จุด (PIN Dots)
                HStack(spacing: 20) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(index < pin.count ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 18, height: 18)
                    }
                }
                .padding(.vertical, 12)
                .shake(attempts: shakeAttempts)
                .sensoryFeedback(.error, trigger: shakeAttempts)
                
                // ข้อความแจ้งเตือนถ้ารหัสไม่ตรงกัน
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                
                // 3. Invisible TextField ตัวรับค่าตัวเลขจริง
                TextField("", text: currentBinding)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .frame(width: 1, height: 1)
                    .opacity(0.001)
                
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }
            .onAppear { isFocused = true }
            
        }
    }
    
    
    private var currentBinding: Binding<String> {
        Binding(
            get: { pin },
            set: { newValue in
                let filtered = String(newValue.filter { $0.isNumber }.prefix(4))
                
                pin = filtered
                if pin.count == 4 {
                    verifyAndUnlock()
                }
            }
        )
    }
    
    // ตรวจสอบรหัสผ่านเพื่อปลดล็อก
    private func verifyAndUnlock() {
        // 1. โยนรหัส 4 หลักที่พิมพ์จบเมื่อกี้ ไปให้หลังบ้าน (SecurityService) เช็ก
        let isCorrect = securityService.verifyPin(inputPin: pin)
        
        if isCorrect {
            if isForDisable{
                
                securityService.disableSecurity()
                dismiss()
            }else{
                
            }
            
        } else {
            // ❌ ถ้ารหัสผิด: สั่งสั่นเครื่อง, โชว์ข้อความ Error, และล้างรหัสทิ้ง
            withAnimation(.default) {
                shakeAttempts += 1
                errorMessage = "รหัสผ่านไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง"
                pin = "" // เคลียร์ช่องพิมพ์ให้ว่างเพื่อรอรับรหัสรอบใหม่
            }
        }
    }
}


