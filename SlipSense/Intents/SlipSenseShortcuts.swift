import AppIntents

struct SlipSenseShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            // ผูกประโยคเข้ากับ Intent ที่เราสร้างไว้ในขั้นตอนที่ 1
            intent: GetTodayExpenseIntent(),
            
            // 💡 กำหนดประโยคที่ผู้ใช้สามารถพูดกับ Siri ได้
            // \(.applicationName) จะถูกแทนที่ด้วยชื่อแอปของเราอัตโนมัติ
            phrases: [
                "วันนี้ฉันใช้เงินไปเท่าไหร่ใน \(.applicationName)",
                "เช็คยอดรายจ่ายวันนี้ด้วย \(.applicationName)",
                "สรุปยอดวันนี้ให้หน่อยใน \(.applicationName)"
            ],
            
            shortTitle: "ยอดใช้จ่ายวันนี้",
            systemImageName: "chart.pie.fill"
        )
    }
}
