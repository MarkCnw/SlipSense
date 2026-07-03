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
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    func nextPage() {
        guard currentPage < pages.count - 1 else { return }
        currentPage += 1
    }
}
