<p align="center">
  <img src="https://github.com/user-attachments/assets/a9d0195f-7ca1-45fa-b707-4799577804b4" alt="SlipSense Logo" width="160">
</p>

<h1 align="center">
  SlipSense
</h1>

<p align="center">
  <strong>แอปพลิเคชัน iOS ที่เปลี่ยนสลิปโอนเงินให้เป็นข้อมูลรายจ่ายโดยอัตโนมัติด้วยเทคโนโลยี OCR</strong>
</p>

<p align="center">
  ออกแบบภายใต้แนวคิด <strong>Privacy First</strong> โดยประมวลผลและจัดเก็บข้อมูลทั้งหมดภายในอุปกรณ์ (<strong>100% On-Device</strong>) โดยไม่มีการส่งรูปภาพหรือข้อมูลทางการเงินไปยังเซิร์ฟเวอร์ภายนอก
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

# 📖 ภาพรวมของโปรเจกต์

SlipSense เป็นแอปพลิเคชัน iOS แบบ Native ที่พัฒนาด้วย **Swift** และ **SwiftUI** เพื่อช่วยจัดการรายจ่ายจากสลิปโอนเงินโดยอัตโนมัติ

ระบบใช้ **Vision Framework** ของ Apple ในการอ่านข้อมูลจากรูปภาพสลิป (OCR) จากนั้นวิเคราะห์ข้อมูล ระบุธนาคาร ดึงรายละเอียดของธุรกรรม และบันทึกลง **SwiftData** เพื่อสร้างประวัติรายจ่ายและสรุปผลผ่าน Dashboard

ข้อมูลทั้งหมดถูกประมวลผลภายในอุปกรณ์ (On-Device Processing) โดยไม่มีการส่งรูปภาพหรือข้อมูลทางการเงินไปยังเซิร์ฟเวอร์ภายนอก

---

# ✨ ความสามารถหลัก

- 📸 สแกนสลิปจากคลังภาพโดยอัตโนมัติ
- 🔍 อ่านข้อความด้วย OCR ผ่าน Vision Framework
- 🏦 ตรวจจับและแยกประเภทธนาคารอัตโนมัติ
- 📊 Dashboard วิเคราะห์การใช้จ่ายแบบ Real-time
- 🎙️ รองรับ Siri และ App Intents
- 🔎 ค้นหาประวัติธุรกรรมแบบ Full-text Search
- 🔒 ประมวลผลข้อมูลภายในอุปกรณ์ 100%

---

# 🚀 การทำงานของแอป

## 📸 Smart Auto-Scan

เมื่อเปิดใช้งานครั้งแรก แอปจะค้นหาและสแกนสลิปทั้งหมดจากอัลบั้มธนาคารโดยอัตโนมัติ

หลังจากนั้น OCR จะทำงานแบบ Background เพื่อตรวจสอบสลิปใหม่ที่ถูกเพิ่มเข้ามา ทำให้ผู้ใช้ไม่จำเป็นต้องบันทึกรายจ่ายด้วยตนเอง

https://github.com/user-attachments/assets/6f87294f-9fc3-4fcc-a17a-1b7850d7d758

---

## 📊 Interactive Dashboard

Dashboard แสดงข้อมูลการใช้จ่ายผ่านกราฟแบบ Interactive พร้อมรองรับ

- รายจ่ายประจำวัน
- สรุปรายสัปดาห์
- สรุปรายเดือน
- กำหนดช่วงเวลาเอง
- สัดส่วนการใช้จ่ายแยกตามธนาคาร
- วิเคราะห์ช่วงเวลาที่มีการใช้จ่ายมากที่สุด

https://github.com/user-attachments/assets/4974909c-a22b-496b-8e8b-b6349f84da4b

---

## 🎙️ Siri และ Apple Intelligence

SlipSense รองรับการใช้งานร่วมกับ **App Intents** เพื่อให้สามารถเรียกใช้งานผ่าน Siri และ Apple Intelligence ได้

