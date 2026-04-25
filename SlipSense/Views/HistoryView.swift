import SwiftUI
import SwiftData
import Photos

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SlipRecord.scanDate, order: .reverse) private var slips: [SlipRecord]
    
    @State private var searchText = ""
    @State private var selectedBank: BankType = .all // 💡 ใช้ Enum แทน String
    
    private let accentColor = Color.indigo
    
    let gridColumns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var filteredSlips: [SlipRecord] {
        var result = slips
        
        // 💡 กรองตามธนาคาร: เช็คว่าถ้าไม่ใช่ .all ให้เอา rawValue (String) ไปเทียบกับฐานข้อมูล
        if selectedBank != .all {
            result = result.filter { $0.bankName == selectedBank.rawValue }
        }
        
        if !searchText.isEmpty {
            result = result.filter { slip in
                let bank = BankType(rawValue: slip.bankName) ?? .unknown
                return String(slip.amount).localizedStandardContains(searchText) ||
                       bank.thaiName.localizedStandardContains(searchText) ||
                       slip.memo.localizedStandardContains(searchText)
            }
        }
        return result
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if searchText.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            // 💡 วนลูปจาก BankType.allCases ได้เลย ไม่ต้องพิมพ์ Array เอง
                            ForEach(BankType.allCases, id: \.self) { bank in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedBank = bank
                                    }
                                }) {
                                    VStack(spacing: 10) {
                                        BankLogoView(bank: bank, size: 54, isSelected: selectedBank == bank, accentColor: accentColor)
                                        
                                        Text(bank.shortName) // 💡 เรียกจาก Enum ตรงๆ
                                            .font(.system(size: 13, weight: selectedBank == bank ? .bold : .medium))
                                            .foregroundStyle(selectedBank == bank ? .primary : Color.gray)
                                    }
                                    .frame(width: 65)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .background(Color(.systemBackground))
                    Divider()
                }
                
                // MARK: - รายการประวัติ
                List {
                    if filteredSlips.isEmpty {
                        Text("ไม่มีประวัติรายจ่าย")
                            .foregroundStyle(.secondary)
                            .listRowSeparator(.hidden)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                    } else {
                        ForEach(filteredSlips) { slip in
                            let currentBank = BankType(rawValue: slip.bankName) ?? .unknown
                            
                            NavigationLink(destination: SlipImageDetailView(slip: slip)) {
                                HStack(spacing: 16) {
                                    BankLogoView(bank: currentBank, size: 42, accentColor: accentColor)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(currentBank == .unknown ? "รายการใช้จ่าย" : currentBank.thaiName)
                                            .font(.system(size: 16, weight: .semibold))
                                        
                                        Text(formatThaiDate(slip.scanDate))
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color.gray)
                                    }
                                    Spacer()
                                    Text("- \(slip.amount, format: .currency(code: "THB"))")
                                        .font(.system(size: 17, weight: .bold))
                                }
                                .padding(.vertical, 6)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    context.delete(slip)
                                } label: {
                                    Label("ลบ", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("ประวัติรายจ่าย")
            .searchable(text: $searchText, prompt: "ค้นหาด้วยยอดเงิน หรือ ชื่อธนาคาร")
        }
    }
    
    private func formatThaiDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        formatter.calendar = Calendar(identifier: .buddhist)
        formatter.dateFormat = "d MMM yyyy HH:mm 'น.'"
        return formatter.string(from: date)
    }
}

// MARK: - 🏦 Logo View (ปรับปรุงให้รับ BankType)
struct BankLogoView: View {
    let bank: BankType
    let size: CGFloat
    var isSelected: Bool = false
    let accentColor: Color
    
    var body: some View {
        ZStack {
            if bank == .all {
                Circle()
                    .fill(isSelected ? accentColor : accentColor.opacity(0.1))
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundStyle(isSelected ? .white : accentColor)
            } else if bank == .unknown {
                Circle()
                    .fill(Color(.systemGray6))
                Image(systemName: "ellipsis")
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundStyle(.gray)
            } else {
                Image(bank.logoName)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .background(Circle().fill(.white))
            }
        }
        .frame(width: size, height: size)
        .overlay(
            Circle()
                .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2.5)
                .padding(-4)
        )
        .shadow(color: isSelected ? accentColor.opacity(0.2) : .clear, radius: 8, y: 4)
    }
}
