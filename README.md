# 💸 SlipSense

**SlipSense** คือแอปพลิเคชันจัดการการเงินบน iOS ที่ช่วยเปลี่ยน **"รูปสลิปโอนเงิน"** ในคลังภาพของคุณ ให้กลายเป็น **"บันทึกรายจ่ายอัตโนมัติ"** ได้ทันที โดยที่คุณไม่ต้องนั่งพิมพ์เอง ข้อมูลทั้งหมดถูกประมวลผลและจัดเก็บไว้ภายในเครื่องของคุณเท่านั้น ปลอดภัย 100%

---

## 🚀 สรุปการทำงาน (App Showcase)

### 1. Smart Auto-Scan (สแกนอัตโนมัติ)
เมื่อเข้าแอปครั้งแรก ระบบจะทำการดึงสลิปจากอัลบั้มธนาคารมาสแกนโดยอัตโนมัติ และในครั้งต่อไป OCR จะทำงานเบื้องหลังเพื่ออัปเดตข้อมูลทันทีที่มีสลิปใหม่เข้ามาในเครื่อง ช่วยลดเวลาการทำบัญชีได้อย่างสมบูรณ์แบบ

https://github.com/user-attachments/assets/6f87294f-9fc3-4fcc-a17a-1b7850d7d758

### 2. Interactive Dashboard (แดชบอร์ดสรุปรายจ่าย)
เมื่อประมวลผลเสร็จสิ้น ระบบจะจัดหมวดหมู่การใช้จ่ายผ่านกราฟที่เข้าใจง่าย รองรับการกรองช่วงเวลา (วันนี้, สัปดาห์นี้, เดือนนี้, เลือกเอง) และดูสัดส่วนการใช้จ่ายแยกตามธนาคาร

https://github.com/user-attachments/assets/4974909c-a22b-496b-8e8b-b6349f84da4b

### 3. Siri & App Intents (สั่งงานด้วยเสียงหรือพิมพ์ผ่านช่องค้นหา)
เข้าถึงข้อมูลทางการเงินได้รวดเร็วขึ้นผ่าน Apple Intelligence และ Siri ผู้ใช้สามารถพูดถามยอดใช้จ่ายของวันนี้ได้ทันที เช่น *"ฉันใช้เงินไปเท่าไหร่ในแอป SlipSense"* หรือพิมพ์ค้นหาในหน้า Home ว่า *"ยอดใช้จ่ายวันนี้"*

https://github.com/user-attachments/assets/6a72e70c-7e27-43b3-adca-e7d2497794b2

https://github.com/user-attachments/assets/cb4e5a16-3606-4a24-b333-d5a70bcbf7fd

---

## ✨ ฟีเจอร์เด่น (Key Features)

- 📸 **Auto Slip Scanner (สแกนสลิปอัตโนมัติ):** ดึงข้อมูลยอดเงิน วันเวลา และชื่อธนาคารจากสลิปโอนเงินในเครื่องได้เองโดยไม่ต้องพิมพ์ ด้วยอัลกอริทึมสแกน 2 รอบ (Two-Pass Scanning) เพิ่มความแม่นยำในการอ่านภาษาไทย
- 🧠 **Self-Transfer Guard (ระบบกันยอดซ้ำ):** ระบบตรวจสอบชื่อผู้โอนและผู้รับ หากเป็นการโอนเงินระหว่างบัญชีตัวเอง จะข้ามการคำนวณยอดนั้นอัตโนมัติ
- 📊 **Smart Dashboard (แดชบอร์ดอัจฉริยะ):**
  - **Dynamic Donut Chart:** สรุปสัดส่วนการใช้จ่ายแยกตามธนาคาร
  - **Daily Bar Chart:** กราฟสรุปเทรนด์การใช้เงินย้อนหลัง
  - **Time-Spend Analysis:** วิเคราะห์เจาะลึกช่วงเวลาที่คุณเสียเงินมากที่สุด (เช้า, บ่าย, ค่ำ, ดึก)
- 🔍 **Full-Text Search (ค้นหาอัจฉริยะ):** ค้นหาประวัติการโอนเงินจากทุกข้อความบนสลิป (เช่น ชื่อร้านค้า, รหัสสาขา, บันทึกช่วยจำ) 
- 🌓 **Adaptive UI:** รองรับการปรับเปลี่ยนธีม Dark Mode / Light Mode แบบสมบูรณ์
- 🛡️ **100% On-Device Privacy:** ไม่มีการส่งรูปภาพหรือข้อมูลทางการเงินขึ้นเซิร์ฟเวอร์ภายนอก ทำงานแบบออฟไลน์ได้ ปลอดภัยขั้นสุด

---

## 🛠️ สถาปัตยกรรมและเทคโนโลยี (Architecture & Tech Stack)

โปรเจกต์นี้พัฒนาด้วยภาษา **Swift** แบบ Native 100% ภายใต้สถาปัตยกรรม **MVVM (Model-View-ViewModel)** และใช้ Framework ล่าสุดจาก Apple:

- **UI Framework:** `SwiftUI`
- **Local Database:** `SwiftData`
- **Data Visualization:** `Swift Charts`
- **Machine Learning / OCR:** `Vision Framework` (VNRecognizeTextRequest)
- **Photo Access:** `PhotoKit`
- **System Integration:** `AppIntents` (Siri Shortcuts)
- **Localization:** `String Catalog (.xcstrings)`

---

## 🚀 การติดตั้งและรันโปรเจกต์ (Getting Started)

1. Clone โปรเจกต์นี้ลงมาที่เครื่องของคุณ
   ```bash
   git clone [https://github.com/MarkCnw/SlipSense.git](https://github.com/MarkCnw/SlipSense.git)
