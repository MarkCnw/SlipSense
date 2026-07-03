import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SlipRecord.scanDate, order: .reverse) private var slips: [SlipRecord]
    @State private var viewModel = HistoryViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                let displaySlips = viewModel.getFilteredSlips(from: slips)
                
                if displaySlips.isEmpty {
                    // กรณีไม่มีข้อมูล
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundStyle(.tertiary)
                        Text(viewModel.searchText.isEmpty ? "ยังไม่มีประวัติการสแกน" : "ไม่พบข้อมูลที่ค้นหา")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // กรณีมีข้อมูล วาด List ตามปกติ
                    List {
                        ForEach(displaySlips) { slip in
                            NavigationLink(destination: SlipImageDetailView(slip: slip)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(slip.bankName)
                                            .font(.headline)
                                        Text(slip.scanDate.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(slip.amount.formatted(.currency(code: "THB")))
                                        .font(.headline)
                                        // ทำให้สลิปโอนตัวเองสีซีดลงนิดนึง
                                        .foregroundStyle(slip.isSelfTransfer ? .secondary : .primary)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteSlip(displaySlips[index], context: context)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("ประวัติรายจ่าย")
            .searchable(text: $viewModel.searchText, prompt: "ค้นหาธนาคาร, ยอดเงิน...")
        }
    }
}
