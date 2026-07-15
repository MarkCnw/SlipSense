import AppIntents

struct SlipSenseShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        // เหลือไว้แค่ GetTodayExpenseIntent ตัวเดียว
        AppShortcut(
            intent: GetTodayExpenseIntent(),
            phrases: [
                "ยอดใช้จ่ายวันนี้จาก \(.applicationName)",
                "อัปเดตสลิปใน \(.applicationName)",
                "เช็คยอด \(.applicationName)"
            ],
            shortTitle: "ยอดใช้จ่ายวันนี้",
            systemImageName: "doc.text.viewfinder" // สามารถเปลี่ยนชื่อไอคอนได้ตามต้องการ
        )
    }
}
