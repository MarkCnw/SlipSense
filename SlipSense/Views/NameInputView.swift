import SwiftUI

struct NameInputView: View {
    // 💡 เชื่อมต่อกับ ViewModel
    @State private var viewModel = NameInputViewModel()
    
    // ตัวแปรสำหรับคุมการสลับหน้า
    @AppStorage("hasName") private var hasName: Bool = false
    
    // 💡 คุมการแสดงคีย์บอร์ด
    @FocusState private var focusedField: Field?
    enum Field { case thai, english }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // 📍 1. ส่วนหัว (Header) สไตล์ iOS Setup
            VStack(alignment: .leading, spacing: 12) {
               
                Text("ชื่อของคุณคืออะไร?")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                
                Text("แอปจะใช้ชื่อของคุณเพื่อดักจับและซ่อนการโอนเงินระหว่างบัญชีตัวเอง ทำให้การสรุปรายจ่ายแม่นยำที่สุด")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            }
            .padding(.top, 60)
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
            
            // 📍 2. ช่องกรอกข้อมูล (Flat Design)
            VStack(spacing: 20) {
                CustomTextField(
                    title: "ชื่อภาษาไทย",
                    placeholder: "สมหมาย ใจดี",
                    text: $viewModel.thaiName
                )
                .focused($focusedField, equals: .thai)
                
                CustomTextField(
                    title: "English Name",
                    placeholder: "Sommai jaidee",
                    text: $viewModel.englishName
                )
                .focused($focusedField, equals: .english)
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // 📍 3. ปุ่มดำเนินการ
            VStack(spacing: 16) {
                Button {
                    focusedField = nil // หุบคีย์บอร์ดก่อนเซฟ
                    viewModel.saveName {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            hasName = true
                        }
                    }
                } label: {
                    Text("บันทึกและไปต่อ")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.isSaveDisabled ? Color.gray.opacity(0.3) : Color.blue)
                        // ใช้ continuous เพื่อความโค้งมนแบบ Apple
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(viewModel.isSaveDisabled)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isSaveDisabled)
                
                // ปุ่มข้าม
                Button {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        hasName = true
                    }
                } label: {
                    Text("ตั้งค่าภายหลัง")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        // แตะพื้นที่ว่างเพื่อหุบคีย์บอร์ด
        .onTapGesture {
            focusedField = nil
        }
    }
}

// 🎨 Component: ช่องกรอกข้อความที่ออกแบบใหม่ให้ดูคลีน
struct CustomTextField: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            TextField(placeholder, text: $text)
                .font(.body)
                .padding()
                // ใช้สีพื้นหลังมาตรฐานของ iOS สำหรับ Input
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

#Preview {
    NameInputView()
}
