จัดให้ครับ! การเพิ่ม 5 หัวข้อนี้เข้าไปจะเปลี่ยน README ธรรมดาให้กลายเป็น **"Technical Portfolio"** ระดับแนวหน้าที่พี่ๆ Tech Lead หรือ Recruiter สาย iOS เห็นแล้วต้องประทับใจแน่นอน เพราะมันแสดงให้เห็นว่าเราไม่ได้แค่เขียนโค้ดได้ แต่เรา **"ออกแบบระบบและแก้ปัญหาเป็น"** ครับ

ผมได้แทรกหัวข้อทั้งหมดเข้าไปในตำแหน่งที่เหมาะสม พร้อมเขียนเนื้อหาอิงจากโครงสร้างโค้ดจริงของแอป SlipSense แบบมืออาชีพให้แล้วครับ บอสก๊อปปี้โค้ดด้านล่างนี้ไปวางทับในไฟล์ `README.md` ได้เลยครับ:

---

```markdown
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

## 🏛️ โครงสร้างระบบ (Architecture & Data Flow)

### 1. Architecture Diagram (MVVM)
แอปพลิเคชันถูกออกแบบโดยแยกส่วน UI และ Business Logic ออกจากกันอย่างชัดเจน เพื่อให้ง่ายต่อการทดสอบและต่อยอดในอนาคต

```text
┌─────────────────┐       ┌──────────────────────┐       ┌──────────────────────┐
│     Views       │ ────> │     ViewModels       │ ────> │       Services       │
│ (SwiftUI, UI)   │ <──── │ (@Observable, State) │ <──── │ (Business/Core Logic)│
└─────────────────┘       └──────────────────────┘       └──────────┬───────────┘
                                                                    │
                                                                    v
                                                         ┌──────────────────────┐
                                                         │        Models        │
                                                         │ (SwiftData, Structs) │
                                                         └──────────────────────┘

