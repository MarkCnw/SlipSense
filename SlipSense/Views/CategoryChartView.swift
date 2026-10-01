import SwiftUI
import SwiftData
import Charts

struct CategoryChartView: View {
    let periodSlips: [SlipRecord]
    
    var chartData: [CategoryExpenseSummary] {
        let grouped = Dictionary(grouping: periodSlips, by: {
            $0.category.isEmpty ? "อื่นๆ" : $0.category
        })
        
        let summaries = grouped.map { (cat, slips) in
            let realExpenses = slips.filter { !$0.isSelfTransfer }
            let total = realExpenses.reduce(0) { $0 + $1.amount }
            return CategoryExpenseSummary(categoryName: cat, totalAmount: total)
        }
        
        return summaries
            .filter { $0.totalAmount > 0 }
            .sorted { $0.totalAmount > $1.totalAmount }
    }
    
    // คำนวณยอดรวมทั้งหมดเพื่อเอาไปโชว์ตรงกลางโดนัท
    var totalAmount: Double {
        chartData.reduce(0) { $0 + $1.totalAmount }
    }
    
    // ฟังก์ชันช่วยเลือกไอคอนให้ตรงกับหมวดหมู่
    private func getIcon(for category: String) -> String {
        if category.contains("อาหาร") || category.contains("เครื่องดื่ม") { return "fork.knife" }
        if category.contains("เดินทาง") { return "car.fill" }
        if category.contains("ช้อปปิ้ง") || category.contains("ของใช้") { return "cart.fill" }
        if category.contains("บิล") || category.contains("สาธารณูปโภค") { return "doc.text.fill" }
        return "tag.fill"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // ส่วน Header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("หมวดหมู่ค่าใช้จ่าย")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                            .foregroundStyle(.purple)
                        Text("วิเคราะห์อัตโนมัติโดย AI")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chart.pie.fill")
                    .font(.title3)
                    .foregroundStyle(Color.gray.opacity(0.3))
            }
            .padding(.bottom, 4)
            
            if chartData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("ไม่มีข้อมูล")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)
            } else {
                HStack(spacing: 16) {
                    
                    // 🌟 1. กราฟวงกลมแบบ Donut
                    Chart(chartData) { item in
                        SectorMark(
                            angle: .value("จำนวนเงิน", item.totalAmount),
                            innerRadius: .ratio(0.70), // เจาะรูตรงกลาง 70%
                            angularInset: 2 // เว้นช่องไฟระหว่างชิ้นให้ดูคลีนขึ้น
                        )
                        .cornerRadius(6)
                        .foregroundStyle(by: .value("หมวดหมู่", item.categoryName))
                        .opacity(0.95)
                    }
                    .frame(width: 170, height: 170)
                    .chartLegend(.hidden) // ซ่อน Legend อัตโนมัติ เพราะเราจะทำเองด้านขวา
                    .chartBackground { chartProxy in
                        GeometryReader { geometry in
                            if let frame = chartProxy.plotFrame {
                                let rect = geometry[frame]
                                VStack(spacing: 2) {
                                    Text("รวมทั้งหมด")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text(totalAmount, format: .number.precision(.fractionLength(0)))
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .contentTransition(.numericText())
                                }
                                .position(x: rect.midX, y: rect.midY)
                            }
                        }
                    }
                    
                    // 🌟 2. รายชื่อหมวดหมู่พร้อมไอคอน (Custom Legend)
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(chartData.prefix(5)) { item in
                            let percent = (item.totalAmount / totalAmount) * 100
                            
                            HStack(spacing: 8) {
                                // ดึงไอคอน SF Symbol ตามชื่อหมวดหมู่
                                Image(systemName: getIcon(for: item.categoryName))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 16)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.categoryName)
                                        .font(.caption.weight(.semibold))
                                        .lineLimit(1)
                                    
                                    // โชว์เปอร์เซ็นต์และยอดเงิน
                                    Text("\(percent, specifier: "%.1f")% • \(item.totalAmount, format: .number.precision(.fractionLength(0)))")
                                        .font(.caption2.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 0)
                            }
                        }
                        
                        // ถ้ามีมากกว่า 5 หมวดหมู่ ให้ขึ้นว่าและอื่นๆ
                        if chartData.count > 5 {
                            Text("และอีก \(chartData.count - 5) หมวดหมู่")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .padding(.top, 2)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.top, 4)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
        )
        .padding(.horizontal)
    }
}
