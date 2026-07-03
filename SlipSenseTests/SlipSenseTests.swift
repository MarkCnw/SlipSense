import XCTest
@testable import SlipSense

final class SlipSelfTransferGuardTests: XCTestCase {

    // MARK: - 🧪 เทสที่ 1: โอนให้ตัวเอง แต่คนละธนาคาร (ต้องข้าม / เป็น True)
    func testSelfTransfer_CrossBank_ShouldReturnTrue() {
        // 1. Arrange: จำลองข้อความที่ได้จากสลิป (มีคำนำหน้าที่ต่างกันได้ เช่น นาย vs Mr.)
        let mockOCRText = """
        โอนเงินสำเร็จ
        วันที่ 26 เม.ย. 69
        นาย ชินวงศ์ มูลคนบุรี
        กสิกรไทย
        xxx-x-x1234-x
        ไปยัง
        Mr. ชินวงศ์ มูลคนบุรี
        SCB
        xxx-x-x9999-x
        """
        
        // 2. Act: เรียกใช้งานฟังก์ชัน
        let result = SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: mockOCRText)
        
        // 3. Assert: ต้องตรวจจับได้ว่าเป็นคนเดียวกันโอนข้ามแบงก์
        XCTAssertTrue(result, "ควรจับได้ว่าเป็นการโอนให้ตัวเองข้ามธนาคาร (กสิกร -> SCB)")
    }

    // MARK: - 🧪 เทสที่ 2: โอนให้ตัวเอง แต่เป็น "ธนาคารเดียวกัน" (ไม่เข้าเงื่อนไข / เป็น False)
    func testSelfTransfer_SameBank_ShouldReturnFalse() {
        let mockOCRText = """
        ชินวงศ์ มูลคนบุรี
        KTB
        xxx-x-x1111-x
        ชินวงศ์ มูลคนบุรี
        กรุงไทย
        xxx-x-x2222-x
        """
        
        let result = SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: mockOCRText)
        
        XCTAssertFalse(result, "ควรคืนค่า False เพราะเป็นธนาคารเดียวกัน (KTB -> กรุงไทย)")
    }

    // MARK: - 🧪 เทสที่ 3: โอนให้ "คนอื่น" ข้ามธนาคาร (ต้องไม่ข้าม / เป็น False)
    func testTransferToOtherPerson_CrossBank_ShouldReturnFalse() {
        let mockOCRText = """
        ชินวงศ์ มูลคนบุรี
        กสิกรไทย
        xxx-x-x1234-x
        นางสาว สมหญิง ใจดี
        BBL
        xxx-x-x5678-x
        """
        
        let result = SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: mockOCRText)
        
        XCTAssertFalse(result, "ควรคืนค่า False เพราะชื่อผู้ส่งและผู้รับไม่เหมือนกัน")
    }
    
    // MARK: - 🧪 เทสที่ 4: ชื่อพิมพ์ตกนิดหน่อย แต่ระบบยังรู้ว่าเป็นคนเดียวกัน (True)
    func testSelfTransfer_CrossBank_WithSlightlyDifferentName_ShouldReturnTrue() {
        // อ้างอิงจาก Logic `commonPrefixLength(a, b) >= 6` ของคุณ
        let mockOCRText = """
        ชินวงศ์ มูลคนบุรี
        ทีทีบี
        xxx-x-x0000-x
        ชินวงศ์ มูล
        พร้อมเพย์
        xxx-x-x9999-x
        """
        
        let result = SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: mockOCRText)
        
        XCTAssertTrue(result, "ควรจับได้ว่าเป็นคนเดียวกัน เพราะชื่อขึ้นต้นด้วย 'ชินวงศ์' เหมือนกัน")
    }
    
    // MARK: - 🧪 เทสที่ 5: สลิป mymo ที่มี "จาก" / "ถึง" และคำนำหน้า ด.ช. / นาย
    func testSelfTransfer_MymoSlip_WithDotChPrefix_ShouldReturnTrue() {
        let mockOCRText = """
        รายการโอนเงินสำเร็จ
        จำนวนเงิน
        10.00
        0.00 ค่าธรรมเนียม
        รหัสอ้างอิง: 618115491217I000009B9790
        30 มิ.ย. 2569 15:45
        จาก
        ด.ช. ชินวงศ์ มูลครบุรี
        ธนาคารออมสิน
        0200xxxx1433
        ถึง
        นาย ชินวงศ์ มูลครบุรี
        ธนาคารกสิกรไทย
        18xxxx5925
        """
        
        let result = SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: mockOCRText)
        
        XCTAssertTrue(result, "ควรจับได้ว่า ด.ช. ชินวงศ์ (ออมสิน) และ นาย ชินวงศ์ (กสิกร) เป็นคนเดียวกันข้ามธนาคาร")
    }
    
    // MARK: - 🧪 เทสที่ 6: จำลอง OCR output ที่ใช้ newline join (หลังแก้ bug)
    func testSelfTransfer_OCRNewlineJoined_ShouldReturnTrue() {
        // จำลอง output จาก recognizeText() หลังแก้ให้ใช้ \n แทน space
        let mockOCRText = "รายการโอนเงินสำเร็จ\nจำนวนเงิน\n10.00\n0.00 ค่าธรรมเนียม\nจาก\nด.ช. ชินวงศ์ มูลครบุรี\nธนาคารออมสิน\n0200xxxx1433\nถึง\nนาย ชินวงศ์ มูลครบุรี\nธนาคารกสิกรไทย\n18xxxx5925"
        
        let result = SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: mockOCRText)
        
        XCTAssertTrue(result, "OCR output ที่ใช้ newline join ควรทำให้ Guard ตรวจจับได้")
    }
    
    // MARK: - 🧪 เทสที่ 7: จำลอง OCR output แบบเก่า (space join) ต้อง fail
    func testSelfTransfer_OCRSpaceJoined_ShouldReturnFalse() {
        // จำลอง output จาก recognizeText() แบบเก่าที่ใช้ space — Guard ควรจะจับไม่ได้
        let mockOCRText = "รายการโอนเงินสำเร็จ จำนวนเงิน 10.00 0.00 ค่าธรรมเนียม จาก ด.ช. ชินวงศ์ มูลครบุรี ธนาคารออมสิน 0200xxxx1433 ถึง นาย ชินวงศ์ มูลครบุรี ธนาคารกสิกรไทย 18xxxx5925"
        
        let result = SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: mockOCRText)
        
        // space-joined text ไม่สามารถแยก party ได้ → Guard ควร return false
        XCTAssertFalse(result, "OCR output แบบ space join ไม่ควรจับได้ (เป็น expected limitation)")
    }
    
    // MARK: - 🧪 เทสที่ 8: สลิป K+ (กสิกร→ออมสิน) ชื่อผู้ส่งถูกตัดสั้น
    func testSelfTransfer_KPlusSlip_TruncatedSenderName_ShouldReturnTrue() {
        let mockOCRText = """
        โอนเงินสำเร็จ
        30 มิ.ย. 69 16:05 น.
        นาย ชินวงศ์ ม
        ธ.กสิกรไทย
        xxx-x-x9592-x
        ด.ช. ชินวงศ์ มูลครบุรี
        ธ.ออมสิน
        xxx-x-x3271-xxx
        เลขที่รายการ:
        016181160521AOR04439
        จำนวน:
        50.00 บาท
        ค่าธรรมเนียม:
        0.00 บาท
        สแกนตรวจสอบสลิป
        """
        
        let result = SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: mockOCRText)
        
        XCTAssertTrue(result, "ควรจับได้ว่า 'นาย ชินวงศ์ ม' (กสิกร) และ 'ด.ช. ชินวงศ์ มูลครบุรี' (ออมสิน) เป็นคนเดียวกัน — commonPrefix >= 6")
    }
    
    // MARK: - 🧪 Debug: dump ทุกค่าที่ Guard ใช้ตัดสินใจ
    func testDebug_KPlusSlip_DumpAllValues() {
        let mockOCRText = """
        โอนเงินสำเร็จ
        30 มิ.ย. 69 16:05 น.
        นาย ชินวงศ์ ม
        ธ.กสิกรไทย
        xxx-x-x9592-x
        ด.ช. ชินวงศ์ มูลครบุรี
        ธ.ออมสิน
        xxx-x-x3271-xxx
        เลขที่รายการ:
        016181160521AOR04439
        จำนวน:
        50.00 บาท
        ค่าธรรมเนียม:
        0.00 บาท
        สแกนตรวจสอบสลิป
        """
        
        let parties = SlipSelfTransferGuard.debugExtractParties(from: mockOCRText)
        let result = SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: mockOCRText)
        
        var debugMsg = "Guard result: \(result)\n"
        debugMsg += "Parties count: \(parties.count)\n"
        for (i, p) in parties.enumerated() {
            debugMsg += "Party \(i): name=[\(p.name)] bank=[\(p.bank)] account=[\(p.account)]\n"
        }
        
        // Intentionally fail to dump the values
        XCTFail("DEBUG DUMP:\n\(debugMsg)")
    }
}