```

### 2. Project Structure

โครงสร้างโฟลเดอร์ถูกจัดระเบียบตามหน้าที่การทำงาน (Feature-based / Layer-based):

* `Models/`: เก็บโครงสร้างข้อมูลและ Schema ของ `SwiftData` (`SlipRecord`, `BankType`)
* `Views/`: เก็บไฟล์ UI Component ทั้งหมด สร้างด้วย `SwiftUI`
* `ViewModels/`: จัดการสถานะและลอจิกของหน้าจอโดยใช้ Macro `@Observable`
* `Services/`: หัวใจหลักของแอปพลิเคชัน เช่น `OCRService`, `PhotoService`, `SlipParserService`
* `Intents/`: โค้ดสำหรับเชื่อมต่อ Apple Intelligence และ Siri Shortcuts

### 3. Data Flow (OCR Processing)

วัฏจักรการทำงานเมื่อระบบทำการสแกนรูปภาพสลิปแบบเบื้องหลัง (Background Batch Scanning):

1. **Fetch:** `PhotoService` ดึงรูปภาพใหม่จากอัลบั้มธนาคารผ่าน `PhotoKit`
2. **Pre-process:** `PhotoImageProvider` โหลดภาพความละเอียดสูง และ `OCRService` ปรับ Contrast/Saturation เพื่อให้ตัวอักษรชัดเจนขึ้น
3. **Extract:** ใช้ `Vision Framework` ดึงตัวอักษร (Text Recognition) ทั้งภาษาไทยและอังกฤษ
4. **Parse & Filter:**
* `SlipParserService` ใช้ Regex ดึงตัวเลขยอดเงินและชื่อธนาคาร
* `SlipSelfTransferGuard` คัดกรองและดรอปสลิปทิ้ง หากพบว่าเป็นชื่อของผู้ใช้โอนหากันเอง


5. **Save:** บันทึกข้อมูลที่สมบูรณ์ลงฐานข้อมูลผ่าน `SwiftData` และอัปเดตกราฟบน Dashboard ทันที

---

## ⚠️ ความท้าทายทางวิศวกรรม (Engineering Challenges)

1. **ความไม่แน่นอนของรูปแบบสลิป (Inconsistent Layouts) และภาษาไทย:**
* *ปัญหา:* สลิปแต่ละธนาคารมีการจัดวางตำแหน่งข้อความที่ต่างกัน และระบบ OCR ของ Apple บางครั้งอ่านตัวเลขติดกับภาษาไทยผิดเพี้ยน
* *วิธีแก้:* พัฒนาอัลกอริทึม **Two-Pass Scanning** ใน `OCRService` โดยสแกนภาพต้นฉบับ 1 รอบ และสแกนภาพที่ถูกดึง Contrast/Saturation ผ่าน `CIContext` อีก 1 รอบ พร้อมกับใช้ระบบ Regex ควบคู่กับ Keyword Blacklist/Whitelist ในการดึงยอดเงินที่แม่นยำที่สุด


2. **การกันยอดใช้จ่ายซ้ำซ้อน (Self-Transfer Duplication):**
* *ปัญหา:* ผู้ใช้มักจะโอนเงินระหว่างบัญชีของตัวเอง (เช่น ย้ายเงินจาก KBANK ไป SCB) ทำให้ระบบนับเป็น "รายจ่าย" เบิ้ล 2 ครั้ง
* *วิธีแก้:* สร้าง `SlipSelfTransferGuard` ขึ้นมาวิเคราะห์และเทียบชื่อ (Name Matching Algorithm) จากผู้ส่งและผู้รับ หากตรงกับชื่อผู้ใช้ที่ตั้งค่าไว้ ระบบจะข้ามสลิปใบนั้นโดยอัตโนมัติ


3. **การจัดการหน่วยความจำ (Memory Management & Concurrency):**
* *ปัญหา:* การสแกนรูปภาพความละเอียดสูงหลายร้อยรูปพร้อมกันทำให้แอปเกิดอาการค้าง (UI Freezes) และกิน RAM สูง
* *วิธีแก้:* ย้ายการทำงานทั้งหมดไปไว้บน Background Thread โดยใช้ `Task.detached` และสร้าง `SlipScanWorker` เป็น `actor` เพื่อป้องกัน Data Race รวมทั้งการ Reuse `CIContext` เพื่อลดภาระการจองหน่วยความจำ



---

## 🔮 แผนการพัฒนาในอนาคต (Future Improvements)

* [ ] **CoreML Integration:** เทรนโมเดล AI เพื่อจำแนกประเภทรายจ่ายอัตโนมัติ (อาหาร, เดินทาง, ช้อปปิ้ง) จากรูปโลโก้หรือชื่อร้านค้าบนสลิป
* [ ] **Export Data:** เพิ่มระบบ Export ข้อมูลรายจ่ายออกมาในรูปแบบไฟล์ `.csv` หรือ Excel
* [ ] **iCloud Sync:** ซิงค์ฐานข้อมูล `SwiftData` ผ่าน CloudKit เพื่อให้ใช้งานได้แบบไร้รอยต่อข้ามอุปกรณ์ Apple (iPhone, iPad, Mac)

---

## 🚀 การติดตั้งและรันโปรเจกต์ (Getting Started)

1. Clone โปรเจกต์นี้ลงมาที่เครื่องของคุณ
```bash
git clone [https://github.com/MarkCnw/SlipSense.git](https://github.com/MarkCnw/SlipSense.git)

```


2. เปิดไฟล์ด้วย `Xcode 15` หรือเวอร์ชันใหม่กว่า
3. แนะนำให้เลือกรันบน **iPhone เครื่องจริง (Physical Device)** เพื่อให้ฮาร์ดแวร์ Neural Engine ประมวลผล OCR ได้เต็มประสิทธิภาพ
4. กด `Cmd + R` เพื่อ Build และ Run แอปพลิเคชัน

```

```
