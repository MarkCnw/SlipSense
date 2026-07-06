<h1 align="center">💸 SlipSense</h1>

<p align="center">
An intelligent native iOS expense tracking application that automatically converts bank transfer receipts into structured expense records using OCR technology.
</p>

<p align="center">
Designed with privacy-first principles, all receipt processing and financial data remain <strong>100% on-device</strong> without relying on external servers.
</p>

<p align="center">

![Platform](https://img.shields.io/badge/iOS-17.0+-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-6-orange?logo=swift)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-success)
![Database](https://img.shields.io/badge/Database-SwiftData-red)
![OCR](https://img.shields.io/badge/OCR-Vision_Framework-purple)
![Charts](https://img.shields.io/badge/Charts-Swift_Charts-pink)

</p>

---

# 📖 Overview

SlipSense is a native iOS application built with **Swift** and **SwiftUI** that eliminates manual expense logging by automatically extracting financial information from bank transfer receipts.

Using Apple's **Vision Framework**, the application recognizes receipt content, identifies the originating financial institution, extracts transaction details, and stores them locally using **SwiftData**. All processing is performed directly on the device, ensuring complete privacy without cloud processing.

---

# ✨ Key Highlights

- 📸 Automatic receipt scanning from the Photos library
- 🔍 OCR-powered text recognition using Apple's Vision Framework
- 🏦 Automatic bank identification and transaction parsing
- 📊 Interactive spending dashboard with real-time analytics
- 🎙️ Siri & App Intents integration
- 🔎 Full-text transaction search
- 🔒 100% On-device processing with no external servers

---

# 🚀 App Showcase

## 📸 Smart Auto-Scan

Automatically detects newly added bank transfer receipts from the user's photo library.

During the initial launch, SlipSense scans the existing receipt album. Afterwards, the OCR pipeline continuously processes newly added receipts in the background, eliminating the need for manual expense entry.

https://github.com/user-attachments/assets/6f87294f-9fc3-4fcc-a17a-1b7850d7d758

---

## 📊 Interactive Dashboard

Visualize spending habits through an interactive dashboard featuring:

- Daily Spending
- Weekly Summary
- Monthly Analytics
- Custom Date Range
- Bank Distribution Chart
- Time-of-Day Spending Analysis

https://github.com/user-attachments/assets/4974909c-a22b-496b-8e8b-b6349f84da4b

---

## 🎙️ Siri & Apple Intelligence

SlipSense integrates with **App Intents** to support Siri and Apple Intelligence.

Users can ask questions such as:

> "How much did I spend today in SlipSense?"

or search directly from Spotlight without opening the application.

https://github.com/user-attachments/assets/6a72e70c-7e27-43b3-adca-e7d2497794b2

https://github.com/user-attachments/assets/cb4e5a16-3606-4a24-b333-d5a70bcbf7fd

---

# 🌟 Features

| Feature | Description |
|---------|-------------|
| 📸 Smart Auto Scan | Automatically detects and scans newly added bank transfer receipts |
| 🧠 Self Transfer Guard | Prevents duplicate expense records by identifying transfers between the user's own accounts |
| 📊 Dashboard Analytics | Interactive charts for spending insights and financial trends |
| 🔍 Full-text Search | Search transactions using any recognized receipt content |
| 🏦 Bank Detection | Automatically identifies supported financial institutions |
| 🎙️ Siri Integration | Query spending information through Siri and App Intents |
| 🔒 On-device Processing | No cloud storage or external server communication |

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
| Photo Access | PhotoKit |
| Siri Integration | App Intents |
| Localization | String Catalog |

---

# 🏛 Architecture

SlipSense follows the **MVVM (Model-View-ViewModel)** architecture to clearly separate presentation, business logic, and data management.

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
|---------|---------------|
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
(Contrast Enhancement)
      │
      ▼
🔍 Vision OCR
(Text Recognition)
      │
      ▼
🏦 Slip Parser
(Bank Detection + Regex)
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
3. Extract Thai and English text using Apple's Vision Framework.
4. Parse transaction details and identify the financial institution.
5. Detect and ignore self-transfer transactions.
6. Store validated records in SwiftData.
7. Instantly refresh dashboard analytics.

---

# ⚙️ Engineering Challenges

| Challenge | Solution | Result |
|-----------|----------|--------|
| OCR accuracy on Thai receipts | Two-pass OCR pipeline | Improved recognition accuracy |
| Different receipt layouts across banks | Bank-specific parsing strategy | Reliable extraction across multiple banks |
| Duplicate records from self-transfers | Self Transfer Guard | Prevented duplicate expense entries |
| Large-scale receipt processing | Background batch scanning | Smooth performance with minimal UI impact |
| User privacy | 100% On-device processing | No financial data leaves the device |

---

# 🚀 Getting Started

```bash
git clone https://github.com/MarkCnw/SlipSense.git
cd SlipSense
open SlipSense.xcodeproj
```


