import XCTest
@testable import SlipSense

final class SlipSelfTransferGuardTests: XCTestCase {
    
    func testSelfTransfer_Chitsanupong_ShouldBeTrue() {
        // 1. จำลองข้อความที่ Vision OCR อ่านได้จากสลิป SCB ในรูป
        // (เราเพิ่ม SCB และ PromptPay เข้าไปเพื่อให้เข้าเงื่อนไขการดึงข้อมูลปาร์ตี้ของโค้ด)
        let ocrText = """
        โอนเงินสำเร็จ
        15 ก.ค. 2569 - 11:38
        รหัสอ้างอิง: 202607157wqO6FTxKoUD6hcx3
        จาก
        นาย ชิษณุพงศ์ ค.
        SCB
        xxx-xxx428-0
        ไปยัง
        นาย ชิษณุพงศ์ คงนอก
        PromptPay
        xxx-xxx-0616
        จำนวนเงิน
        10.00
        """
        
        // 2. โยนข้อความเข้าไปเทสในฟังก์ชันของเรา
        let result = SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: ocrText)
        
        // 3. ตรวจสอบผลลัพธ์ (ต้องได้ true เพราะเป็นคนเดียวกัน)
        XCTAssertTrue(result, "ควรตรวจจับได้ว่า 'ชิษณุพงศ์ ค.' และ 'ชิษณุพงศ์ คงนอก' คือคนเดียวกัน")
    }
}
