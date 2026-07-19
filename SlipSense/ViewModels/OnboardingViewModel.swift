import SwiftUI
import Observation

struct OnboardingPage: Identifiable {
    let id = UUID()
    let image: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let color: Color
}

@MainActor
@Observable
final class OnboardingViewModel {
    var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            // ✅ เปลี่ยนชื่อให้ตรงกับในรูป ภาพ.jpg
            image: "Blockchain-Network--Streamline-Manila",
            title: "สแกนสลิปอัตโนมัติ",
            description: "บอกลาการจดเเบบเดิม ทุกครั้งที่คุณโอนเงินเสร็จ ระบบจะอ่านสลิปและสรุปยอดให้ทันที",
            color: .blue
        ),
        OnboardingPage(
            // ✅ เปลี่ยนชื่อให้ตรงกับในรูป ภาพ.jpg (ใช้รูป Approval แทนจะได้ไม่ซ้ำกันครับ)
            image: "Online-Shopping--Streamline-Manila",
            title: "วิเคราะห์พฤติกรรม",
            description: "รู้ทันทุกการใช้จ่าย ด้วยแดชบอร์ดสรุปยอดเงินและช่วงเวลาที่คุณเสียเงินมากที่สุด",
            color: .orange
        ),
        OnboardingPage(
            // ✅ เปลี่ยนชื่อให้ตรงกับในรูป ภาพ.jpg
            image: "Protect-Privacy-1--Streamline-Manila",
            title: "ปลอดภัย ข้อมูลไม่รั่วไหล",
            description: "ข้อมูลทุกอย่างประมวลผลและเก็บไว้ในเครื่องของคุณเท่านั้น ไม่มีการส่งขึ้นเซิร์ฟเวอร์",
            color: .green
        )
    ]
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    func nextPage() {
        guard currentPage < pages.count - 1 else { return }
        currentPage += 1
    }
}
