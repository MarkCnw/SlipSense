import SwiftUI

struct CreatePINView: View {
    @Environment(\.dismiss) private var dismiss
    var securityService: SecurityService
    
    // State สำหรับเก็บรหัส 2 รอบ
    @State private var pin: String = ""
    @State private var confirmPin: String = ""
    @State private var isConfirming: Bool = false
    @State private var errorMessage: String? = nil
    
    // State สำหรับสั่ง Shake Animation และ Haptic Feedback
    @State private var shakeAttempts: Int = 0
    
    // ตัวคุมให้คีย์บอร์ดเด้งอัตโนมัติ
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // 1. ข้อความแนะนำตามสเต็ป
                VStack(spacing: 8) {
                    Text(isConfirming ? "ยืนยันรหัสผ่าน 4 หลัก" : "ตั้งรหัสผ่าน 4 หลัก")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(isConfirming ? "กรอกรหัสผ่านใหม่อีกครั้งเพื่อยืนยัน" : "กรอกรหัสผ่านที่คุณต้องการใช้งาน")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // 2. วงกลมแสดงสถานะ 4 จุด (PIN Dots)
                HStack(spacing: 20) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(index < currentInput.count ? Color.accentColor : Color.gray.opacity(0.3))
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("ยกเลิก") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Helper Logic
    
    private var currentInput: String {
        isConfirming ? confirmPin : pin
    }
    
    private var currentBinding: Binding<String> {
        Binding(
            get: { currentInput },
            set: { newValue in
                let filtered = String(newValue.filter { $0.isNumber }.prefix(4))
                
                if isConfirming {
                    confirmPin = filtered
                    if confirmPin.count == 4 {
                        validateAndSave()
                    }
                } else {
                    pin = filtered
                    if pin.count == 4 {
                        withAnimation {
                            isConfirming = true
                        }
                    }
                }
            }
        )
    }
    
    private func validateAndSave() {
        if pin == confirmPin {
            securityService.createPin(pin: pin)
            dismiss()
        } else {
            withAnimation(.default) {
                shakeAttempts += 1
                errorMessage = "รหัสผ่านไม่ตรงกัน กรุณาลองใหม่อีกครั้ง"
                pin = ""
                confirmPin = ""
                isConfirming = false
            }
        }
    }
}

// MARK: - File Scope Declarations (ต้องอยู่นอก struct CreatePINView)

struct ShakeEffect: GeometryEffect {
    var travelDistance: CGFloat = 10
    var shakeCount: Int = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translationX = travelDistance * sin(animatableData * .pi * CGFloat(shakeCount * 2))
        return ProjectionTransform(CGAffineTransform(translationX: translationX, y: 0))
    }
}

extension View {
    func shake(attempts: Int) -> some View {
        self.modifier(ShakeEffect(animatableData: CGFloat(attempts)))
    }
}
