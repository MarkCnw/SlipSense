# 💸 SlipSense

**SlipSense คือแอปพลิเคชันจัดการการเงินบน iOS ที่ช่วยเปลี่ยน "รูปสลิปโอนเงิน" ในคลังภาพของคุณ ให้กลายเป็น "บันทึกรายจ่ายอัตโนมัติ" ได้ทันที โดยที่คุณไม่ต้องนั่งพิมพ์เอง


https://github.com/user-attachments/assets/05c1fb22-7441-446d-a35f-f10966921b73







---

## ✨ ฟีเจอร์เด่น (Key Features)

- 📸 **Auto Slip Scanner (สแกนสลิปอัตโนมัติ):** ดึงข้อมูลยอดเงิน วันเวลา และชื่อธนาคารจากสลิปโอนเงินในเครื่องได้เองโดยไม่ต้องพิมพ์ ด้วยอัลกอริทึมสแกน 2 รอบควบ (Two-Pass Scanning) เพิ่มความแม่นยำในการอ่านภาษาไทย
- 📊 **Smart Dashboard (แดชบอร์ดอัจฉริยะ):**
  - **Smart Ring:** วงแหวนเปรียบเทียบยอดการใช้จ่ายรายสัปดาห์ พร้อมจิตวิทยาการใช้สีแจ้งเตือนเมื่อใช้เงินเกินงบ
  - **Daily Bar Chart:** กราฟสรุปเทรนด์การใช้เงินย้อนหลัง 7 วัน และ 30 วัน
  - **Time-Spend Analysis:** วิเคราะห์เจาะลึกช่วงเวลาที่คุณเสียเงินมากที่สุด (เช้า, บ่าย, ค่ำ, ดึก)
- 🔍 **Full-Text Search (ค้นหาอัจฉริยะ):** ค้นหาประวัติการโอนเงินจากทุกข้อความบนสลิป (เช่น ชื่อร้านค้า, รหัสสาขา, บันทึกช่วยจำ) 
- 🌐 **Theming:** องรับ Dark Mode / Light Mode
- 🛡️ **100% On-Device Privacy:** ไม่มีการส่งรูปภาพหรือข้อมูลทางการเงินขึ้นเซิร์ฟเวอร์ภายนอก ทำงานแบบออฟไลน์ได้ ปลอดภัยขั้นสุด

---

## 🛠️ เทคโนโลยีที่ใช้ (Tech Stack)

โปรเจกต์นี้พัฒนาด้วยภาษา **Swift** แบบ Native 100% โดยใช้ Framework ล่าสุดจาก Apple:

- **UI Framework:** `SwiftUI`
- **Local Database:** `SwiftData`
- **Data Visualization:** `Swift Charts`
- **Machine Learning / OCR:** `Vision Framework` (VNRecognizeTextRequest)
- **Photo Access:** `PhotoKit`
- **Localization:** `String Catalog (.xcstrings)`

---

## 🚀 การติดตั้งและรันโปรเจกต์ (Getting Started)

1. Clone โปรเจกต์นี้ลงมาที่เครื่องของคุณ
   ```bash
   git clone [https://github.com/MarkCnw/SlipSense.git](https://github.com/MarkCnw/SlipSense.git)
