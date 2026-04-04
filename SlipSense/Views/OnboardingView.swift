import SwiftUI

// โครงสร้างข้อมูลสำหรับแต่ละหน้า
struct OnboardingPage: Identifiable {
    let id = UUID()
    let image: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let color: Color
}

struct OnboardingView: View {
    // ตัวแปรสำหรับเช็คว่าผู้ใช้ดูหน้าต้อนรับจบหรือยัง
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var currentPage = 0
    
    // ข้อมูลทั้ง 3 หน้า
    let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "text.viewfinder",
            title: "สแกนสลิปอัตโนมัติ",
            description: "ไม่ต้องเหนื่อยพิมพ์เอง! แค่บันทึกสลิปโอนเงิน ระบบ AI จะดึงยอดเงินและชื่อธนาคารให้ทันที",
            color: .blue
        ),
        OnboardingPage(
            image: "chart.bar.xaxis",
            title: "วิเคราะห์พฤติกรรม",
            description: "รู้ทันทุกการใช้จ่าย ด้วยแดชบอร์ดสรุปยอดเงินและช่วงเวลาที่คุณเสียเงินมากที่สุด",
            color: .orange
        ),
        OnboardingPage(
            image: "lock.shield.fill",
            title: "ปลอดภัย ข้อมูลไม่รั่วไหล",
            description: "ข้อมูลทุกอย่างประมวลผลและเก็บไว้ในเครื่องของคุณเท่านั้น ไม่มีการส่งขึ้นเซิร์ฟเวอร์",
            color: .green
        )
    ]
    
    var body: some View {
        VStack {
            // ส่วนสไลด์หน้าจอ
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        Spacer()
                        
                        // รูปภาพไอคอน
                        Image(systemName: pages[index].image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundStyle(pages[index].color)
                            .padding(.bottom, 30)
                        
                        // หัวข้อ
                        Text(pages[index].title)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        // คำอธิบาย
                        Text(pages[index].description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            // ปุ่มด้านล่าง
            VStack {
                if currentPage == pages.count - 1 {
                    // ปุ่มหน้าสุดท้าย: เริ่มต้นใช้งาน
                    Button(action: {
                        withAnimation {
                            hasSeenOnboarding = true // เปลี่ยนสถานะเพื่อเข้าแอปหลัก
                        }
                    }) {
                        Text("เริ่มต้นใช้งาน")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 40)
                    .transition(.opacity)
                } else {
                    // ปุ่มหน้าอื่นๆ: ถัดไป
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        Text("ถัดไป")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.8))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 40)
                }
            }
            .padding(.bottom, 50)
            .animation(.easeInOut, value: currentPage)
        }
    }
}
