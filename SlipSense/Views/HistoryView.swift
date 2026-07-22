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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. ค้นหาจากข้อความก่อน
                let searchedSlips = viewModel.getFilteredSlips(from: slips)
                
                // 2. กรองธนาคาร (ถ้า selectedBanks ว่างเปล่า = แสดงทั้งหมด)
                let displaySlips = searchedSlips.filter { slip in
                    selectedBanks.isEmpty || selectedBanks.contains(slip.bankName)
                }
                
                // MARK: - แสดงผลรายการ
                if displaySlips.isEmpty {
                    VStack(spacing: 16) {
                        Image("Analyze-Data-2--Streamline-Manila")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .grayscale(1.0)
                            .opacity(0.6)
                        
                        Text(slips.isEmpty ? "ยังไม่มีประวัติการสแกน" : "ไม่พบข้อมูลที่ค้นหา")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(displaySlips) { slip in
                            NavigationLink(destination: SlipImageDetailView(slip: slip)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(slip.bankName)
                                            .font(.headline)
                                        Text(slip.scanDate.formatted(.dateTime.day().month(.abbreviated).year().hour().minute().locale(Locale(identifier: "th_TH"))))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(slip.amount.formatted(.currency(code: "THB")))
                                        .font(.headline)
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
            
            // MARK: - ปุ่ม Filter สไตล์ Apple HIG
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // ปุ่มเคลียร์ตัวกรอง (จะโชว์ก็ต่อเมื่อมีการเลือกธนาคารไว้อยู่)
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
                        
                        // วนลูปรายชื่อธนาคารให้กดเลือกได้หลายอัน
                        ForEach(dynamicBankFilters, id: \.self) { bank in
                            Button {
                                withAnimation(.snappy) {
                                    // โลจิก Multi-select: ถ้ามีอยู่แล้วให้เอาออก ถ้าไม่มีให้เพิ่มเข้าไป
                                    if selectedBanks.contains(bank) {
                                        selectedBanks.remove(bank)
                                    } else {
                                        selectedBanks.insert(bank)
                                    }
                                }
                            } label: {
                                // ถ้าธนาคารนี้อยู่ใน Set ให้แสดงเครื่องหมายถูก (Checkmark) แบบ Native
                                if selectedBanks.contains(bank) {
                                    Label(bank, systemImage: "checkmark")
                                } else {
                                    Text(bank)
                                }
                            }
                        }
                    } label: {
                        // ไอคอนปุ่ม Filter มุมขวาบน จะทึบและเป็นสีฟ้าเมื่อมีการใช้งานตัวกรองอยู่
                        Image(systemName: selectedBanks.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                            .font(.title3)
                            .foregroundColor(selectedBanks.isEmpty ? .primary : .blue)
                    }
                }
            }
        }
    }
}
