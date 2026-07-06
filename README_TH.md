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
  Designed with a <strong>Privacy-First</strong> approach, all receipt processing and financial data remain <strong>100% on-device</strong>, with no images or financial information ever sent to external servers.
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

Powered by Apple's **Vision Framework**, the application extracts text from receipt images using OCR, identifies the issuing financial institution, parses transaction details, and stores the processed data locally with **SwiftData**. Users can then visualize their spending through an interactive analytics dashboard.

All receipt processing is performed entirely on the device, ensuring complete privacy without uploading images or financial data to external servers.

---

# ✨ Key Highlights

- 📸 Automatically scans bank transfer receipts from the Photos library
- 🔍 OCR-powered text recognition using Apple's Vision Framework
- 🏦 Automatic bank identification and transaction parsing
- 📊 Interactive dashboard with real-time spending analytics
- 🎙️ Siri & App Intents integration
- 🔎 Full-text transaction search
- 🔒 100% on-device processing with no cloud dependency

---

# 🚀 App Showcase

## 📸 Smart Auto-Scan

On the first launch, SlipSense automatically scans all existing bank transfer receipts stored in the user's Photos library.

After the initial scan, the OCR pipeline continuously detects and processes newly added receipts in the background, eliminating the need for manual expense logging.

https://github.com/user-attachments/assets/6f87294f-9fc3-4fcc-a17a-1b7850d7d758

---

## 📊 Interactive Dashboard

Visualize spending habits through an interactive dashboard featuring:

- Daily Spending
- Weekly Summary
- Monthly Analytics
- Custom Date Range
- Bank Distribution
- Time-of-Day Spending Analysis

https://github.com/user-attachments/assets/4974909c-a22b-496b-8e8b-b6349f84da4b

---

## 🎙️ Siri & Apple Intelligence

SlipSense integrates with **App Intents** to support Siri and Apple Intelligence.

Users can ask Siri questions such as:

> "How much did I spend today in SlipSense?"

or search directly from Spotlight without opening the application.

https://github.com/user-attachments/assets/6a72e70c-7e27-43b3-adca-e7d2497794b2

https://github.com/user-attachments/assets/cb4e5a16-3606-4a24-b333-d5a70bcbf7fd

---

# 🌟 Features

| Feature | Description |
|----------|-------------|
| 📸 Smart Auto Scan | Automatically detects and scans newly added bank transfer receipts |
| 🧠 Self Transfer Guard | Prevents duplicate expense records by identifying transfers between the user's own bank accounts |
| 📊 Dashboard Analytics | Interactive charts for spending insights and financial trends |
| 🔍 Full-Text Search | Search transactions using any recognized text from receipts |
| 🏦 Bank Detection | Automatically identifies supported financial institutions |
| 🎙️ Siri Integration | Access spending information through Siri and App Intents |
| 🔒 On-Device Processing | All receipt processing and financial data remain on the device |

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

SlipSense follows the **MVVM (Model–View–ViewModel)** architecture to clearly separate presentation, business logic, and data management, resulting in a codebase that is maintainable, scalable, and easy to test.

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
|----------|---------------|
| Models | Domain models and SwiftData schemas |
| Views | SwiftUI user interface |
| ViewModels | UI state management and presentation logic |
| Services | OCR, image processing, parsing, and business logic |
| Intents | Siri and App Intents integration |
| Utilities | Shared helpers and extensions |
| Resources | Localization files and application resources |

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
4. Parse transaction details and identify the issuing financial institution.
5. Detect and ignore transfers between the user's own bank accounts.
6. Store validated transaction records in SwiftData.
7. Refresh dashboard analytics in real time.

---

# ⚙️ Engineering Challenges

| Challenge | Solution | Result |
|-----------|----------|--------|
| OCR inaccuracies on Thai receipts | Two-pass OCR pipeline | Improved text recognition accuracy |
| Different receipt layouts across banks | Bank-specific parsing strategy | Reliable extraction across multiple banks |
| Duplicate records from self-transfers | Self Transfer Guard | Prevented duplicate expense entries |
| Processing large numbers of receipts | Background batch scanning | Smooth performance with minimal UI impact |
| Protecting user privacy | 100% on-device processing | No financial data leaves the device |

---

# 🚀 Getting Started

```bash
git clone https://github.com/MarkCnw/SlipSense.git
cd SlipSense
open SlipSense.xcodeproj
```
