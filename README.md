# 💸 SlipSense

> **SlipSense** คือแอปพลิเคชันจัดการการเงินบน iOS ที่เปลี่ยน **รูปสลิปโอนเงิน** ให้กลายเป็น **บันทึกรายจ่ายอัตโนมัติ** ด้วยเทคโนโลยี OCR โดยข้อมูลทั้งหมดถูกประมวลผลและจัดเก็บ **ภายในอุปกรณ์ (On-Device)** เพื่อความเป็นส่วนตัวและความปลอดภัยสูงสุด 🔒

---

# 🚀 App Showcase

## 📸 Smart Auto-Scan
เมื่อเปิดแอปครั้งแรก ระบบจะค้นหาและสแกนสลิปจากอัลบั้มธนาคารโดยอัตโนมัติ หลังจากนั้น OCR จะทำงานแบบ Background เพื่อประมวลผลสลิปใหม่ทันทีที่ถูกบันทึกลงในเครื่อง ช่วยลดภาระการบันทึกรายจ่ายด้วยตนเองทั้งหมด

https://github.com/user-attachments/assets/6f87294f-9fc3-4fcc-a17a-1b7850d7d758

---

## 📊 Interactive Dashboard
แดชบอร์ดแสดงภาพรวมการใช้จ่ายผ่านกราฟแบบ Interactive พร้อมรองรับการกรองข้อมูลตามช่วงเวลาและสรุปค่าใช้จ่ายแยกตามธนาคารแบบ Real-time
* **Today** (วันนี้)
* **This Week** (สัปดาห์นี้)
* **This Month** (เดือนนี้)
* **Custom Range** (กำหนดช่วงเวลาเอง)

https://github.com/user-attachments/assets/4974909c-a22b-496b-8e8b-b6349f84da4b

---

## 🎙️ Siri & App Intents
เข้าถึงข้อมูลการเงินได้อย่างรวดเร็วผ่าน Siri หรือ Apple Intelligence เพียงออกคำสั่งเสียงหรือค้นหาผ่านช่องทางระบบของ iOS
* **Siri Voice Command:** *"ฉันใช้เงินไปเท่าไหร่ในแอป SlipSense"*
* **Spotlight Search:** *"ยอดใช้จ่ายวันนี้"*

https://github.com/user-attachments/assets/6a72e70c-7e27-43b3-adca-e7d2497794b2

https://github.com/user-attachments/assets/cb4e5a16-3606-4a24-b333-d5a70bcbf7fd

---

# ✨ Key Features

### 📸 Auto Slip Scanner
* **Automatic Detection:** ดักจับเฉพาะรูปภาพที่เป็นสลิปธนาคารโดยอัตโนมัติ ไม่ปะปนกับรูปถ่ายทั่วไป
* **Two-Pass Scanning:** อัลกอริทึมวิเคราะห์สแกน 2 รอบควบ เพื่อเพิ่มความแม่นยำในการอ่านภาษาไทยและตัวเลขบนสลิป

### 🧠 Self-Transfer Guard
* **อัลกอริทึมคัดกรองอัจฉริยะ:** ระบบตรวจสอบชื่อผู้โอนและผู้รับบนสลิป หากพบว่าเป็นการโอนเงินสลับบัญชีไปมาของตัวผู้ใช้เอง (Self-Transfer) ระบบจะข้ามการบันทึกยอดนั้นอัตโนมัติเพื่อป้องกันยอดเงินซ้ำซ้อน

### 📊 Smart Dashboard
* **Dynamic Donut Chart:** วงแหวนแสดงสัดส่วนรายจ่ายแยกสีตามธนาคารแบบเรียลไทม์
* **Daily Spending Chart:** กราฟแท่งแสดงแนวโน้มยอดใช้เงินย้อนหลัง
* **Time-of-Day Analysis:** เจาะลึกช่วงเวลาที่เสียเงินมากที่สุดในแต่ละวัน (เช้า, บ่าย, ค่ำ, ดึก)[cite: 2]

### 🔍 Full-Text Search
* ค้นหาประวัติการทำธุรกรรมได้อย่างรวดเร็วจากทุกข้อความที่อยู่บนสลิป เช่น **ชื่อร้านค้า, รหัสอ้างอิง, บันทึกช่วยจำ (Memo), หรือสาขาธนาคาร**[cite: 2]

### 🌓 Adaptive UI
* รองรับสไตล์การแสดงผลทั้งกลมกลืนตามระบบปฏิบัติการ
  * **Light Mode** (โหมดสว่าง)
  * **Dark Mode** (โหมดมืด)

### 🛡️ 100% On-Device Privacy
* **Local Processing:** ไม่มีระบบ Cloud Storage และไม่พึ่งพา External Server ภายนอก ข้อมูลและรูปภาพทั้งหมดประมวลผลออฟไลน์บนเครื่องของผู้ใช้เท่านั้น[cite: 2]

---

# 🛠️ Architecture & Tech Stack

### 💻 Tech Stack

| Category | Technology | Description |
| :--- | :--- | :--- |
| **Language** | Swift | Native Development 100% |
| **UI Framework** | SwiftUI | Declarative UI Component[cite: 2] |
| **Architecture** | MVVM | Clean Design Pattern แยกส่วน Logic และ View[cite: 2] |
| **Database** | SwiftData | ประสิทธิภาพสูง จัดเก็บข้อมูลในเครื่องปลอดภัย[cite: 2] |
| **Charts** | Swift Charts | แสดงผล Data Visualization ที่ลื่นไหลและสวยงาม[cite: 2] |
| **OCR Core** | Vision Framework | `VNRecognizeTextRequest` ประมวลผลภาพแบบ On-Device[cite: 2] |
| **Photo Library** | PhotoKit | จัดการ Asset รูปภาพในเครื่องได้อย่างปลอดภัย[cite: 2] |
| **Siri Integration** | AppIntents | ผูกคำสั่งลัดกับระบบ Siri Shortcuts[cite: 2] |
| **Localization** | String Catalog | รองรับการจัดการข้อความหลายภาษาอย่างเป็นระบบ[cite: 2] |

---

# 🏛️ Architecture & Project Structure

### 1. Architectural Overview (MVVM)
SlipSense ถูกออกแบบภายใต้สถาปัตยกรรม **MVVM (Model-View-ViewModel)** โดยแยก Presentation, Business Logic และ Data Layer ออกจากกันอย่างเด็ดขาด เพื่อความง่ายต่อการบำรุงรักษาและการทดสอบซอฟต์แวร์[cite: 2]

```text
       ┌─────────────────────────────────────────────────────────┐
       │                      SwiftUI Views                      │
       └───────────────────────────┬─────────────────────────────┘
                                   │
                                   ▼
       ┌─────────────────────────────────────────────────────────┐
       │                 ViewModels (@Observable)                │
       └───────────────────────────┬─────────────────────────────┘
                                   │
                                   ▼
       ┌─────────────────────────────────────────────────────────┐
       │                Services / Business Logic                │
       │  ┌────────────────────────┼──────────────────────────┐  │
       │  ▼                        ▼                          ▼  │
       │ OCRService           PhotoService             ParserService │
       └───────────────────────────┬─────────────────────────────┘
                                   │
                                   ▼
       ┌─────────────────────────────────────────────────────────┐
       │                Models / SwiftData Storage               │
       └─────────────────────────────────────────────────────────┘