ตัวอย่างคำสั่ง

> "วันนี้ฉันใช้เงินไปเท่าไหร่ใน SlipSense"

หรือค้นหาผ่าน Spotlight ได้โดยไม่ต้องเปิดแอป

https://github.com/user-attachments/assets/6a72e70c-7e27-43b3-adca-e7d2497794b2

https://github.com/user-attachments/assets/cb4e5a16-3606-4a24-b333-d5a70bcbf7fd

---

# 🌟 ฟีเจอร์หลัก

| ฟีเจอร์ | รายละเอียด |
|---------|------------|
| 📸 Smart Auto Scan | ตรวจจับและสแกนสลิปใหม่จากคลังภาพโดยอัตโนมัติ |
| 🧠 Self Transfer Guard | ป้องกันการบันทึกธุรกรรมซ้ำจากการโอนระหว่างบัญชีของผู้ใช้ |
| 📊 Dashboard Analytics | วิเคราะห์พฤติกรรมการใช้จ่ายผ่านกราฟแบบ Interactive |
| 🔍 Full-text Search | ค้นหาข้อมูลจากข้อความทั้งหมดที่ OCR อ่านได้ |
| 🏦 Bank Detection | ตรวจจับและจำแนกธนาคารโดยอัตโนมัติ |
| 🎙️ Siri Integration | เรียกดูข้อมูลผ่าน Siri และ App Intents |
| 🔒 On-device Processing | ประมวลผลข้อมูลทั้งหมดภายในอุปกรณ์ |

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
| Photo Library | PhotoKit |
| Siri | App Intents |
| Localization | String Catalog |

---

# 🏛️ สถาปัตยกรรมของระบบ

SlipSense ถูกออกแบบภายใต้สถาปัตยกรรม **MVVM (Model-View-ViewModel)** เพื่อแยกส่วนการแสดงผล (Presentation) ออกจาก Business Logic และ Data Layer ทำให้โค้ดสามารถดูแลรักษา ทดสอบ และขยายระบบในอนาคตได้ง่าย

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
|-----------|---------|
| Models | โมเดลข้อมูลและ SwiftData Schema |
| Views | ส่วนติดต่อผู้ใช้ด้วย SwiftUI |
| ViewModels | จัดการ State และ Presentation Logic |
| Services | OCR, Parser และ Business Logic |
| Intents | Siri และ App Intents |
| Utilities | Helper และ Extension |
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
2. ปรับคุณภาพของรูปเพื่อเพิ่มความแม่นยำของ OCR
3. อ่านข้อความด้วย Vision Framework
4. วิเคราะห์ข้อมูลและตรวจจับธนาคาร
5. กรองธุรกรรมที่เป็นการโอนระหว่างบัญชีของผู้ใช้
6. บันทึกข้อมูลลง SwiftData
7. อัปเดต Dashboard แบบ Real-time

---

# ⚙️ ความท้าทายในการพัฒนา

| ความท้าทาย | วิธีแก้ไข | ผลลัพธ์ |
|------------|-----------|----------|
| OCR อ่านภาษาไทยคลาดเคลื่อน | Two-pass OCR Pipeline | เพิ่มความแม่นยำในการอ่าน |
| รูปแบบสลิปของแต่ละธนาคารแตกต่างกัน | Bank-specific Parsing | รองรับหลายธนาคาร |
| ธุรกรรมโอนเงินระหว่างบัญชีเดียวกัน | Self Transfer Guard | ลดข้อมูลซ้ำ |
| การประมวลผลรูปภาพจำนวนมาก | Background Batch Processing | ลดผลกระทบต่อประสิทธิภาพของ UI |
| ความเป็นส่วนตัวของข้อมูล | On-device Processing | ไม่มีข้อมูลออกจากอุปกรณ์ |

---

# 🚀 การติดตั้ง

```bash
git clone https://github.com/MarkCnw/SlipSense.git
cd SlipSense
open SlipSense.xcodeproj
```
