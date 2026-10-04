import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SlipRecord.scanDate, order: .reverse) private var slips: [SlipRecord]
    @State private var viewModel = HistoryViewModel()
    
    // 💡 1. เปลี่ยนมาใช้ Set เพื่อให้รองรับการเลือกหลายธนาคารพร้อมกันได้ (Multi-select)
    @State private var selectedBanks: Set<String> = []
    
    // จัดอันดับธนาคารจากที่ใช้บ่อยสุด
    var dynamicBankFilters: [String] {
        let grouped = Dictionary(grouping: slips, by: { $0.bankName })
        let sorted = grouped.sorted { $0.value.count > $1.value.count }
        return sorted.map { $0.key }
    }
    
    private var displaySlips: [SlipRecord] {
        let searchedSlips = viewModel.getFilteredSlips(from: slips)
        return searchedSlips.filter { slip in
            selectedBanks.isEmpty || selectedBanks.contains(slip.bankName)
        }
    }
    
    private var groupedSlips: [SlipDateGroup] {
        viewModel.groupSlipsByDate(displaySlips)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if displaySlips.isEmpty {
                    emptyStateView
                } else {
                    slipListView
                }
            }
            .navigationTitle("ประวัติรายจ่าย")
            .searchable(text: $viewModel.searchText, prompt: "ค้นหาธนาคาร, ยอดเงิน...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterMenu
                }
            }
            .onAppear {
                SlipWidgetDataManager.shared.updateTodayExpense(from: slips)
            }
            .onChange(of: slips) { _, newSlips in
                SlipWidgetDataManager.shared.updateTodayExpense(from: newSlips)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image("Analyze-Data-2--Streamline-Manila")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .grayscale(1.0)
                .opacity(0.6)
            
            Text(slips.isEmpty ? "ยังไม่มีสลิปที่สแกน" : "ไม่พบข้อมูลที่ค้นหา")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var slipListView: some View {
        List {
            ForEach(groupedSlips) { group in
                Section {
                    ForEach(group.slips) { slip in
                        slipRow(for: slip)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteSlip(group.slips[index], context: context)
                        }
                    }
                } header: {
                    sectionHeader(for: group)
                }
            }
        }
        .listStyle(.plain)
    }
    
    private func slipRow(for slip: SlipRecord) -> some View {
        NavigationLink(destination: SlipImageDetailView(slip: slip)) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    if !slip.memo.isEmpty {
                        Text(slip.memo)
                            .font(.system(.body, weight: .medium))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Text(slip.bankName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            if shouldShowCategory(slip.category) {
                                Text("•")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                                
                                categoryBadge(slip.category)
                            }
                            
                            Text("•")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                            
                            Text(slip.scanDate.formatted(.dateTime.hour().minute().locale(Locale(identifier: "th_TH"))))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text(slip.bankName)
                            .font(.system(.body, weight: .medium))
                            .foregroundStyle(.primary)
                        
                        HStack(spacing: 6) {
                            if shouldShowCategory(slip.category) {
                                categoryBadge(slip.category)
                                
                                Text("•")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            
                            Text(slip.scanDate.formatted(.dateTime.hour().minute().locale(Locale(identifier: "th_TH"))))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(slip.amount.formatted(.number.precision(.fractionLength(2)))) บาท")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(slip.isSelfTransfer ? .secondary : .primary)
                    
                    if slip.isSelfTransfer {
                        Text("โอนให้ตัวเอง")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func shouldShowCategory(_ category: String) -> Bool {
        let trimmed = category.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed != "ทั่วไป" && trimmed != "อื่นๆ" && trimmed != "ไม่มีหมวดหมู่"
    }
    
    private func categoryBadge(_ category: String) -> some View {
        Text(category)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color(.tertiarySystemFill))
            .clipShape(Capsule())
    }
    
    private func sectionHeader(for group: SlipDateGroup) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(group.header)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("รวม")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("\(group.totalAmount.formatted(.number.precision(.fractionLength(2)))) บาท")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 2)
    }
    
    private var filterMenu: some View {
        Menu {
            if !selectedBanks.isEmpty {
                Button(role: .destructive) {
                    withAnimation(.snappy) {
                        selectedBanks.removeAll()
                    }
                } label: {
                    Label("ล้างตัวกรองทั้งหมด", systemImage: "xmark.circle")
                }
                Divider()
            }
            
            ForEach(dynamicBankFilters, id: \.self) { bank in
                Button {
                    withAnimation(.snappy) {
                        if selectedBanks.contains(bank) {
                            selectedBanks.remove(bank)
                        } else {
                            selectedBanks.insert(bank)
                        }
                    }
                } label: {
                    if selectedBanks.contains(bank) {
                        Label(bank, systemImage: "checkmark")
                    } else {
                        Text(bank)
                    }
                }
            }
        } label: {
            Image(systemName: selectedBanks.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                .font(.title3)
                .foregroundColor(selectedBanks.isEmpty ? .primary : .blue)
        }
    }
}
