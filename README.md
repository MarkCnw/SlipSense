<p align="center">
  <img src="https://github.com/user-attachments/assets/a9d0195f-7ca1-45fa-b707-4799577804b4" alt="SlipSense Logo" width="160">
</p>

<h1 align="center">
  SlipSense
</h1>

<p align="center">
  <strong>An iOS application that automatically transforms bank transfer receipts into structured expense records using OCR technology.</strong>
</p>

<p align="center">
  Designed with a <strong>Privacy-First</strong> approach, all receipt processing and financial data remain <strong>100% on-device</strong>, with no external servers or cloud processing involved.
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

# 📖 Overview

SlipSense is a native iOS application built with **Swift** and **SwiftUI** that automatically converts bank transfer receipts into structured expense records.

Using Apple's **Vision Framework**, the application extracts text from receipt images, identifies the originating financial institution, parses transaction details, and stores them locally using **SwiftData**. The processed data is then visualized through an interactive analytics dashboard.

All receipt processing is performed directly on the device, ensuring complete privacy without uploading images or financial information to external servers.

---

# ✨ Key Highlights

- 📸 Automatic receipt scanning from the Photos library
- 🔍 OCR-powered text recognition using Apple's Vision Framework
- 🏦 Automatic bank identification and transaction parsing
- 📊 Interactive spending dashboard with real-time analytics
- 🎙️ Siri & App Intents integration
- 🔎 Full-text transaction search
- 🔒 100% on-device processing with no cloud dependency

---

# 🚀 App Showcase

## 📸 Smart Auto-Scan

On first launch, SlipSense automatically scans existing bank transfer receipts stored in the user's photo library.

After the initial scan, the OCR pipeline continuously monitors and processes newly added receipts in the background, eliminating the need for manual expense logging.

[Demo Video]

---

## 📊 Interactive Dashboard

Visualize spending habits through an interactive dashboard featuring:

- Daily Spending Analysis
- Weekly Summary
- Monthly Analytics
- Custom Date Range Filtering
- Bank Distribution Chart
- Time-of-Day Spending Insights

[Demo Video]

---

## 🎙️ Siri & Apple Intelligence

SlipSense integrates with **App Intents** to support Siri and Apple Intelligence.

Users can ask questions such as:

> "How much did I spend today in SlipSense?"

or search directly from Spotlight without opening the application.

[Demo Video]

---

# 🌟 Features

| Feature | Description |
|----------|-------------|
| 📸 Smart Auto Scan | Automatically detects and processes newly added bank transfer receipts |
| 🧠 Self Transfer Guard | Prevents duplicate expense records caused by transfers between the user's own accounts |
| 📊 Dashboard Analytics | Interactive charts and spending insights |
| 🔍 Full-Text Search | Search transactions using any recognized receipt content |
| 🏦 Bank Detection | Automatically identifies supported financial institutions |
| 🎙️ Siri Integration | Query spending information through Siri and App Intents |
| 🔒 On-Device Processing | All data remains on the user's device |

---

# 🛠 Tech Stack

| Category | Technology |
|----------|------------|
| Language | Swift |
| UI Framework | SwiftUI |
| Architecture | MVVM |
| Database | SwiftData |
| OCR | Vision Framework |
| Charts | Swift Charts |
| Photo Library | PhotoKit |
| Siri Integration | App Intents |
| Localization | String Catalog |

---

# 🏛 Architecture

SlipSense follows the **MVVM (Model-View-ViewModel)** architecture to separate presentation, business logic, and data management responsibilities.

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
├── Resources
└── Assets
```

| Folder | Responsibility |
|----------|---------------|
| Models | Domain models and SwiftData schemas |
| Views | SwiftUI user interface |
| ViewModels | UI state management and presentation logic |
| Services | OCR, parsing, image processing, and business logic |
| Intents | Siri and App Intents integration |
| Utilities | Shared helpers and extensions |
| Resources | Localization and supporting resources |

---

# 🔄 OCR Processing Pipeline

```text
📷 PhotoKit
      │
      ▼
🖼 Image Pre-processing
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

### Processing Flow

1. Retrieve newly added receipt images from the Photos library.
2. Enhance image quality to improve OCR accuracy.
3. Extract Thai and English text using Vision Framework.
4. Parse transaction information and identify the financial institution.
5. Detect and ignore self-transfer transactions.
6. Store validated records in SwiftData.
7. Refresh dashboard analytics in real time.

---

# ⚙️ Engineering Challenges

| Challenge | Solution | Result |
|------------|----------|---------|
| OCR inaccuracies on Thai receipts | Two-pass OCR pipeline | Improved recognition accuracy |
| Different receipt formats across banks | Bank-specific parsing strategy | Reliable extraction across multiple banks |
| Duplicate records from self-transfers | Self Transfer Guard | Eliminated duplicate expense entries |
| Large-scale image processing | Background batch scanning | Minimal impact on UI performance |
| User privacy concerns | 100% on-device processing | No financial data leaves the device |

---

# 🚀 Getting Started

```bash
git clone https://github.com/MarkCnw/SlipSense.git
cd SlipSense
open SlipSense.xcodeproj
```
