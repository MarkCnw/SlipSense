import XCTest
@testable import SlipSense

final class SlipSelfTransferGuardTests: XCTestCase {
    
    func testSelfTransfer_Chitsanupong_ShouldBeTrue() {
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
        
        let result = SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: ocrText)
        XCTAssertTrue(result, "ควรตรวจจับได้ว่า 'ชิษณุพงศ์ ค.' และ 'ชิษณุพงศ์ คงนอก' คือคนเดียวกัน")
    }
    
    func testSelfTransfer_MyMoTopUp_ShouldBeTrue() {
        let ocrText = """
        รายการเติมเงินสำเร็จ
        จำนวนเงิน
        60.00
        0.00 ค่าธรรมเนียม
        รหัสอ้างอิง: 6197204123081000017B9790
        16 ก.ค. 2569 20:31
        จาก
        ด.ช. ชินวงศ์ มูลครบุรี
        ธนาคารออมสิน
        0200xxxx1433
        ถึง
        ชินวงศ์ มูลครบุรี
        เติมเงินพร้อมเพย์
        140000954571129
        QR Code
        สแกน QR เพื่อตรวจสอบรายละเอียด
        ของรายการ
        """
        
        let result = SlipSelfTransferGuard.shouldSkipSelfTransferCrossBank(from: ocrText)
        XCTAssertTrue(result, "สลิป MyMo เติมเงินพร้อมเพย์ให้ตัวเอง ควรข้ามได้")
    }
}

// ╔═══════════════════════════════════════════════════════════════╗
// ║  MARK: - 🛑 ทดสอบการยกเลิกสแกน (Scan Cancellation)         ║
// ╚═══════════════════════════════════════════════════════════════╝

final class ScanCancellationTests: XCTestCase {
    
    /// ทดสอบว่า Task.isCancelled หยุด loop ได้จริง
    func testCancelledTask_StopsProcessing() async {
        let totalItems = 100
        var processedCount = 0
        
        let task = Task {
            for i in 0..<totalItems {
                // 🛑 เช็คเหมือนใน SlipScanWorker.batchScan
                if Task.isCancelled {
                    break
                }
                processedCount = i + 1
                // จำลองการทำงาน OCR (ใช้เวลานิดหน่อย)
                try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
            }
        }
        
        // รอให้สแกนไปสักหน่อย
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // 🛑 กดยกเลิก!
        task.cancel()
        
        // รอให้ task หยุดจริง
        await task.value
        
        // ✅ ต้องหยุดก่อนจะถึง 100 ตัว
        XCTAssertLessThan(processedCount, totalItems,
            "หลังกดยกเลิก ระบบต้องหยุดสแกน — ประมวลผลไป \(processedCount)/\(totalItems) ตัว")
        XCTAssertGreaterThan(processedCount, 0,
            "ก่อนกดยกเลิก ต้องมีการประมวลผลไปบ้างแล้ว")
        
        print("✅ ยกเลิกสำเร็จ: ประมวลผล \(processedCount)/\(totalItems) ตัว แล้วหยุด")
    }
    
    /// ทดสอบว่ากดยกเลิกทันที (ยังไม่ทันเริ่ม) จะไม่ประมวลผลอะไรเลย
    func testCancelBeforeStart_ProcessesNothing() async {
        var processedCount = 0
        
        let task = Task {
            for _ in 0..<50 {
                if Task.isCancelled { break }
                processedCount += 1
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
        }
        
        // ยกเลิกทันที!
        task.cancel()
        await task.value
        
        // ต้องไม่ได้ทำอะไรเลย หรือทำแค่ 1-2 ตัวเพราะ race condition
        XCTAssertLessThanOrEqual(processedCount, 2,
            "กดยกเลิกทันที ต้องไม่ประมวลผลอะไรเลย (หรือแทบไม่มี)")
        
        print("✅ ยกเลิกทันที: ประมวลผลไป \(processedCount) ตัว")
    }
    
    /// ทดสอบว่า Task ที่ไม่ได้ยกเลิก จะทำงานจนครบ
    func testNoCancellation_ProcessesAll() async {
        let totalItems = 20
        var processedCount = 0
        
        let task = Task {
            for _ in 0..<totalItems {
                if Task.isCancelled { break }
                processedCount += 1
            }
        }
        
        await task.value
        
        XCTAssertEqual(processedCount, totalItems,
            "ถ้าไม่กดยกเลิก ต้องประมวลผลครบทุกตัว (\(totalItems))")
    }
    
    /// ทดสอบว่า AlbumDetailViewModel.cancelScan() ตั้งค่าสถานะถูกต้อง
    @MainActor
    func testCancelScan_UpdatesState() {
        let photoService = PhotoService()
        let viewModel = AlbumDetailViewModel(photoService: photoService)
        
        // จำลองสถานะกำลังสแกน
        viewModel.isBatchScanning = true
        
        // กดยกเลิก
        viewModel.cancelScan()
        
        // ✅ ตรวจสอบว่าสถานะอัปเดตถูกต้อง
        XCTAssertFalse(viewModel.isBatchScanning, "หลังกดยกเลิก isBatchScanning ต้องเป็น false")
    }
}
