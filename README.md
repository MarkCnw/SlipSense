# 💸 SlipSense

> **SlipSense** คือแอปพลิเคชันจัดการการเงินบน iOS ที่ช่วยเปลี่ยน **รูปสลิปโอนเงิน** ให้กลายเป็น **บันทึกรายจ่ายอัตโนมัติ** ด้วยเทคโนโลยี OCR โดยข้อมูลทั้งหมดถูกประมวลผลและจัดเก็บ **ภายในอุปกรณ์ (On-Device)** เพื่อความเป็นส่วนตัวและความปลอดภัยสูงสุด

---

# 🚀 App Showcase

## 📸 Smart Auto-Scan

เมื่อเปิดแอปครั้งแรก ระบบจะค้นหาและสแกนสลิปจากอัลบั้มธนาคารโดยอัตโนมัติ หลังจากนั้น OCR จะทำงานแบบ Background เพื่อค้นหาและประมวลผลสลิปใหม่ทันทีที่ถูกบันทึกลงในเครื่อง ช่วยลดการบันทึกรายจ่ายด้วยตนเองทั้งหมด โดยผู้ใช้ไม่ต้องมากรอกเเละกดสเเกนใหม่ให้เสียเวลาเเค่จ่ายเงินผ่านธนาคารยอดเงินจะอัพเดทอัตโนมัติ

https://github.com/user-attachments/assets/6f87294f-9fc3-4fcc-a17a-1b7850d7d758

---

## 📊 Interactive Dashboard

Dashboard แสดงภาพรวมการใช้จ่ายผ่านกราฟแบบ Interactive พร้อมรองรับการกรองข้อมูลตามช่วงเวลา

- Today
- This Week
- This Month
- Custom Range

รวมถึงสรุปค่าใช้จ่ายแยกตามธนาคารแบบ Real-time

https://github.com/user-attachments/assets/4974909c-a22b-496b-8e8b-b6349f84da4b

---

## 🎙️ Siri & App Intents

ผู้ใช้สามารถเรียกดูข้อมูลการเงินผ่าน Siri หรือ Apple Intelligence ได้ทันที เช่น

> "ฉันใช้เงินไปเท่าไหร่ในแอป SlipSense"

หรือค้นหาผ่าน Spotlight ด้วยคำว่า

> "ยอดใช้จ่ายวันนี้"

https://github.com/user-attachments/assets/6a72e70c-7e27-43b3-adca-e7d2497794b2

https://github.com/user-attachments/assets/cb4e5a16-3606-4a24-b333-d5a70bcbf7fd

---

# ✨ Key Features

### 📸 Auto Slip Scanner

- Automatic bank slip detection
- Two-Pass OCR Pipeline
- Thai & English text recognition
- Automatic amount extraction

---

### 🧠 Self-Transfer Guard

ป้องกันการนับรายการซ้ำ โดยตรวจสอบชื่อผู้โอนและผู้รับ หากเป็นการโอนระหว่างบัญชีของผู้ใช้ ระบบจะละเว้นรายการดังกล่าวโดยอัตโนมัติ

---

### 📊 Smart Dashboard

- Dynamic Donut Chart
- Daily Spending Chart
- Time-of-Day Spending Analysis
- Real-time Statistics

---

### 🔍 Full-Text Search

ค้นหาข้อมูลจากข้อความทั้งหมดบนสลิป เช่น

- ร้านค้า
- หมายเลขอ้างอิง
- บันทึกช่วยจำ
- รหัสสาขา

---

### 🛡️ 100% On-Device Privacy

- No Cloud Storage
- No External Server
- Offline Processing
- Local Data Only

---

# 🛠️ Architecture & Tech Stack

## Tech Stack

| Category | Technology |
|----------|------------|
| Language | Swift |
| UI | SwiftUI |
| Architecture | MVVM |
| Local Database | SwiftData |
| Charts | Swift Charts |
| OCR | Vision Framework |
| Photo Library | PhotoKit |
| Siri Integration | AppIntents |
| Localization | String Catalog |

---

# 🏛️ Architecture

SlipSense ถูกออกแบบภายใต้สถาปัตยกรรม **MVVM (Model-View-ViewModel)** โดยแยก Presentation, Business Logic และ Data Layer ออกจากกันอย่างชัดเจน เพื่อให้ระบบสามารถดูแลรักษา ขยายต่อ และทดสอบได้ง่าย

```text
                 SwiftUI Views
                      │
                      ▼
              ViewModels (@Observable)
                      │
                      ▼
            Services / Business Logic
        ┌────────────┼────────────┐
        ▼            ▼            ▼
 OCR Service   Photo Service   Parser Service
        │            │            │
        └────────────┴────────────┘
                      │
                      ▼
          Models / SwiftData Storage
```

---

# 📂 Project Structure

```text
SlipSense
│
├── Models
├── Views
├── ViewModels
├── Services
├── Intents
├── Utilities
└── Resources
```

| Folder | Responsibility |
|---------|---------------|
| Models | SwiftData Models และ Domain Models |
| Views | SwiftUI Views |
| ViewModels | UI State และ Presentation Logic |
| Services | OCR, Parser, Photo Processing และ Business Logic |
| Intents | Siri และ Apple Intelligence |
| Utilities | Helper และ Shared Components |

---

# 🔄 OCR Processing Pipeline

```text
PhotoKit
    │
    ▼
PhotoService
    │
    ▼
Image Pre-processing
(Contrast / Saturation)
    │
    ▼
Vision OCR
(Text Recognition)
    │
    ▼
SlipParserService
(Regex + Bank Detection)
    │
    ▼
SelfTransferGuard
    │
    ▼
SwiftData
    │
    ▼
Dashboard
```

### Processing Steps

1. ดึงรูปภาพจากอัลบั้มธนาคารผ่าน PhotoKit
2. ปรับคุณภาพภาพเพื่อเพิ่มความแม่นยำของ OCR
3. อ่านข้อความด้วย Vision Framework
4. วิเคราะห์ข้อมูลด้วย Regex และ Bank Detection
5. ตรวจสอบธุรกรรมโอนเงินระหว่างบัญชีของผู้ใช้
6. บันทึกลง SwiftData
7. อัปเดต Dashboard แบบ Real-time

---

# 🚀 Getting Started

```bash
git clone https://github.com/MarkCnw/SlipSense.git
```
