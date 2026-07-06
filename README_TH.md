<p align="center">
  <img src="https://github.com/user-attachments/assets/a9d0195f-7ca1-45fa-b707-4799577804b4" alt="SlipSense Logo" width="160">
</p>

<h1 align="center">
  SlipSense
</h1>

<p align="center">
  <strong>แอปพลิเคชัน iOS ที่ช่วยแปลงสลิปโอนเงินให้เป็นข้อมูลรายจ่ายโดยอัตโนมัติด้วยเทคโนโลยี OCR</strong>
</p>

<p align="center">
  ออกแบบภายใต้แนวคิด <strong>Privacy-First</strong> โดยประมวลผลและจัดเก็บข้อมูลทั้งหมดภายในอุปกรณ์ (<strong>100% On-Device</strong>) ไม่มีการส่งรูปภาพหรือข้อมูลทางการเงินไปยังเซิร์ฟเวอร์ภายนอก
</p>

<p align="center">

![Platform](https://img.shields.io/badge/iOS-17.0+-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-6-orange?logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-blue?logo=swift)
![MVVM](https://img.shields.io/badge/Architecture-MVVM-success)
![SwiftData](https://img.shields.io/badge/Database-SwiftData-red)
![Vision](https://img.shields.io/badge/OCR-Vision_Framework-purple)
![Charts](https://img.shields.io/badge/Charts-Swift_Charts-pink)

</p>

---

# 📖 ภาพรวมโปรเจกต์

SlipSense เป็นแอปพลิเคชัน iOS แบบ Native ที่พัฒนาด้วย **Swift** และ **SwiftUI** เพื่อช่วยให้การบันทึกรายจ่ายจากสลิปโอนเงินเป็นเรื่องอัตโนมัติ ลดการกรอกข้อมูลด้วยตนเอง และช่วยให้ผู้ใช้ติดตามพฤติกรรมการใช้จ่ายได้สะดวกยิ่งขึ้น

ระบบใช้ **Vision Framework** ของ Apple ในการอ่านข้อมูลจากรูปภาพสลิปด้วยเทคโนโลยี OCR จากนั้นวิเคราะห์ข้อมูล ระบุธนาคาร ดึงรายละเอียดของธุรกรรม และบันทึกลง **SwiftData** ก่อนนำข้อมูลมาแสดงผลผ่าน Dashboard แบบ Interactive

ข้อมูลทั้งหมดถูกประมวลผลและจัดเก็บภายในอุปกรณ์ (On-Device Processing) โดยไม่มีการอัปโหลดรูปภาพหรือข้อมูลทางการเงินไปยังเซิร์ฟเวอร์ภายนอก เพื่อรักษาความเป็นส่วนตัวของผู้ใช้อย่างสูงสุด

---

# ✨ ความสามารถหลัก

- 📸 สแกนสลิปโอนเงินจากคลังภาพโดยอัตโนมัติ
- 🔍 อ่านข้อความด้วย OCR ผ่าน Vision Framework
- 🏦 ตรวจจับและจำแนกธนาคารอัตโนมัติ
- 📊 Dashboard วิเคราะห์ข้อมูลการใช้จ่ายแบบ Real-time
- 🎙️ รองรับ Siri และ App Intents
- 🔎 ค้นหาประวัติธุรกรรมแบบ Full-Text Search
- 🔒 ประมวลผลข้อมูลทั้งหมดภายในอุปกรณ์ (100% On-Device)

---

# 🚀 ตัวอย่างการทำงานของแอป

## 📸 Smart Auto-Scan

เมื่อเปิดใช้งานครั้งแรก แอปจะค้นหาและสแกนสลิปโอนเงินทั้งหมดจากอัลบั้มรูปภาพโดยอัตโนมัติ

หลังจากการสแกนครั้งแรก ระบบ OCR จะทำงานเบื้องหลังเพื่อตรวจจับและประมวลผลสลิปใหม่ที่ถูกเพิ่มเข้ามา ทำให้ผู้ใช้ไม่จำเป็นต้องบันทึกรายจ่ายด้วยตนเองอีกต่อไป

https://github.com/user-attachments/assets/6f87294f-9fc3-4fcc-a17a-1b7850d7d758

---

## 📊 Interactive Dashboard

Dashboard แสดงภาพรวมการใช้จ่ายผ่านกราฟแบบ Interactive พร้อมรองรับ

- รายจ่ายประจำวัน
- สรุปรายสัปดาห์
- สรุปรายเดือน
- เลือกช่วงเวลาเอง (Custom Date Range)
- สัดส่วนค่าใช้จ่ายแยกตามธนาคาร
- วิเคราะห์ช่วงเวลาที่มีการใช้จ่ายมากที่สุด

https://github.com/user-attachments/assets/4974909c-a22b-496b-8e8b-b6349f84da4b

---

## 🎙️ Siri และ Apple Intelligence

SlipSense รองรับ **App Intents** เพื่อให้สามารถใช้งานร่วมกับ Siri และ Apple Intelligence ได้

ผู้ใช้สามารถถาม Siri ได้ เช่น

> "วันนี้ฉันใช้เงินไปเท่าไหร่ใน SlipSense"

หรือค้นหาข้อมูลผ่าน Spotlight ได้ทันทีโดยไม่ต้องเปิดแอป

https://github.com/user-attachments/assets/6a72e70c-7e27-43b3-adca-e7d2497794b2

https://github.com/user-attachments/assets/cb4e5a16-3606-4a24-b333-d5a70bcbf7fd

---

# 🌟 ฟีเจอร์หลัก

| ฟีเจอร์ | รายละเอียด |
|----------|-------------|
| 📸 Smart Auto Scan | ตรวจจับและสแกนสลิปโอนเงินใหม่จากคลังภาพโดยอัตโนมัติ |
| 🧠 Self Transfer Guard | ป้องกันการบันทึกข้อมูลซ้ำจากการโอนเงินระหว่างบัญชีของผู้ใช้ |
| 📊 Dashboard Analytics | วิเคราะห์ข้อมูลการใช้จ่ายผ่านกราฟและสถิติแบบ Interactive |
| 🔍 Full-Text Search | ค้นหาธุรกรรมจากข้อความทั้งหมดที่ OCR อ่านได้ |
| 🏦 Bank Detection | ตรวจจับและจำแนกธนาคารอัตโนมัติ |
| 🎙️ Siri Integration | เรียกดูข้อมูลผ่าน Siri และ App Intents |
| 🔒 On-Device Processing | ข้อมูลทั้งหมดถูกประมวลผลและจัดเก็บภายในอุปกรณ์ |

---

# 🛠 เทคโนโลยีที่ใช้

| หมวดหมู่ | เทคโนโลยี |
|----------|-----------|
| ภาษา | Swift |
| UI Framework | SwiftUI |
| สถาปัตยกรรม | MVVM |
| ฐานข้อมูล | SwiftData |
| OCR | Vision Framework |
| กราฟ | Swift Charts |
| คลังรูปภาพ | PhotoKit |
| Siri | App Intents |
| Localization | String Catalog |

---

# 🏛️ สถาปัตยกรรมของระบบ

SlipSense ถูกออกแบบภายใต้สถาปัตยกรรม **MVVM (Model–View–ViewModel)** เพื่อแยกส่วนของ Presentation, Business Logic และ Data Layer ออกจากกันอย่างชัดเจน ทำให้โค้ดสามารถดูแลรักษา ขยายระบบ และทดสอบได้ง่าย

```text
                 SwiftUI Views
                       │
                       ▼
             ViewModels (@Observable)
                       │
                       ▼
              Business Services
      ┌────────────┼────────────┐
      ▼            ▼            ▼
 OCR Service   Photo Service   Slip Parser
      │            │            │
      └────────────┴────────────┘
                       │
                       ▼
             SwiftData Persistence
```

---

# 📂 โครงสร้างโปรเจกต์

```text
SlipSense
│
├── Models
├── Views
├── ViewModels
├── Services
├── Intents
├── Utilities
├── Resources
└── Assets
```

| โฟลเดอร์ | หน้าที่ |
|----------|----------|
| Models | โมเดลข้อมูลและ SwiftData Schema |
| Views | ส่วนติดต่อผู้ใช้ด้วย SwiftUI |
| ViewModels | จัดการ State และ Presentation Logic |
| Services | OCR, การประมวลผลรูปภาพ, Parser และ Business Logic |
| Intents | รองรับ Siri และ App Intents |
| Utilities | Helper และ Extension ที่ใช้ร่วมกัน |
| Resources | ไฟล์ Localization และทรัพยากรของแอป |

---

# 🔄 กระบวนการประมวลผล OCR

```text
📷 PhotoKit
      │
      ▼
🖼 ปรับคุณภาพรูปภาพ
      │
      ▼
🔍 Vision OCR
      │
      ▼
🏦 Slip Parser
      │
      ▼
🧠 Self Transfer Guard
      │
      ▼
💾 SwiftData
      │
      ▼
📊 Dashboard
```

### ขั้นตอนการทำงาน

1. ดึงรูปสลิปใหม่จากคลังภาพผ่าน PhotoKit
2. ปรับคุณภาพของรูปภาพเพื่อเพิ่มความแม่นยำของ OCR
3. อ่านข้อความภาษาไทยและภาษาอังกฤษด้วย Vision Framework
4. วิเคราะห์ข้อมูลธุรกรรมและตรวจจับธนาคาร
5. ตรวจสอบและกรองรายการที่เป็นการโอนเงินระหว่างบัญชีของผู้ใช้
6. บันทึกข้อมูลที่ผ่านการตรวจสอบลง SwiftData
7. อัปเดต Dashboard และสถิติการใช้จ่ายแบบ Real-time

---

# ⚙️ ความท้าทายในการพัฒนา

| ความท้าทาย | วิธีแก้ไข | ผลลัพธ์ |
|------------|-----------|----------|
| OCR อ่านสลิปภาษาไทยคลาดเคลื่อน | Two-Pass OCR Pipeline | เพิ่มความแม่นยำในการอ่านข้อความ |
| รูปแบบสลิปของแต่ละธนาคารแตกต่างกัน | Bank-Specific Parsing | รองรับหลายธนาคารได้อย่างถูกต้อง |
| ธุรกรรมโอนเงินระหว่างบัญชีเดียวกัน | Self Transfer Guard | ป้องกันการบันทึกข้อมูลซ้ำ |
| การประมวลผลรูปภาพจำนวนมาก | Background Batch Scanning | ลดผลกระทบต่อประสิทธิภาพของ UI |
| ความเป็นส่วนตัวของข้อมูล | 100% On-Device Processing | ไม่มีข้อมูลทางการเงินออกจากอุปกรณ์ |

---

# 🚀 การติดตั้ง

```bash
git clone https://github.com/MarkCnw/SlipSense.git
cd SlipSense
open SlipSense.xcodeproj
```
